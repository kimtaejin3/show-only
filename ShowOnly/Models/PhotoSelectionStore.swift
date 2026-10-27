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
    /// 원본 Data가 동시에 너무 많이 메모리에 올라오지 않도록 제한
    private static let maxConcurrentLoads = 3

    /// PhotosPicker의 selection 바인딩
    @Published var pickerItems: [PhotosPickerItem] = []
    /// 고른 순서대로의 사진 상태
    @Published private(set) var photos: [SelectedPhoto] = []

    /// photos와 같은 순서의 원본 항목. 재시도에 씁니다.
    private var items: [PhotosPickerItem] = []
    private var loadTask: Task<Void, Never>?
    /// 이전 불러오기의 늦은 결과가 새 선택을 덮어쓰지 않게 하는 세대 번호
    private var generation = 0

    var isLoading: Bool { photos.contains { $0.state == .loading } }
    var loadedImages: [UIImage] {
        photos.compactMap { if case .loaded(let image) = $0.state { return image } else { return nil } }
    }
    var loadedCount: Int { loadedImages.count }
    var failedCount: Int { photos.filter { $0.state == .failed }.count }
    var isAtLimit: Bool { photos.count >= Self.maxCount }
    var isEmpty: Bool { photos.isEmpty }

    /// pickerItems가 바뀔 때 호출. 진행 중인 불러오기는 취소하고, 고른 순서대로 다운샘플링하며 불러옵니다.
    func load(_ newItems: [PhotosPickerItem]) async {
        cancelInFlight()
        let capped = Array(newItems.prefix(Self.maxCount))
        items = capped
        photos = capped.enumerated().map { offset, item in
            SelectedPhoto(id: "\(offset)-\(item.itemIdentifier ?? "item")", state: .loading)
        }
        await run(indices: Array(capped.indices))
    }

    /// 실패한 사진만 다시 불러옵니다.
    func retryFailed() async {
        let failed = photos.indices.filter { photos[$0].state == .failed && $0 < items.count }
        guard !failed.isEmpty else { return }
        cancelInFlight()
        for index in failed {
            photos[index].state = .loading
        }
        await run(indices: failed)
    }

    /// 선택을 모두 비웁니다(보여주기 시작 후, 다시 고르기 전).
    func clear() {
        cancelInFlight()
        items = []
        pickerItems = []
        photos = []
    }

    // MARK: - 불러오기

    private func cancelInFlight() {
        loadTask?.cancel()
        loadTask = nil
        generation += 1
    }

    private func run(indices: [Int]) async {
        guard !indices.isEmpty else { return }
        let token = generation
        let targets = indices.map { ($0, items[$0]) }
        let maxPixelSize = ImageDownsampler.defaultMaxPixelSize

        let task = Task { [weak self] in
            await withTaskGroup(of: (Int, UIImage?).self) { group in
                var pending = targets[...]
                func enqueue() {
                    guard let (index, item) = pending.popFirst() else { return }
                    group.addTask { (index, await Self.loadImage(item, maxPixelSize: maxPixelSize)) }
                }
                for _ in 0..<Self.maxConcurrentLoads { enqueue() }

                while let (index, image) = await group.next() {
                    guard !Task.isCancelled else { group.cancelAll(); return }
                    self?.apply(image, at: index, token: token)
                    enqueue()
                }
            }
        }
        loadTask = task
        await task.value
        if generation == token {
            loadTask = nil
        }
    }

    private func apply(_ image: UIImage?, at index: Int, token: Int) {
        guard token == generation, photos.indices.contains(index) else { return }
        photos[index].state = image.map(PhotoLoadState.loaded) ?? .failed
    }

    /// 선택한 항목의 데이터만 메모리로 받아 다운샘플링합니다. 디스크·네트워크에 쓰지 않습니다.
    private nonisolated static func loadImage(_ item: PhotosPickerItem, maxPixelSize: CGFloat) async -> UIImage? {
        guard !Task.isCancelled,
              let data = try? await item.loadTransferable(type: Data.self),
              !Task.isCancelled else {
            return nil
        }
        return ImageDownsampler.downsample(data: data, maxPixelSize: maxPixelSize)
    }
}
