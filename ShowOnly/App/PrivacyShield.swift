import UIKit

/// 앱 스위처 스냅샷에 사진이 찍히지 않도록 비활성화 순간 최상단에 가림 창을 띄웁니다.
@MainActor
enum PrivacyShield {
    // TODO(기능): willResignActive에 show(), didBecomeActive에 hide()
    static func show() {}
    static func hide() {}
}
