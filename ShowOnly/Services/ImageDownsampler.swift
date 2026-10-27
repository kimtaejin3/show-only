import UIKit
import ImageIO

/// 큰 원본을 화면 크기에 맞게 줄여 메모리 사용을 제한합니다.
enum ImageDownsampler {
    // TODO(기능): CGImageSourceCreateThumbnailAtIndex 기반 구현
    static func downsample(data: Data, maxPixelSize: CGFloat) -> UIImage? {
        UIImage(data: data)
    }
}
