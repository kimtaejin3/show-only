import SwiftUI

/// 버튼 종류. `link`는 "다시 고르기"처럼 포인트 색을 쓰는 텍스트 버튼입니다.
enum SOButtonKind {
    case primary
    case secondary
    case text
    case link
}

/// 밝은 화면(홈·가이드·종료 시트)과 잠금 화면(다크) 색 변형.
enum SOButtonTheme {
    case light
    case lock
}

/// 컴포넌트 보드의 Button / Primary·Secondary·Text (Default·Pressed·Disabled).
struct SOButtonStyle: ButtonStyle {
    var kind: SOButtonKind = .primary
    var theme: SOButtonTheme = .light

    func makeBody(configuration: Configuration) -> some View {
        SOButtonBody(configuration: configuration, kind: kind, theme: theme)
    }
}

private struct SOButtonBody: View {
    let configuration: ButtonStyleConfiguration
    let kind: SOButtonKind
    let theme: SOButtonTheme
    @Environment(\.isEnabled) private var isEnabled

    var body: some View {
        configuration.label
            .font(isFilled ? Theme.Fonts.bodyEmphasis : Theme.Fonts.subheadEmphasis)
            .foregroundStyle(foreground)
            .multilineTextAlignment(.center)
            .padding(.horizontal, Theme.Spacing.s4)
            .padding(.vertical, isFilled ? Theme.Spacing.s3 : Theme.Spacing.s2)
            .frame(maxWidth: isFilled ? .infinity : nil)
            .frame(minHeight: isFilled ? Theme.Size.buttonHeight : Theme.Size.textButtonHeight)
            .background {
                if isFilled {
                    RoundedRectangle(cornerRadius: Theme.Radius.md, style: .continuous)
                        .fill(background)
                }
            }
            .contentShape(Rectangle())
    }

    private var isFilled: Bool { kind == .primary || kind == .secondary }
    private var isPressed: Bool { configuration.isPressed }

    private var background: Color {
        switch (kind, theme) {
        case (.primary, .light):
            return isEnabled ? (isPressed ? Theme.Colors.primaryPressed : Theme.Colors.primary) : Theme.Colors.disabledFill
        case (.primary, .lock):
            return isEnabled ? Theme.Colors.lockPrimary.opacity(isPressed ? 0.8 : 1) : Theme.Colors.lockHairline
        case (.secondary, _):
            return isEnabled ? (isPressed ? Theme.Colors.accentSoftPressed : Theme.Colors.accentSoft) : Theme.Colors.disabledSoftFill
        default:
            return .clear
        }
    }

    private var foreground: Color {
        switch (kind, theme) {
        case (.primary, .light):
            return Theme.Colors.onPrimary
        case (.primary, .lock):
            return isEnabled ? Theme.Colors.lockOnPrimary : Theme.Colors.lockText2
        case (.secondary, _):
            return isEnabled ? Theme.Colors.primary : Theme.Colors.disabledText
        case (.text, .light):
            return isEnabled ? (isPressed ? Theme.Colors.text : Theme.Colors.text2) : Theme.Colors.disabledText
        case (.text, .lock):
            return isEnabled ? (isPressed ? Theme.Colors.lockText : Theme.Colors.lockText2) : Theme.Colors.lockHairline
        case (.link, .light):
            return isEnabled ? (isPressed ? Theme.Colors.primaryPressed : Theme.Colors.primary) : Theme.Colors.disabledText
        case (.link, .lock):
            return isEnabled ? Theme.Colors.lockPrimary.opacity(isPressed ? 0.8 : 1) : Theme.Colors.lockHairline
        }
    }
}

extension ButtonStyle where Self == SOButtonStyle {
    static var soPrimary: SOButtonStyle { SOButtonStyle(kind: .primary) }
    static var soSecondary: SOButtonStyle { SOButtonStyle(kind: .secondary) }
    static var soText: SOButtonStyle { SOButtonStyle(kind: .text) }
    static var soLink: SOButtonStyle { SOButtonStyle(kind: .link) }
    static func so(_ kind: SOButtonKind, theme: SOButtonTheme = .light) -> SOButtonStyle {
        SOButtonStyle(kind: kind, theme: theme)
    }
}

#Preview("Buttons") {
    VStack(spacing: Theme.Spacing.s3) {
        Button("사진 고르기") {}.buttonStyle(.soPrimary)
        Button("사진 고르기") {}.buttonStyle(.soPrimary).disabled(true)
        Button("설정 앱 열기") {}.buttonStyle(.soSecondary)
        Button("설정 앱 열기") {}.buttonStyle(.soSecondary).disabled(true)
        Button("알림·앱 이동 막는 법 보기") {}.buttonStyle(.soText)
        Button("다시 고르기") {}.buttonStyle(.soLink)
    }
    .padding(Theme.Spacing.margin)
    .background(Theme.Colors.bg)
}
