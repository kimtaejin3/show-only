import SwiftUI

struct HandoffViewer: View {
    @EnvironmentObject private var session: PhotoSessionStore
    @State private var currentIndex = 0
    @State private var isAuthenticating = false
    @State private var feedback: String?

    private let authentication = AuthenticationService()

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            if session.isLocked {
                lockedView
            } else {
                TabView(selection: $currentIndex) {
                    ForEach(session.photos.indices, id: \.self) { index in
                        ZoomableImageView(image: session.photos[index])
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .ignoresSafeArea()

                VStack {
                    HStack {
                        Text("\(min(currentIndex + 1, session.photos.count)) / \(session.photos.count)")
                            .font(.subheadline.monospacedDigit())
                            .foregroundStyle(.white)
                        Spacer()
                        Button("보여주기 종료") {
                            Task { await authenticateToEnd() }
                        }
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .background(.black.opacity(0.55), in: Capsule())
                        .disabled(isAuthenticating)
                    }
                    .padding(.horizontal, 18)
                    .padding(.top, 8)
                    Spacer()
                }
            }
        }
        .statusBarHidden()
        .persistentSystemOverlays(.hidden)
        .alert("인증을 완료하지 못했어요", isPresented: Binding(
            get: { feedback != nil },
            set: { if !$0 { feedback = nil } }
        )) {
            Button("확인", role: .cancel) { feedback = nil }
        } message: {
            Text(feedback ?? "")
        }
    }

    private var lockedView: some View {
        VStack(spacing: 20) {
            Image(systemName: "lock.shield.fill")
                .font(.system(size: 54))
                .foregroundStyle(.white)
            Text("사진을 가려뒀어요")
                .font(.title2.bold())
                .foregroundStyle(.white)
            Text("소유자 인증 후 다시 볼 수 있어요.")
                .foregroundStyle(.white.opacity(0.75))
            Button {
                Task { await authenticateToResume() }
            } label: {
                Label("인증 후 계속", systemImage: "faceid")
                    .frame(maxWidth: 240)
            }
            .buttonStyle(.borderedProminent)
            .disabled(isAuthenticating)
        }
        .padding()
        .accessibilityElement(children: .contain)
    }

    @MainActor
    private func authenticateToResume() async {
        guard !isAuthenticating else { return }
        isAuthenticating = true
        let success = await authentication.authenticate(reason: "보여주던 사진을 다시 확인하려면 인증해 주세요.")
        isAuthenticating = false
        if success {
            session.unlock()
        } else {
            feedback = "인증이 취소되었거나 실패했어요. 사진은 계속 숨겨집니다."
        }
    }

    @MainActor
    private func authenticateToEnd() async {
        guard !isAuthenticating else { return }
        isAuthenticating = true
        let success = await authentication.authenticate(reason: "사진 보여주기를 종료하려면 인증해 주세요.")
        isAuthenticating = false
        if success {
            session.end()
        } else {
            feedback = "인증이 취소되었거나 실패했어요. 보여주기는 종료되지 않았습니다."
        }
    }
}
