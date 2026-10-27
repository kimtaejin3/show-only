import SwiftUI

/// 뷰어 위에 올리는 종료 확인 시트. 시스템 alert 대신 디자인의 하단 시트를 씁니다.
/// 인증은 호출하는 쪽(HandoffViewer)이 실행하고, 이 뷰는 상태만 그립니다.
struct EndSessionSheet: View {
    let kind: BiometryKind
    /// 직전 인증이 실패·취소됐는지
    let didFail: Bool
    let isAuthenticating: Bool
    let onConfirm: () -> Void
    let onCancel: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("보여주기를 끝낼까요?")
                .font(Theme.Fonts.title)
                .tracking(Theme.Tracking.title)
                .foregroundStyle(Theme.Colors.text)
                .accessibilityAddTraits(.isHeader)

            Text("휴대폰 주인만 끝낼 수 있어요.\n끝내면 고른 사진도 앱에서 비워져요.")
                .font(Theme.Fonts.subhead)
                .foregroundStyle(Theme.Colors.text2)
                .lineSpacing(3)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.top, Theme.Spacing.s3)

            if didFail {
                BannerView(
                    tone: .error,
                    title: "주인 확인에 실패했어요",
                    message: "계속 보여주는 중이에요. 휴대폰 주인이 다시 시도해 주세요."
                )
                .padding(.top, Theme.Spacing.s5)
            }

            VStack(spacing: Theme.Spacing.s2) {
                AuthButton(
                    kind: kind,
                    title: didFail ? "\(kind.displayName) 다시 시도" : "\(kind.displayName)로 끝내기",
                    action: onConfirm
                )
                .disabled(isAuthenticating)

                Button("계속 보여주기", action: onCancel)
                    .buttonStyle(.soLink)
                    .disabled(isAuthenticating)
            }
            .padding(.top, Theme.Spacing.s6)
        }
        .padding(.horizontal, Theme.Spacing.s5)
        .padding(.top, Theme.Spacing.s6)
        .padding(.bottom, Theme.Spacing.s4)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: Theme.Radius.lg + Theme.Spacing.s2, style: .continuous)
                .fill(Theme.Colors.surface)
        )
        .padding(.horizontal, Theme.Spacing.s2)
        .padding(.bottom, Theme.Spacing.s2)
        .accessibilityElement(children: .contain)
        .accessibilityAddTraits(.isModal)
    }
}

#Preview("End sheet") {
    ZStack(alignment: .bottom) {
        Theme.Colors.viewerBg.ignoresSafeArea()
        EndSessionSheet(kind: .faceID, didFail: false, isAuthenticating: false, onConfirm: {}, onCancel: {})
    }
}

#Preview("End sheet · failed") {
    ZStack(alignment: .bottom) {
        Theme.Colors.viewerBg.ignoresSafeArea()
        EndSessionSheet(kind: .faceID, didFail: true, isAuthenticating: false, onConfirm: {}, onCancel: {})
    }
}
