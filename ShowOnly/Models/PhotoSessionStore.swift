import SwiftUI
import UIKit

/// 기기 메모리에서만 선택 사진과 게스트 세션 상태를 관리합니다.
@MainActor
final class PhotoSessionStore: ObservableObject {
    @Published private(set) var photos: [UIImage] = []
    @Published var isPresented = false
    @Published private(set) var isLocked = true
    /// 보여주는 중 iOS가 앱을 종료해 이전 세션이 사라졌을 때 홈에 안내를 띄웁니다.
    @Published private(set) var showsSessionEndedNotice = false

    init() {
        // TODO(기능): 이전 실행에서 세션이 정상 종료되지 않았는지 확인해 showsSessionEndedNotice 설정
    }

    func begin(with images: [UIImage]) {
        guard !images.isEmpty else { return }
        photos = images
        isLocked = false
        isPresented = true
        showsSessionEndedNotice = false
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
    }

    func dismissSessionEndedNotice() {
        showsSessionEndedNotice = false
    }
}
