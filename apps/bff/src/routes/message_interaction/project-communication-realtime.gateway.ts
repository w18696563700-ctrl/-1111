import { Injectable, Logger } from "@nestjs/common";
import type { IncomingMessage, Server } from "http";
import { URL } from "url";
import { WebSocket, WebSocketServer } from "ws";
import type { RawData } from "ws";
import { MessageInteractionService } from "./message-interaction.service";

type SubscribeMessage = {
  action: "project_communication.subscribe";
  threadId: string;
  projectId: string;
  counterpartOrganizationId?: string;
};

type RealtimeClient = {
  send(message: string): void;
};

type AcceptedSubscription = {
  eventType: "project_communication.subscription.accepted";
  projectId: string;
  threadId: string;
  counterpartOrganizationId: string | null;
};

type RejectedSubscription = {
  eventType: "project_communication.subscription.rejected";
  code: string;
  message: string;
};

const REALTIME_PATH = "/api/app/message/project-communication/realtime";
const POLL_INTERVAL_MS = 2000;

@Injectable()
export class ProjectCommunicationRealtimeGateway {
  private readonly logger = new Logger(
    ProjectCommunicationRealtimeGateway.name,
  );
  private readonly subscriptions = new Map<string, Set<RealtimeClient>>();
  private attached = false;

  constructor(private readonly service: MessageInteractionService) {}

  attach(server: Server) {
    if (this.attached) {
      return;
    }
    this.attached = true;
    const websocketServer = new WebSocketServer({ noServer: true });
    server.on("upgrade", (request, socket, head) => {
      if (!this.isRealtimeRequest(request)) {
        return;
      }
      websocketServer.handleUpgrade(request, socket, head, (client) => {
        websocketServer.emit("connection", client, request);
      });
    });
    websocketServer.on("connection", (client, request) => {
      this.handleConnection(client, request);
    });
  }

  private handleConnection(client: WebSocket, request: IncomingMessage) {
    this.send(client, {
      eventType: "project_communication.connected",
    });
    let timer: NodeJS.Timeout | null = null;
    let afterEventId: string | null = null;

    client.on("message", (data) => {
      void this.handleMessage(client, request, data, {
        stop: () => {
          if (timer) {
            clearInterval(timer);
            timer = null;
          }
        },
        start: (subscription) => {
          if (timer) {
            clearInterval(timer);
          }
          const poll = async () => {
            try {
              const result =
                await this.service.listProjectCommunicationRealtimeEvents(
                  subscription.threadId,
                  subscription.projectId,
                  afterEventId ?? undefined,
                  request.headers,
                );
              for (const event of result.items) {
                afterEventId = event.eventId;
                this.send(client, event);
              }
            } catch (error) {
              this.logger.warn(
                `project communication realtime poll failed: ${(error as Error).message}`,
              );
              this.send(client, {
                eventType: "project_communication.error",
                code: "PROJECT_COMMUNICATION_REALTIME_UNAVAILABLE",
              });
            }
          };
          void poll();
          timer = setInterval(poll, POLL_INTERVAL_MS);
        },
      });
    });

    client.on("close", () => {
      if (timer) {
        clearInterval(timer);
      }
      this.removeClient(client);
    });
  }

  private async handleMessage(
    client: WebSocket,
    request: IncomingMessage,
    data: RawData,
    polling: {
      stop(): void;
      start(subscription: SubscribeMessage): void;
    },
  ) {
    const subscription = this.readSubscribeMessage(data);
    if (!subscription) {
      this.send(client, {
        eventType: "project_communication.error",
        code: "PROJECT_COMMUNICATION_REALTIME_INVALID",
      });
      return;
    }
    const accepted = await this.handleSubscribe(
      client,
      subscription,
      request.headers,
    );
    if (accepted.eventType === "project_communication.subscription.accepted") {
      polling.stop();
      polling.start(subscription);
      return;
    }
    if (accepted.code === "PROJECT_COMMUNICATION_FORBIDDEN") {
      client.close();
    }
  }

