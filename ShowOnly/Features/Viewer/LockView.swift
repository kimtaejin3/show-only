import SwiftUI
import LocalAuthentication

/// 잠금 화면. 어떤 사진도, 사진의 흐림 처리도 그리지 않습니다.
struct LockView: View {
    @EnvironmentObject private var session: PhotoSessionStore
    @Environment(\.scenePhase) private var scenePhase
    @State private var status = AuthenticationService().status()
    @State private var didFail = false
    @State private var isAuthenticating = false

    private let authentication = AuthenticationService()

    var body: some View {
        LockContent(
            mode: LockMode(status: status),
            didFail: didFail,
            isAuthenticating: isAuthenticating,
            onAuthenticate: { Task { await authenticate() } }
        )
        .onAppear { status = authentication.status() }
        .onChange(of: scenePhase) { phase in
            if phase == .active {
                status = authentication.status()
            }
        }
    }

    @MainActor
    private func authenticate() async {
        guard !isAuthenticating else { return }
        isAuthenticating = true
        let outcome = await session.authenticateOwner { await authentication.authenticate(reason: "보여주던 사진을 다시 보려면 인증해 주세요.") }
        isAuthenticating = false
        status = authentication.status()
        switch outcome {
        case .success:
            didFail = false
            session.unlock()
        case .biometryLockedOut:
            // 잠김 상태 문구가 이미 이유를 설명하므로 실패 배너는 띄우지 않습니다.
            didFail = false
        case .cancelled, .failed, .notAvailable:
            didFail = true
        }
    }
}

/// 잠금 화면에 보여줄 상태.
enum LockMode: Equatable {
    /// 생체 인증 가능
    case biometric(BiometryKind)
    /// 생체 인증 시도 초과로 잠김 (이름은 하드웨어 기준)
    case biometryLocked(String)
    /// 생체 인증 하드웨어는 있지만 지금 쓸 수 없음
    case biometryUnavailable(String)
    /// 생체 인증이 없는 기기
    case passcodeOnly

    init(status: AuthStatus) {
        if status.isBiometryLockedOut {
            self = .biometryLocked(Self.hardwareName())
        } else if status.isBiometryUnavailable {
            self = .biometryUnavailable(Self.hardwareName())
        } else if status.kind == .passcodeOnly {
            self = .passcodeOnly
        } else {
            self = .biometric(status.kind)
        }
    }

    /// 생체 인증이 잠기면 AuthStatus.kind가 `.passcodeOnly`가 되므로 문구용 이름은 하드웨어에서 읽습니다.
    private static func hardwareName() -> String {
        let context = LAContext()
        _ = context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
        switch context.biometryType {
        case .faceID: return BiometryKind.faceID.displayName
        case .touchID: return BiometryKind.touchID.displayName
        case .opticID: return BiometryKind.opticID.displayName
        default: return "생체 인증"
        }
    }
}

private struct LockContent: View {
    let mode: LockMode
    let didFail: Bool
    let isAuthenticating: Bool
    let onAuthenticate: () -> Void

    var body: some View {
        ZStack {
            Theme.Colors.lockBg.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {
                Spacer(minLength: Theme.Spacing.s6)

                Text("화면이\n보호되고 있어요")
                    .font(Theme.Fonts.lockTitle)
                    .tracking(Theme.Tracking.largeTitle)
                    .foregroundStyle(Theme.Colors.lockText)
                    .fixedSize(horizontal: false, vertical: true)
                    .accessibilityAddTraits(.isHeader)

                Text(description)
                    .font(Theme.Fonts.subhead)
                    .foregroundStyle(Theme.Colors.lockText2)
                    .lineSpacing(4)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.top, Theme.Spacing.s4)

                if didFail {
                    BannerView(
                        tone: .error,
                        title: "인증하지 못했어요",
                        message: "사진은 계속 가려둘게요. 다시 시도하거나 기기 암호를 사용해 주세요.",
                        isDark: true
                    )
                    .padding(.top, Theme.Spacing.s5)
                }

                VStack(spacing: Theme.Spacing.s2) {
                    AuthButton(kind: buttonKind, title: buttonTitle, theme: .lock, action: onAuthenticate)
                        .disabled(isAuthenticating)

                    if case .biometric = mode {
                        // 기기 암호만 쓰는 별도 정책이 없어 같은 인증을 호출합니다. iOS가 암호 입력으로 이어줍니다.
                        Button("기기 암호 사용", action: onAuthenticate)
                            .buttonStyle(.so(.text, theme: .lock))
                            .disabled(isAuthenticating)
                    }
                }
                .padding(.top, Theme.Spacing.s6)
            }
            .padding(.horizontal, Theme.Spacing.lockMargin)
            .padding(.bottom, Theme.Spacing.s2)
        }
    }

    private var buttonKind: BiometryKind {
        if case .biometric(let kind) = mode { return kind }
        return .passcodeOnly
    }

    private var buttonTitle: String {
        if case .biometric(let kind) = mode {
            return didFail ? "\(kind.displayName) 다시 시도" : "\(kind.displayName)로 다시 보기"
        }
        return "기기 암호로 다시 보기"
    }

    private var description: String {
        switch mode {
        case .biometric, .passcodeOnly:
            return "다시 보려면 휴대폰 주인의 확인이 필요해요. 확인 전에는 사진을 보여주지 않아요."
        case .biometryLocked(let name):
            return "\(name) 시도 횟수를 넘었어요.\n기기 암호로 확인해 주세요."
        case .biometryUnavailable(let name):
            let object = name == "생체 인증" ? "생체 인증을" : "\(name)를"
            return "지금은 \(object) 쓸 수 없어요.\n기기 암호로 확인하면 다시 보여줘요."
        }
    }
}

#Preview("Lock") { LockContent(mode: .biometric(.faceID), didFail: false, isAuthenticating: false, onAuthenticate: {}) }
#Preview("Lock · failed") { LockContent(mode: .biometric(.faceID), didFail: true, isAuthenticating: false, onAuthenticate: {}) }
#Preview("Lock · biometry locked") { LockContent(mode: .biometryLocked("Face ID"), didFail: false, isAuthenticating: false, onAuthenticate: {}) }
#Preview("Lock · unavailable") { LockContent(mode: .biometryUnavailable("Face ID"), didFail: false, isAuthenticating: false, onAuthenticate: {}) }
#Preview("Lock · Touch ID") { LockContent(mode: .biometric(.touchID), didFail: false, isAuthenticating: false, onAuthenticate: {}) }
