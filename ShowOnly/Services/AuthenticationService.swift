import Foundation
import LocalAuthentication

/// 기기가 지원하는 주인 확인 수단. UI는 이 값으로 글리프·문구를 고릅니다.
enum BiometryKind: Equatable {
    case faceID
    case touchID
    case opticID
    /// 생체 인증 없이 기기 암호만 가능
    case passcodeOnly
}

/// 지금 이 기기에서 주인 확인이 가능한지.
struct AuthStatus: Equatable {
    /// 기기 암호 또는 생체 인증 중 하나라도 가능하면 true. false면 보여주기를 시작할 수 없음.
    var canAuthenticate: Bool
    /// 버튼에 보여줄 수단. 생체 인증이 잠겼거나 쓸 수 없으면 `.passcodeOnly`.
    var kind: BiometryKind
    /// 생체 인증 시도 초과로 iOS가 잠근 상태
    var isBiometryLockedOut: Bool
    /// 생체 인증 하드웨어는 있지만 지금 쓸 수 없음(미등록 등)
    var isBiometryUnavailable: Bool
}

/// 인증 결과. UI는 실패 종류에 따라 잠금 화면 상태를 바꿉니다.
enum AuthOutcome: Equatable {
    case success
    /// 사용자가 취소
    case cancelled
    /// 인증 실패(얼굴 불일치 등)
    case failed
    /// 생체 인증 잠김 → 기기 암호로만 가능
    case biometryLockedOut
    /// 기기에 암호가 없어 인증 자체가 불가
    case notAvailable
}

struct AuthenticationService {
    func status() -> AuthStatus {
        let context = LAContext()
        var ownerError: NSError?
        let canOwner = context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &ownerError)

        var bioError: NSError?
        let canBio = context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &bioError)
        let bioCode = bioError.flatMap { LAError.Code(rawValue: $0.code) }
        // biometryType은 canEvaluatePolicy 호출 뒤에야 채워지며, 잠김·미등록이어도 하드웨어 종류를 알려줍니다.
        let hasHardware = context.biometryType != .none
        let lockedOut = canOwner && bioCode == .biometryLockout

        let kind: BiometryKind
        if canBio {
            switch context.biometryType {
            case .faceID: kind = .faceID
            case .touchID: kind = .touchID
            case .opticID: kind = .opticID
            default: kind = .passcodeOnly
            }
        } else {
            kind = .passcodeOnly
        }

        return AuthStatus(
            canAuthenticate: canOwner,
            kind: kind,
            isBiometryLockedOut: lockedOut,
            isBiometryUnavailable: canOwner && !canBio && !lockedOut && hasHardware
        )
    }

    func canAuthenticate() -> Bool { status().canAuthenticate }

    /// 생체 인증이 가능하면 생체 인증을, 아니면(잠김·미등록·실패 후 대체) 기기 암호를 사용합니다.
    func authenticate(reason: String) async -> AuthOutcome {
        let context = LAContext()
        var error: NSError?
        guard context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) else {
            return .notAvailable
        }

        let gate = ResumeGate()
        return await withTaskCancellationHandler {
            await withCheckedContinuation { (continuation: CheckedContinuation<AuthOutcome, Never>) in
                // 응답 클로저는 LocalAuthentication의 비공개 큐에서 불립니다. 한 번만 resume합니다.
                context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason) { success, error in
                    let outcome = success ? AuthOutcome.success : Self.outcome(for: error)
                    if gate.claim() {
                        continuation.resume(returning: outcome)
                    }
                }
            }
        } onCancel: {
            // 작업이 취소되면 인증 시트를 닫습니다. 응답은 위 클로저에 .appCancel로 한 번 옵니다.
            context.invalidate()
        }
    }

    private static func outcome(for error: Error?) -> AuthOutcome {
        guard let error, let code = LAError.Code(rawValue: (error as NSError).code),
              (error as NSError).domain == LAErrorDomain else {
            return .failed
        }
        switch code {
        case .userCancel, .appCancel, .systemCancel, .notInteractive:
            return .cancelled
        case .userFallback:
            // deviceOwnerAuthentication에선 대체 버튼이 곧 암호 입력이라 보통 오지 않음. 오면 취소로 취급
            return .cancelled
        case .authenticationFailed:
            return .failed
        case .biometryLockout:
            return .biometryLockedOut
        case .passcodeNotSet:
            return .notAvailable
        default:
            return .failed
        }
    }
}

/// continuation 중복 resume 방지용 원자적 플래그
private final class ResumeGate: @unchecked Sendable {
    private let lock = NSLock()
    private var claimed = false

    func claim() -> Bool {
        lock.lock()
        defer { lock.unlock() }
        if claimed { return false }
        claimed = true
        return true
    }
}
