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
                    session.lock()
                }
                .onChange(of: scenePhase) { phase in
                    if phase != .active {
                        session.lock()
                    }
                }
        }
    }
}
