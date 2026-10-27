import SwiftUI
import UIKit

struct HandoffViewer: View {
    @EnvironmentObject private var session: PhotoSessionStore
    @State private var currentIndex = 0
    @State private var showsEndSheet = false
    @State private var endAuthFailed = false
    @State private var isAuthenticating = false
    @State private var kind = AuthenticationService().status().kind

    private let authentication = AuthenticationService()

    var body: some View {
        ZStack {
            Theme.Colors.viewerBg.ignoresSafeArea()

            // 잠금 중에는 사진 뷰 자체를 계층에서 내립니다.
            if session.isLocked {
                LockView()
            } else {
                ViewerContent(
                    photos: session.photos,
                    currentIndex: $currentIndex,
                    kind: kind,
                    showsEndSheet: showsEndSheet,
                    endAuthFailed: endAuthFailed,
                    isAuthenticating: isAuthenticating,
                    onEndTapped: {
                        kind = authentication.status().kind
                        endAuthFailed = false
                        withAnimation(.easeOut(duration: 0.2)) { showsEndSheet = true }
                    },
                    onConfirmEnd: { Task { await authenticateToEnd() } },
                    onCancelEnd: {
                        withAnimation(.easeOut(duration: 0.2)) { showsEndSheet = false }
                        endAuthFailed = false
                    }
                )
            }
        }
        .preferredColorScheme(.dark)
        .persistentSystemOverlays(.hidden)
    }

    @MainActor
    private func authenticateToEnd() async {
        guard !isAuthenticating else { return }
        isAuthenticating = true
        let outcome = await session.authenticateOwner { await authentication.authenticate(reason: "사진 보여주기를 끝내려면 인증해 주세요.") }
        isAuthenticating = false
        if outcome == .success {
            showsEndSheet = false
            session.end()
        } else {
            kind = authentication.status().kind
            endAuthFailed = true
        }
    }
}

/// 뷰어 화면 본문. 세션 없이도 미리보기할 수 있게 값만 받습니다.
private struct ViewerContent: View {
    let photos: [UIImage]
    @Binding var currentIndex: Int
    let kind: BiometryKind
    let showsEndSheet: Bool
    let endAuthFailed: Bool
    let isAuthenticating: Bool
    let onEndTapped: () -> Void
    let onConfirmEnd: () -> Void
    let onCancelEnd: () -> Void

    var body: some View {
        ZStack {
            TabView(selection: $currentIndex) {
                ForEach(photos.indices, id: \.self) { index in
                    ZoomableImageView(image: photos[index])
                        .tag(index)
                        .accessibilityLabel("\(photos.count)장 중 \(index + 1)번째 사진")
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .ignoresSafeArea()

            if !showsEndSheet {
                chrome
            }

            if showsEndSheet {
                Theme.Colors.viewerBg.opacity(0.55)
                    .ignoresSafeArea()
                    .onTapGesture { if !isAuthenticating { onCancelEnd() } }
                    .accessibilityHidden(true)
                    .transition(.opacity)

                VStack {
                    Spacer()
                    EndSessionSheet(
                        kind: kind,
                        didFail: endAuthFailed,
                        isAuthenticating: isAuthenticating,
                        onConfirm: onConfirmEnd,
                        onCancel: onCancelEnd
                    )
                }
                .transition(.move(edge: .bottom))
            }
        }
    }

    private var chrome: some View {
        VStack(spacing: 0) {
            HStack {
                PageCounter(current: min(currentIndex + 1, photos.count), total: photos.count)
                Spacer()
                Button(action: onEndTapped) {
                    HStack(spacing: Theme.Spacing.s1) {
                        Image(systemName: kind.glyphName)
                            .accessibilityHidden(true)
                        Text("끝내기")
                    }
                    .font(Theme.Fonts.subhead)
                    .foregroundStyle(Theme.Colors.lockText2)
                    .padding(.horizontal, Theme.Spacing.s2)
                    .frame(minHeight: Theme.Size.textButtonHeight)
                    .contentShape(Rectangle())
                }
                .padding(.trailing, -Theme.Spacing.s2)
                .accessibilityLabel("보여주기 끝내기")
                .accessibilityHint("휴대폰 주인의 \(kind.displayName) 확인이 필요해요")
            }
            .padding(.horizontal, Theme.Spacing.margin)
            .padding(.top, Theme.Spacing.s2)

            Spacer()

            Text(hint)
                .font(Theme.Fonts.caption)
                .foregroundStyle(Theme.Colors.lockText2)
                .multilineTextAlignment(.center)
                .padding(.horizontal, Theme.Spacing.margin)
                .padding(.bottom, Theme.Spacing.s5)
        }
    }

    private var hint: String {
        if photos.count <= 1 { return "두 번 탭하면 확대돼요" }
        if currentIndex >= photos.count - 1 { return "마지막 사진이에요" }
        return "좌우로 넘겨보세요 · 두 번 탭하면 확대돼요"
    }
}

private struct ViewerPreview: View {
    let count: Int
    @State var index: Int
    var showsSheet = false
    var failed = false

    var body: some View {
        ZStack {
            Theme.Colors.viewerBg.ignoresSafeArea()
            ViewerContent(
                photos: (0..<count).map { _ in .previewPlaceholder(.systemBrown, size: CGSize(width: 400, height: 500)) },
                currentIndex: $index,
                kind: .faceID,
                showsEndSheet: showsSheet,
                endAuthFailed: failed,
                isAuthenticating: false,
                onEndTapped: {}, onConfirmEnd: {}, onCancelEnd: {}
            )
        }
        .preferredColorScheme(.dark)
    }
}

#Preview("Viewer") { ViewerPreview(count: 3, index: 1) }
#Preview("Single photo") { ViewerPreview(count: 1, index: 0) }
#Preview("Last photo") { ViewerPreview(count: 3, index: 2) }
#Preview("End sheet") { ViewerPreview(count: 3, index: 1, showsSheet: true) }
#Preview("End auth failed") { ViewerPreview(count: 3, index: 1, showsSheet: true, failed: true) }