  async handleSubscribe(
    client: Partial<RealtimeClient>,
    message: Record<string, unknown>,
    headers: IncomingMessage["headers"] = {},
  ): Promise<AcceptedSubscription | RejectedSubscription> {
    const subscription = this.readSubscribeRecord(message);
    if (!subscription) {
      const rejected = {
        eventType: "project_communication.subscription.rejected",
        code: "PROJECT_COMMUNICATION_INVALID",
        message: "Subscription requires projectId and threadId.",
      } satisfies RejectedSubscription;
      this.sendPlain(client, rejected);
      return rejected;
    }

    try {
      await this.service.listProjectCommunicationMessages(
        subscription.threadId,
        subscription.projectId,
        undefined,
        "1",
        headers,
      );
      const accepted = {
        eventType: "project_communication.subscription.accepted",
        projectId: subscription.projectId,
        threadId: subscription.threadId,
        counterpartOrganizationId:
          subscription.counterpartOrganizationId ?? null,
      } satisfies AcceptedSubscription;
      this.addSubscription(client, subscription);
      this.sendPlain(client, accepted);
      return accepted;
    } catch (error) {
      const rejected = {
        eventType: "project_communication.subscription.rejected",
        code: "PROJECT_COMMUNICATION_FORBIDDEN",
        message: this.readErrorMessage(error),
      } satisfies RejectedSubscription;
      this.sendPlain(client, rejected);
      return rejected;
    }
  }

  forwardMessageCreated(event: Record<string, unknown>) {
    if (event.eventType !== "project_communication.message.created") {
      return 0;
    }
    const threadId = this.readRequiredString(event.threadId);
    const projectId = this.readRequiredString(event.projectId);
    if (!threadId || !projectId) {
      return 0;
    }
    const clients = this.subscriptions.get(
      this.subscriptionKey(threadId, projectId),
    );
    if (!clients) {
      return 0;
    }
    let sent = 0;
    for (const client of clients) {
      this.sendPlain(client, event);
      sent += 1;
    }
    return sent;
  }

  private readSubscribeMessage(data: RawData): SubscribeMessage | null {
    try {
      const source = JSON.parse(data.toString()) as Record<string, unknown>;
      return this.readSubscribeRecord(source);
    } catch {
      return null;
    }
  }

  private readSubscribeRecord(
    source: Record<string, unknown>,
  ): SubscribeMessage | null {
    if (source.action !== "project_communication.subscribe") {
      return null;
    }
    const threadId = this.readRequiredString(source.threadId);
    const projectId = this.readRequiredString(source.projectId);
    if (!threadId || !projectId) {
      return null;
    }
    const counterpartOrganizationId = this.readOptionalString(
      source.counterpartOrganizationId,
    );
    return {
      action: "project_communication.subscribe",
      threadId,
      projectId,
      counterpartOrganizationId: counterpartOrganizationId ?? undefined,
    };
  }

  private isRealtimeRequest(request: IncomingMessage) {
    const host = request.headers.host ?? "127.0.0.1";
    const url = new URL(request.url ?? "/", `http://${host}`);
    return url.pathname === REALTIME_PATH;
  }

  private readRequiredString(value: unknown) {
    return typeof value === "string" && value.trim() ? value.trim() : null;
  }

  private readOptionalString(value: unknown) {
    return typeof value === "string" && value.trim() ? value.trim() : null;
  }

  private addSubscription(
    client: Partial<RealtimeClient>,
    subscription: SubscribeMessage,
  ) {
    if (!client.send) {
      return;
    }
    const key = this.subscriptionKey(
      subscription.threadId,
      subscription.projectId,
    );
    const clients = this.subscriptions.get(key) ?? new Set<RealtimeClient>();
    clients.add(client as RealtimeClient);
    this.subscriptions.set(key, clients);
  }

  private removeClient(client: Partial<RealtimeClient>) {
    for (const [key, clients] of this.subscriptions) {
      clients.delete(client as RealtimeClient);
      if (clients.size === 0) {
        this.subscriptions.delete(key);
      }
    }
  }

  private subscriptionKey(threadId: string, projectId: string) {
    return `${projectId}:${threadId}`;
  }

  private readErrorMessage(error: unknown) {
    if (error && typeof error === "object" && "getResponse" in error) {
      const response = (error as { getResponse(): unknown }).getResponse();
      if (response && typeof response === "object" && "message" in response) {
        return String((response as { message?: unknown }).message);
      }
    }
    return "Project communication subscription is not allowed.";
  }

  private sendPlain(
    client: Partial<RealtimeClient>,
    payload: Record<string, unknown>,
  ) {
    client.send?.(JSON.stringify(payload));
  }

  private send(client: WebSocket, payload: Record<string, unknown>) {
    if (client.readyState === WebSocket.OPEN) {
      client.send(JSON.stringify(payload));
    }
  }
}
