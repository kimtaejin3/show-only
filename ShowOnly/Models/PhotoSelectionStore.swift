import SwiftUI
import PhotosUI
import UIKit

/// 홈에서 고른 사진 한 장의 불러오기 상태.
enum PhotoLoadState: Equatable {
    case loading
    case loaded(UIImage)
    case failed
}

struct SelectedPhoto: Identifiable, Equatable {
    /// PhotosPickerItem.itemIdentifier 또는 순번 기반 id
    let id: String
    var state: PhotoLoadState
}

/// 홈 화면의 사진 선택·불러오기 상태. 보여주기가 시작되면 세션으로 넘기고 비웁니다.
@MainActor
final class PhotoSelectionStore: ObservableObject {
    static let maxCount = 10

    /// PhotosPicker의 selection 바인딩
    @Published var pickerItems: [PhotosPickerItem] = []
    /// 고른 순서대로의 사진 상태
    @Published private(set) var photos: [SelectedPhoto] = []

    var isLoading: Bool { photos.contains { $0.state == .loading } }
    var loadedImages: [UIImage] {
        photos.compactMap { if case .loaded(let image) = $0.state { return image } else { return nil } }
    }
    var loadedCount: Int { loadedImages.count }
    var failedCount: Int { photos.filter { $0.state == .failed }.count }
    var isAtLimit: Bool { photos.count >= Self.maxCount }
    var isEmpty: Bool { photos.isEmpty }

    /// pickerItems가 바뀔 때 호출. 각 사진을 다운샘플링하며 불러옵니다.
    func load(_ items: [PhotosPickerItem]) async {
        // TODO(기능): 다운샘플링, 순서 유지, 재시도용 item 보관, 취소 처리
        photos = items.enumerated().map { SelectedPhoto(id: $0.element.itemIdentifier ?? "\($0.offset)", state: .loading) }
        for (index, item) in items.enumerated() {
            if let data = try? await item.loadTransferable(type: Data.self), let image = UIImage(data: data) {
                photos[index].state = .loaded(image)
            } else {
                photos[index].state = .failed
            }
        }
    }

    /// 실패한 사진만 다시 불러옵니다.
    func retryFailed() async {
        // TODO(기능)
    }

    /// 선택을 모두 비웁니다(보여주기 시작 후, 다시 고르기 전).
    func clear() {
        pickerItems = []
        photos = []
    }
}
