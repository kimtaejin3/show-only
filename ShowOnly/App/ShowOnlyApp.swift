import SwiftUI
import UIKit

@main
struct ShowOnlyApp: App {
    @StateObject private var session = PhotoSessionStore()
    @Environment(\.scenePhase) private var scenePhase

    var body: some Scene {
        WindowGroup {
            HomeView()
                .environmentObject(session)
                .onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) { _ in
                    shieldAndLock(leavingApp: false)
                }
                .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
                    // 가림 창을 내리면 아래의 잠금 화면이 이어서 사진을 가립니다.
                    PrivacyShield.hide()
                }
                .onChange(of: scenePhase) { phase in
                    if phase != .active {
                        shieldAndLock(leavingApp: phase == .background)
                    }
                }
        }
    }

    /// 보여주는 중일 때만 가림 창을 띄우고, 세션을 잠급니다.
    /// 앱 안의 인증 시트로 잠깐 비활성화된 경우는 건너뛰고, 실제로 앱을 떠나면 항상 잠급니다.
    private func shieldAndLock(leavingApp: Bool) {
        if session.isAuthenticatingInApp && !leavingApp { return }
        if session.isPresented {
            PrivacyShield.show()
        }
        session.lock()
    }
}
