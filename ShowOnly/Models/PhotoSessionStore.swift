import SwiftUI
import UIKit

/// 기기 메모리에서만 선택 사진과 게스트 세션 상태를 관리합니다.
@MainActor
final class PhotoSessionStore: ObservableObject {
    @Published private(set) var photos: [UIImage] = []
    @Published var isPresented = false
    @Published private(set) var isLocked = true

    func begin(with images: [UIImage]) {
        guard !images.isEmpty else { return }
        photos = images
        isLocked = false
        isPresented = true
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
}
