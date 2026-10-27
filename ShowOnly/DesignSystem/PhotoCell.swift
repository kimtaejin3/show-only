import SwiftUI
import UIKit

/// 홈 그리드의 사진 한 칸. 불러온 사진 / 불러오는 중 / 실패, 그리고 "+N" 오버레이.
struct PhotoCell: View {
    let state: PhotoLoadState
    /// 1부터 시작하는 보여줄 순서
    let order: Int
    /// 0보다 크면 이 칸 위에 "+N"을 얹어 나머지 장수를 표시
    var overflowCount = 0

    var body: some View {
        content
            .frame(maxWidth: .infinity)
            .frame(height: Theme.Size.thumbnailHeight)
            .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.sm, style: .continuous))
            .overlay {
                if overflowCount > 0 {
                    ZStack {
                        RoundedRectangle(cornerRadius: Theme.Radius.sm, style: .continuous)
                            .fill(Theme.Colors.viewerBg.opacity(0.45))
                        Text("+\(overflowCount)")
                            .font(Theme.Fonts.title)
                            .foregroundStyle(Theme.Colors.onPrimary)
                    }
                }
            }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(accessibilityText)
    }

    @ViewBuilder
    private var content: some View {
        switch state {
        case .loaded(let image):
            Color.clear
                .overlay {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                }
                .clipped()
                .overlay(alignment: .bottomLeading) {
                    Text("\(order)")
                        .font(Theme.Fonts.captionEmphasis.monospacedDigit())
                        .foregroundStyle(Theme.Colors.onPrimary)
                        .shadow(color: Theme.Colors.viewerBg.opacity(0.5), radius: 2)
                        .padding(Theme.Spacing.s2)
                }
        case .loading:
            ZStack {
                Theme.Colors.skeleton
                VStack(spacing: Theme.Spacing.s2) {
                    ProgressView()
                        .tint(Theme.Colors.text3)
                    Text("불러오는 중")
                        .font(Theme.Fonts.caption)
                        .foregroundStyle(Theme.Colors.text3)
                }
            }
        case .failed:
            ZStack {
                Theme.Colors.surface
                VStack(spacing: Theme.Spacing.s2) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(Theme.Fonts.subhead)
                        .foregroundStyle(Theme.Colors.warning)
                    Text("불러오지 못함")
                        .font(Theme.Fonts.caption)
                        .foregroundStyle(Theme.Colors.text2)
                }
                RoundedRectangle(cornerRadius: Theme.Radius.sm, style: .continuous)
                    .strokeBorder(Theme.Colors.hairline, lineWidth: 1)
            }
        }
    }

    private var accessibilityText: String {
        var text: String
        switch state {
        case .loaded: text = "\(order)번째 사진"
        case .loading: text = "\(order)번째 사진, 불러오는 중"
        case .failed: text = "\(order)번째 사진, 불러오지 못함"
        }
        if overflowCount > 0 {
            text += ", 외 \(overflowCount)장"
        }
        return text
    }
}

extension UIImage {
    /// 미리보기용 단색 이미지
    static func previewPlaceholder(_ color: UIColor, size: CGSize = CGSize(width: 300, height: 400)) -> UIImage {
        UIGraphicsImageRenderer(size: size).image { context in
            color.setFill()
            context.fill(CGRect(origin: .zero, size: size))
        }
    }
}

#Preview("Photo cells") {
    HStack(spacing: Theme.Spacing.s2) {
        PhotoCell(state: .loaded(.previewPlaceholder(.systemTeal)), order: 1)
        PhotoCell(state: .loading, order: 2)
        PhotoCell(state: .failed, order: 3)
    }
    .padding(Theme.Spacing.margin)
    .background(Theme.Colors.bg)
}
