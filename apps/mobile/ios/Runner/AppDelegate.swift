import Flutter
import UIKit
import UserNotifications

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  private let apnsChannelName = "exhibition_home/apns_notifications"
  private var apnsChannel: FlutterMethodChannel?
  private var pendingApnsRegistrationResult: FlutterResult?
  private var latestApnsDeviceToken: String?
  private var pendingRouteTarget: [String: Any]?

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    let result = super.application(application, didFinishLaunchingWithOptions: launchOptions)
    UNUserNotificationCenter.current().delegate = self
    configureApnsChannelIfPossible()
    if let launchOptions,
       let notification = launchOptions[.remoteNotification] as? [AnyHashable: Any] {
      pendingRouteTarget = extractRouteTarget(from: notification)
    }
    return result
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    configureApnsChannelIfPossible()
  }

  override func application(
    _ application: UIApplication,
    didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
  ) {
    latestApnsDeviceToken = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
    completePendingApnsRegistration(
      permissionGranted: true,
      authorizationStatus: "authorized",
      deviceToken: latestApnsDeviceToken,
      message: "APNs device token 已获取。"
    )
  }

  override func application(
    _ application: UIApplication,
    didFailToRegisterForRemoteNotificationsWithError error: Error
  ) {
    completePendingApnsRegistration(
      permissionGranted: true,
      authorizationStatus: "authorized",
      deviceToken: nil,
      message: "APNs device token 获取失败，已降级为站内通知。"
    )
  }

  override func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    willPresent notification: UNNotification,
    withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
  ) {
    if #available(iOS 14.0, *) {
      completionHandler([.banner, .sound, .badge])
    } else {
      completionHandler([.alert, .sound, .badge])
    }
  }

  override func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    didReceive response: UNNotificationResponse,
    withCompletionHandler completionHandler: @escaping () -> Void
  ) {
    let userInfo = response.notification.request.content.userInfo
    pendingRouteTarget = extractRouteTarget(from: userInfo)
    notifyFlutterRouteTargetIfPossible()
    completionHandler()
  }

  private func configureApnsChannelIfPossible() {
    guard apnsChannel == nil,
          let controller = window?.rootViewController as? FlutterViewController else {
      return
    }
    let channel = FlutterMethodChannel(
      name: apnsChannelName,
      binaryMessenger: controller.binaryMessenger
    )
    channel.setMethodCallHandler { [weak self] call, result in
      guard let self else {
        result(FlutterError(code: "APNS_BRIDGE_UNAVAILABLE", message: "APNs bridge is unavailable.", details: nil))
        return
      }
      switch call.method {
      case "requestAuthorizationAndRegister":
        self.requestAuthorizationAndRegister(result: result)
      case "currentToken":
        result(self.latestApnsDeviceToken)
      case "pendingRouteTarget":
        result(self.pendingRouteTarget)
        self.pendingRouteTarget = nil
      default:
        result(FlutterMethodNotImplemented)
      }
    }
    apnsChannel = channel
    notifyFlutterRouteTargetIfPossible()
  }

  private func requestAuthorizationAndRegister(result: @escaping FlutterResult) {
    UNUserNotificationCenter.current().getNotificationSettings { [weak self] settings in
      guard let self else { return }
      if #available(iOS 14.0, *), settings.authorizationStatus == .ephemeral {
        self.registerForRemoteNotifications(result: result, authorizationStatus: "ephemeral")
        return
      }
      switch settings.authorizationStatus {
      case .authorized, .provisional:
        self.registerForRemoteNotifications(result: result, authorizationStatus: self.authorizationStatusName(settings.authorizationStatus))
      case .denied:
        result([
          "permissionSupported": true,
          "permissionGranted": false,
          "authorizationStatus": "denied",
          "deviceToken": NSNull(),
          "message": "用户未允许系统通知，已保留站内通知。"
        ])
      case .notDetermined:
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
          if let error {
            result([
              "permissionSupported": true,
              "permissionGranted": false,
              "authorizationStatus": "error",
              "deviceToken": NSNull(),
              "message": "系统通知权限请求失败，已降级为站内通知。",
              "errorCode": error.localizedDescription
            ])
            return
          }
          if !granted {
            result([
              "permissionSupported": true,
              "permissionGranted": false,
              "authorizationStatus": "denied",
              "deviceToken": NSNull(),
              "message": "用户未允许系统通知，已保留站内通知。"
            ])
            return
          }
          self.registerForRemoteNotifications(result: result, authorizationStatus: "authorized")
        }
      @unknown default:
        result([
          "permissionSupported": true,
          "permissionGranted": false,
          "authorizationStatus": "unknown",
          "deviceToken": NSNull(),
          "message": "系统通知权限状态未知，已降级为站内通知。"
        ])
      }
    }
  }

  private func registerForRemoteNotifications(
    result: @escaping FlutterResult,
    authorizationStatus: String
  ) {
    if let latestApnsDeviceToken {
      result([
        "permissionSupported": true,
        "permissionGranted": true,
        "authorizationStatus": authorizationStatus,
        "deviceToken": latestApnsDeviceToken,
        "message": "APNs device token 已获取。"
      ])
      return
    }
    DispatchQueue.main.async {
      self.pendingApnsRegistrationResult = result
      UIApplication.shared.registerForRemoteNotifications()
    }
  }

  private func completePendingApnsRegistration(
    permissionGranted: Bool,
    authorizationStatus: String,
    deviceToken: String?,
    message: String
  ) {
    guard let result = pendingApnsRegistrationResult else {
      return
    }
    pendingApnsRegistrationResult = nil
    result([
      "permissionSupported": true,
      "permissionGranted": permissionGranted,
      "authorizationStatus": authorizationStatus,
      "deviceToken": deviceToken ?? NSNull(),
      "message": message
    ])
  }

  private func authorizationStatusName(_ status: UNAuthorizationStatus) -> String {
    switch status {
    case .authorized:
      return "authorized"
    case .denied:
      return "denied"
    case .notDetermined:
      return "not_determined"
    case .provisional:
      return "provisional"
    @unknown default:
      if #available(iOS 14.0, *), status == .ephemeral {
        return "ephemeral"
      }
      return "unknown"
    }
  }

  private func extractRouteTarget(from userInfo: [AnyHashable: Any]) -> [String: Any]? {
    if let routeTarget = userInfo["routeTarget"] as? [String: Any] {
      return routeTarget
    }
    if let data = userInfo["data"] as? [String: Any],
       let routeTarget = data["routeTarget"] as? [String: Any] {
      return routeTarget
    }
    return nil
  }

  private func notifyFlutterRouteTargetIfPossible() {
    guard let pendingRouteTarget,
          let apnsChannel else {
      return
    }
    apnsChannel.invokeMethod("notificationRouteTargetOpened", arguments: pendingRouteTarget)
    self.pendingRouteTarget = nil
  }
}
