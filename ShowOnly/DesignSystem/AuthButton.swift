import SwiftUI

extension BiometryKind {
    /// SF Symbols 글리프
    var glyphName: String {
        switch self {
        case .faceID: return "faceid"
        case .touchID: return "touchid"
        case .opticID: return "opticid"
        case .passcodeOnly: return "key"
        }
    }

    /// 문구에 들어가는 수단 이름. "~로", "~가", "~를" 모두 자연스럽게 붙는 형태입니다.
    var displayName: String {
        switch self {
        case .faceID: return "Face ID"
        case .touchID: return "Touch ID"
        case .opticID: return "Optic ID"
        case .passcodeOnly: return "기기 암호"
        }
    }
}

/// Button / Auth. 기기 인증 수단에 맞는 글리프 + 전달받은 라벨.
struct AuthButton: View {
    let kind: BiometryKind
    let title: String
    var theme: SOButtonTheme = .light
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: Theme.Spacing.s2) {
                Image(systemName: kind.glyphName)
                    .accessibilityHidden(true)
                Text(title)
            }
        }
        .buttonStyle(SOButtonStyle(kind: .primary, theme: theme))
        .accessibilityLabel(title)
    }
}

#Preview("Auth") {
    VStack(spacing: Theme.Spacing.s3) {
        AuthButton(kind: .faceID, title: "Face ID로 끝내기") {}
        AuthButton(kind: .touchID, title: "Touch ID로 끝내기") {}
        AuthButton(kind: .passcodeOnly, title: "기기 암호로 끝내기") {}
        AuthButton(kind: .faceID, title: "Face ID로 계속") {}.disabled(true)
        AuthButton(kind: .faceID, title: "Face ID로 다시 보기", theme: .lock) {}
            .padding(Theme.Spacing.s4)
            .background(Theme.Colors.lockBg)
    }
    .padding(Theme.Spacing.margin)
}
