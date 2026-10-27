import SwiftUI
import UIKit
import Combine

/// 기기 메모리에서만 선택 사진과 게스트 세션 상태를 관리합니다.
@MainActor
final class PhotoSessionStore: ObservableObject {
    @Published private(set) var photos: [UIImage] = []
    @Published var isPresented = false
    @Published private(set) var isLocked = true
    /// 보여주는 중 iOS가 앱을 종료해 이전 세션이 사라졌을 때 홈에 안내를 띄웁니다.
    @Published private(set) var showsSessionEndedNotice = false
    /// 앱 안에서 띄운 Face ID·암호 확인 중. 이때의 일시적인 비활성화로는 잠그지 않습니다.
    private(set) var isAuthenticatingInApp = false

    /// 세션 진행 여부만 담는 플래그. 사진 데이터는 절대 저장하지 않습니다.
    private static let activeFlagKey = "session.isActive"
    private let defaults: UserDefaults
    private var cancellables = Set<AnyCancellable>()

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        if defaults.bool(forKey: Self.activeFlagKey) {
            showsSessionEndedNotice = true
            defaults.removeObject(forKey: Self.activeFlagKey)
        }

        NotificationCenter.default.publisher(for: UIApplication.didReceiveMemoryWarningNotification)
            .sink { [weak self] _ in
                Task { @MainActor in self?.handleMemoryWarning() }
            }
            .store(in: &cancellables)
    }

    func begin(with images: [UIImage]) {
        guard !images.isEmpty else { return }
        photos = images
        isLocked = false
        isPresented = true
        showsSessionEndedNotice = false
        defaults.set(true, forKey: Self.activeFlagKey)
    }

    /// 주인 확인을 진행합니다. 인증 시트 때문에 앱이 잠깐 비활성화돼도 세션을 잠그지 않습니다.
    func authenticateOwner(_ authenticate: () async -> AuthOutcome) async -> AuthOutcome {
        isAuthenticatingInApp = true
        defer { isAuthenticatingInApp = false }
        return await authenticate()
    }

    func lock() {
        if isPresented {
            isLocked = true
        }
    }

    func unlock() {
        if isPresented {
            isLocked = false
        }
    }

    func end() {
        isLocked = true
        isPresented = false
        photos.removeAll()
        defaults.removeObject(forKey: Self.activeFlagKey)
    }

    func dismissSessionEndedNotice() {
        showsSessionEndedNotice = false
    }

    /// 사진은 이미 다운샘플링돼 있어 보여주는 중에는 유지하고, 세션 밖에 남은 참조만 정리합니다.
    private func handleMemoryWarning() {
        if !isPresented, !photos.isEmpty {
            photos.removeAll()
        }
    }
}
