import SwiftUI

struct ProtectionGuideView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    guideSection(
                        icon: "bell.slash.fill",
                        title: "카카오톡 알림 숨기기",
                        subtitle: "iOS 집중 모드 · 사용자가 직접 설정",
                        steps: [
                            "설정 > 집중 모드에서 새로운 집중 모드를 만드세요.",
                            "알림 허용 설정에서 카카오톡 등 민감한 알림을 제한하세요.",
                            "일정 추가(또는 자동으로 켜기)에서 이 앱을 선택하세요.",
                            "보여주기 전에 알림 예외가 없는지 확인하세요."
                        ],
                        caution: "앱이 집중 모드를 직접 켜거나 카톡 알림을 강제로 차단할 수는 없어요. 긴급 알림 등 예외가 있을 수 있어요."
                    )
                    guideSection(
                        icon: "iphone.gen3.radiowaves.left.and.right",
                        title: "다른 앱으로 이동 못 하게 하기",
                        subtitle: "iOS 사용법 유도 · 선택 설정",
                        steps: [
                            "설정 > 손쉬운 사용 > 사용법 유도를 켜고 인증 수단을 설정하세요.",
                            "사진 보여주기 화면에서 측면 버튼을 세 번 누르세요.",
                            "사용법 유도를 시작한 다음 상대에게 휴대폰을 건네세요.",
                            "종료할 때도 iOS 안내에 따라 인증하세요."
                        ],
                        caution: "앱 안의 종료 인증만으로 홈 스와이프를 막을 수는 없어요. 사용법 유도는 iOS에서 사용자가 직접 시작해야 해요."
                    )
                }
                .padding(20)
            }
            .navigationTitle("보호 설정 안내")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("닫기") { dismiss() }
                }
            }
        }
    }

    private func guideSection(icon: String, title: String, subtitle: String, steps: [String], caution: String) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Label(title, systemImage: icon)
                .font(.headline)
            Text(subtitle)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            ForEach(Array(steps.enumerated()), id: \.offset) { index, step in
                HStack(alignment: .top, spacing: 8) {
                    Text("\(index + 1).")
                        .fontWeight(.bold)
                    Text(step)
                }
                .font(.subheadline)
            }
            Text(caution)
                .font(.caption)
                .foregroundStyle(.secondary)
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 12))
        }
    }
}
