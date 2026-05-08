const test = require('node:test');
const assert = require('node:assert/strict');

function createContext() {
  return {
    authorization: 'Bearer project-communication-read-state-test',
    actorId: 'actor-owner',
    userId: 'user-owner',
    organizationId: 'owner-org',
    actorRole: 'buyer_admin',
    requestId: 'project-communication-read-state-test',
    traceId: 'trace-project-communication-read-state-test',
    userAgent: 'node-test',
    remoteIp: '127.0.0.1',
  };
}

function createMessage(overrides) {
  return {
    id: 'message-1',
    threadId: 'thread-1',
    projectId: 'project-1',
    senderUserId: 'user-owner',
    senderActorId: 'actor-owner',
    senderOrganizationId: 'owner-org',
    messageKind: 'text',
    body: 'hello',
    payload: {},
    clientMessageId: null,
    messageState: 'active',
    createdAt: new Date('2026-05-19T10:00:00.000Z'),
    ...overrides,
  };
}

test('project communication message list projects counterpart read cursor state for own messages', async () => {
  const {
    ProjectCommunicationMessageService,
  } = require('../dist/modules/project_communication/project-communication-message.service.js');
  const {
    ProjectCommunicationPresenter,
  } = require('../dist/modules/project_communication/project-communication.presenter.js');
  const {
    ProjectCommunicationReadCursorEntity,
  } = require('../dist/modules/project_communication/entities/project-communication-read-cursor.entity.js');

  const readBoundary = createMessage({ id: 'message-read' });
  const messages = [
    readBoundary,
    createMessage({
      id: 'message-unread',
      createdAt: new Date('2026-05-19T10:01:00.000Z'),
    }),
    createMessage({
      id: 'message-from-counterpart',
      senderUserId: 'user-counterpart',
      senderActorId: 'actor-counterpart',
      senderOrganizationId: 'counterpart-org',
      createdAt: new Date('2026-05-19T10:02:00.000Z'),
    }),
  ];
  const messageRepository = {
    async find() {
      return messages;
    },
    async findOneBy(where) {
      assert.deepEqual(where, {
        id: 'message-read',
        threadId: 'thread-1',
        projectId: 'project-1',
      });
      return readBoundary;
    },
  };
  const readCursorRepository = {
    async findOneBy(where) {
      assert.deepEqual(where, {
        threadId: 'thread-1',
        organizationId: 'counterpart-org',
      });
      return {
        threadId: 'thread-1',
        projectId: 'project-1',
        organizationId: 'counterpart-org',
        lastReadMessageId: 'message-read',
        lastReadAt: new Date('2026-05-19T10:03:00.000Z'),
        updatedAt: new Date('2026-05-19T10:03:00.000Z'),
      };
    },
  };
  const service = new ProjectCommunicationMessageService(
    messageRepository,
    {
      getRepository(entity) {
        assert.equal(entity, ProjectCommunicationReadCursorEntity);
        return readCursorRepository;
      },
    },
    {},
    {},
    new ProjectCommunicationPresenter(),
    {},
  );
  service.requireThreadParticipant = async () => ({
    actor: {
      currentSession: {
        userId: 'user-owner',
        actorId: 'actor-owner',
      },
      organizationId: 'owner-org',
    },
    thread: {
      id: 'thread-1',
      projectId: 'project-1',
      ownerOrganizationId: 'owner-org',
      counterpartOrganizationId: 'counterpart-org',
    },
  });

  const result = await service.listMessages(
    { threadId: 'thread-1', projectId: 'project-1' },
    createContext(),
  );

  assert.equal(result.items[0].deliveryState, 'persisted');
  assert.equal(result.items[0].readState, 'read_by_counterpart');
  assert.equal(result.items[0].readByCounterpartAt, '2026-05-19T10:03:00.000Z');
  assert.equal(result.items[1].readState, 'unread_by_counterpart');
  assert.equal(result.items[1].readByCounterpartAt, null);
  assert.equal(result.items[2].readState, 'not_applicable');
  assert.equal(result.items[2].readByCounterpartAt, null);
});

test('project communication message list keeps historical null read cursor compatible', async () => {
  const {
    ProjectCommunicationMessageService,
  } = require('../dist/modules/project_communication/project-communication-message.service.js');
  const {
    ProjectCommunicationPresenter,
  } = require('../dist/modules/project_communication/project-communication.presenter.js');
  const {
    ProjectCommunicationReadCursorEntity,
  } = require('../dist/modules/project_communication/entities/project-communication-read-cursor.entity.js');

  const messages = [
    createMessage({
      id: 'message-before-null-cursor',
      createdAt: new Date('2026-05-19T10:00:00.000Z'),
    }),
    createMessage({
      id: 'message-after-null-cursor',
      createdAt: new Date('2026-05-19T10:05:00.000Z'),
    }),
  ];
  const messageRepository = {
    async find() {
      return messages;
    },
    async findOneBy() {
      throw new Error('historical null cursor should not load a boundary message');
    },
  };
  const readCursorRepository = {
    async findOneBy(where) {
      assert.deepEqual(where, {
        threadId: 'thread-1',
        organizationId: 'counterpart-org',
      });
      return {
        threadId: 'thread-1',
        projectId: 'project-1',
        organizationId: 'counterpart-org',
        lastReadMessageId: null,
        lastReadAt: new Date('2026-05-19T10:03:00.000Z'),
        updatedAt: new Date('2026-05-19T10:03:00.000Z'),
      };
    },
  };
  const service = new ProjectCommunicationMessageService(
    messageRepository,
    {
      getRepository(entity) {
        assert.equal(entity, ProjectCommunicationReadCursorEntity);
        return readCursorRepository;
      },
    },
    {},
    {},
    new ProjectCommunicationPresenter(),
    {},
  );
  service.requireThreadParticipant = async () => ({
    actor: {
      currentSession: {
        userId: 'user-owner',
        actorId: 'actor-owner',
      },
      organizationId: 'owner-org',
    },
    thread: {
      id: 'thread-1',
      projectId: 'project-1',
      ownerOrganizationId: 'owner-org',
      counterpartOrganizationId: 'counterpart-org',
    },
  });

  const result = await service.listMessages(
    { threadId: 'thread-1', projectId: 'project-1' },
    createContext(),
  );

  assert.equal(result.items[0].readState, 'read_by_counterpart');
  assert.equal(result.items[0].readByCounterpartAt, '2026-05-19T10:03:00.000Z');
  assert.equal(result.items[1].readState, 'unread_by_counterpart');
  assert.equal(result.items[1].readByCounterpartAt, null);
});
