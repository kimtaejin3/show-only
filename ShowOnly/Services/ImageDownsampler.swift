import UIKit
import ImageIO

/// 큰 원본을 화면 크기에 맞게 줄여 메모리 사용을 제한합니다. 디스크에 아무것도 쓰지 않습니다.
enum ImageDownsampler {
    /// 화면 긴 변 × 배율 정도. 확대 보기 여유를 두되 원본(48MP 등)보다 훨씬 작게 유지합니다.
    static let defaultMaxPixelSize: CGFloat = 2400

    static func downsample(data: Data, maxPixelSize: CGFloat) -> UIImage? {
        let sourceOptions = [kCGImageSourceShouldCache: false] as CFDictionary
        guard let source = CGImageSourceCreateWithData(data as CFData, sourceOptions),
              CGImageSourceGetCount(source) > 0 else {
            return nil
        }

        let thumbnailOptions = [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceShouldCacheImmediately: true,
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceThumbnailMaxPixelSize: max(1, Int(maxPixelSize.rounded()))
        ] as CFDictionary

        guard let cgImage = CGImageSourceCreateThumbnailAtIndex(source, 0, thumbnailOptions) else {
            return nil
        }
        // 방향은 이미 픽셀에 반영됨(WithTransform)
        return UIImage(cgImage: cgImage, scale: 1, orientation: .up)
    }
}
