import SwiftUI

enum BannerTone {
    case info
    case warning
    case error
}

/// Banner / Info·Warning·Error. 흰 표면 + 1px 헤어라인, 톤 색은 제목과 액션에만 씁니다.
/// `isDark`는 잠금 화면용 다크 변형입니다.
struct BannerView: View {
    let tone: BannerTone
    let title: String
    var message: String?
    var actionTitle: String?
    var isDark = false
    var action: (() -> Void)?

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.s1) {
            VStack(alignment: .leading, spacing: Theme.Spacing.s1) {
                Text(title)
                    .font(Theme.Fonts.subheadEmphasis)
                    .foregroundStyle(titleColor)
                if let message {
                    Text(message)
                        .font(Theme.Fonts.caption)
                        .foregroundStyle(isDark ? Theme.Colors.lockText2 : Theme.Colors.text2)
                        .lineSpacing(2)
                }
            }
            .fixedSize(horizontal: false, vertical: true)
            .accessibilityElement(children: .combine)

            if let actionTitle, let action {
                // 배너 높이를 키우지 않으면서 44pt 탭 영역을 확보
                Button(action: action) {
                    Text(actionTitle)
                        .font(Theme.Fonts.captionEmphasis)
                        .foregroundStyle(actionColor)
                        .frame(minHeight: Theme.Size.textButtonHeight, alignment: .leading)
                        .contentShape(Rectangle())
                }
                .padding(.vertical, -Theme.Spacing.s2)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, Theme.Spacing.s4)
        .padding(.vertical, Theme.Spacing.s4)
        .background(
            RoundedRectangle(cornerRadius: Theme.Radius.banner, style: .continuous)
                .fill(isDark ? Theme.Colors.lockSurface : Theme.Colors.surface)
        )
        .overlay(
            RoundedRectangle(cornerRadius: Theme.Radius.banner, style: .continuous)
                .strokeBorder(isDark ? Theme.Colors.lockHairline : Theme.Colors.hairline, lineWidth: 1)
        )
        .accessibilityElement(children: .contain)
    }

    private var titleColor: Color {
        switch tone {
        case .info: return isDark ? Theme.Colors.lockText : Theme.Colors.text
        case .warning: return Theme.Colors.warning
        case .error: return isDark ? Theme.Colors.lockDanger : Theme.Colors.danger
        }
    }

    private var actionColor: Color {
        switch tone {
        case .info: return isDark ? Theme.Colors.lockPrimary : Theme.Colors.primary
        case .warning: return Theme.Colors.warning
        case .error: return isDark ? Theme.Colors.lockDanger : Theme.Colors.danger
        }
    }
}

#Preview("Banners") {
    VStack(spacing: Theme.Spacing.s3) {
        BannerView(tone: .info, title: "이전 보여주기가 끝났어요", message: "앱이 다시 시작되면서 고른 사진을 비웠어요. 다시 골라주세요.")
        BannerView(tone: .warning, title: "1장을 불러오지 못했어요", message: "사진 원본을 가져오지 못했어요. 잠시 후 다시 시도해 주세요.", actionTitle: "다시 시도") {}
        BannerView(tone: .error, title: "기기 암호가 설정되어 있지 않아요", message: "보여주기를 끝낼 때 주인 확인이 필요해요. 기기 암호를 켜면 시작할 수 있어요.")
        BannerView(tone: .error, title: "인증하지 못했어요", message: "사진은 계속 가려둘게요. 다시 시도하거나 기기 암호를 사용해 주세요.", isDark: true)
            .padding(Theme.Spacing.s3)
            .background(Theme.Colors.lockBg)
    }
    .padding(Theme.Spacing.margin)
    .background(Theme.Colors.bg)
}
