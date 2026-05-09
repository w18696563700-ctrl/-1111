import Flutter
import UIKit
import AlipaySDK

class SceneDelegate: FlutterSceneDelegate {
  override func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
    for context in URLContexts {
      let url = context.url
      let scheme = (Bundle.main.object(forInfoDictionaryKey: "AlipayAppScheme") as? String)?
        .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
      if !scheme.isEmpty && url.scheme == scheme {
        AlipaySDK.defaultService().processOrder(withPaymentResult: url) { _ in }
        AlipaySDK.defaultService().processAuth_V2Result(url) { _ in }
        return
      }
    }
    super.scene(scene, openURLContexts: URLContexts)
  }
}
