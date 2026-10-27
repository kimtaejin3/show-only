import SwiftUI
import UIKit

/// 알림·앱 이동 보호 가이드. 홈에서 내비게이션으로 들어오며 뒤로 버튼은 "홈"입니다.
struct ProtectionGuideView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                VStack(alignment: .leading, spacing: Theme.Spacing.s3) {
                    Text("건네기 전에\n두 가지만 켜두세요")
                        .font(Theme.Fonts.largeTitle)
                        .tracking(Theme.Tracking.largeTitle)
                        .foregroundStyle(Theme.Colors.text)
                        .fixedSize(horizontal: false, vertical: true)
                        .accessibilityAddTraits(.isHeader)
                    Text("둘 다 iOS 설정이라 이 앱이 대신 켤 수 없어요.\n한 번만 해두면 돼요.")
                        .font(Theme.Fonts.subhead)
                        .foregroundStyle(Theme.Colors.text2)
                        .lineSpacing(3)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.top, Theme.Spacing.s5)

                VStack(spacing: Theme.Spacing.s3) {
                    GuideSection(
                        kicker: "01 · 알림 숨기기",
                        title: "집중 모드",
                        steps: [
                            "설정 → 집중 모드 → + → 사용자 설정",
                            "알림을 허용할 사람과 앱을 모두 빼요",
                            "자동화 → 앱 → ‘딱 이 사진만’을 선택해요"
                        ],
                        limit: "카카오톡 같은 다른 앱 알림은 이 앱이 직접 막을 수 없어요. 긴급 알림처럼 예외로 뜨는 알림도 있어요."
                    )
                    GuideSection(
                        kicker: "02 · 앱 이동 막기",
                        title: "사용법 유도",
                        steps: [
                            "설정 → 손쉬운 사용 → 사용법 유도를 켜요",
                            "보여줄 때 전원 버튼(측면 버튼)을 세 번 눌러요",
                            "끝낼 때도 세 번 누르고 암호로 풀어요"
                        ],
                        limit: "사용법 유도 없이는 홈 화면으로 나가는 걸 막지 못해요. 대신 다시 들어오면 사진이 잠겨 있어요."
                    )
                }
                .padding(.top, Theme.Spacing.s6)
            }
            .padding(.horizontal, Theme.Spacing.margin)
            .padding(.bottom, Theme.Spacing.s5)
        }
        .background(Theme.Colors.bg.ignoresSafeArea())
        .safeAreaInset(edge: .bottom) {
            Button("설정 앱 열기", action: openSettings)
                .buttonStyle(.soSecondary)
                .accessibilityHint("이 앱의 설정 화면이 열려요. 집중 모드와 사용법 유도는 설정 첫 화면에서 찾아주세요.")
                .padding(.horizontal, Theme.Spacing.margin)
                .padding(.top, Theme.Spacing.s3)
                .padding(.bottom, Theme.Spacing.s2)
                .background(Theme.Colors.bg.ignoresSafeArea())
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Theme.Colors.bg, for: .navigationBar)
    }

    private func openSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
    }
}

private struct GuideSection: View {
    let kicker: String
    let title: String
    let steps: [String]
    let limit: String

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(kicker)
                .font(Theme.Fonts.captionEmphasis)
                .foregroundStyle(Theme.Colors.primary)
            Text(title)
                .font(Theme.Fonts.section)
                .tracking(Theme.Tracking.section)
                .foregroundStyle(Theme.Colors.text)
                .padding(.top, Theme.Spacing.s2)
                .accessibilityAddTraits(.isHeader)

            VStack(alignment: .leading, spacing: Theme.Spacing.s4) {
                ForEach(Array(steps.enumerated()), id: \.offset) { index, step in
                    GuideStep(number: index + 1, text: step)
                }
            }
            .padding(.top, Theme.Spacing.s5)

            Text(limit)
                .font(Theme.Fonts.caption)
                .foregroundStyle(Theme.Colors.text2)
                .lineSpacing(3)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.top, Theme.Spacing.s4)
                .overlay(alignment: .top) {
                    Rectangle()
                        .fill(Theme.Colors.separator)
                        .frame(height: 1)
                }
                .padding(.top, Theme.Spacing.s4)
        }
        .padding(Theme.Spacing.margin)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: Theme.Radius.lg, style: .continuous)
                .fill(Theme.Colors.surface)
        )
    }
}

#Preview("Guide") {
    NavigationStack {
        ProtectionGuideView()
    }
    .tint(Theme.Colors.primary)
}
