import UIKit

/// 앱 스위처 스냅샷에 사진이 찍히지 않도록 비활성화 순간 최상단에 가림 창을 띄웁니다.
@MainActor
enum PrivacyShield {
    /// 이미지·블러 없이 단색으로만 가립니다.
    private static let shieldColor = UIColor(red: 0x0B / 255, green: 0x0F / 255, blue: 0x0F / 255, alpha: 1)
    private static var window: UIWindow?

    static func show() {
        if let window {
            window.isHidden = false
            return
        }
        guard let scene = activeScene() else { return }

        let controller = UIViewController()
        controller.view.backgroundColor = shieldColor
        controller.view.accessibilityViewIsModal = true

        let shield = UIWindow(windowScene: scene)
        shield.frame = scene.coordinateSpace.bounds
        shield.windowLevel = .alert + 1
        shield.backgroundColor = shieldColor
        shield.rootViewController = controller
        // 키 윈도우를 빼앗지 않도록 makeKey 없이 보이게만 합니다.
        shield.isHidden = false
        window = shield
    }

    static func hide() {
        window?.isHidden = true
        window?.rootViewController = nil
        window = nil
    }

    private static func activeScene() -> UIWindowScene? {
        let scenes = UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }
        return scenes.first { $0.activationState == .foregroundActive }
            ?? scenes.first { $0.activationState == .foregroundInactive }
            ?? scenes.first
    }
}
