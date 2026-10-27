import SwiftUI

/// List / Fact. "01" 모노 번호 + 한 줄 설명, 아래 구분선.
struct FactRow: View {
    let index: Int
    let text: String
    /// 목록 첫 행이면 위쪽 구분선도 그립니다.
    var showsTopSeparator = false

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: Theme.Spacing.s4) {
            Text(String(format: "%02d", index))
                .font(Theme.Fonts.numeric)
                .foregroundStyle(Theme.Colors.primary)
                .accessibilityHidden(true)
            Text(text)
                .font(Theme.Fonts.subhead)
                .foregroundStyle(Theme.Colors.text)
                .fixedSize(horizontal: false, vertical: true)
            Spacer(minLength: 0)
        }
        .padding(.vertical, Theme.Spacing.s4)
        .overlay(alignment: .top) {
            if showsTopSeparator { separator }
        }
        .overlay(alignment: .bottom) { separator }
        .accessibilityElement(children: .combine)
    }

    private var separator: some View {
        Rectangle()
            .fill(Theme.Colors.separator)
            .frame(height: 1)
    }
}

/// List / Step. 가이드의 번호 단계.
struct GuideStep: View {
    let number: Int
    let text: String

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: Theme.Spacing.s3) {
            Text("\(number)")
                .font(Theme.Fonts.numeric)
                .foregroundStyle(Theme.Colors.text3)
                .frame(minWidth: Theme.Spacing.s3, alignment: .leading)
            Text(text)
                .font(Theme.Fonts.subhead)
                .foregroundStyle(Theme.Colors.text)
                .fixedSize(horizontal: false, vertical: true)
            Spacer(minLength: 0)
        }
        .accessibilityElement(children: .combine)
    }
}

/// Viewer / Page Counter. 사진 위에 얹는 "2 / 3".
struct PageCounter: View {
    let current: Int
    let total: Int

    var body: some View {
        Text("\(current) / \(total)")
            .font(Theme.Fonts.numeric)
            .foregroundStyle(Theme.Colors.lockText)
            .padding(.horizontal, Theme.Spacing.s3)
            .padding(.vertical, Theme.Spacing.s2)
            .background(Capsule().fill(Theme.Colors.lockText.opacity(0.14)))
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("\(total)장 중 \(current)번째 사진")
    }
}

#Preview("List rows") {
    VStack(alignment: .leading, spacing: Theme.Spacing.s5) {
        VStack(spacing: 0) {
            FactRow(index: 1, text: "고른 사진 말고는 불러오지 않아요", showsTopSeparator: true)
            FactRow(index: 2, text: "앱을 나갔다 오면 사진을 가리고 잠가요")
        }
        GuideStep(number: 1, text: "설정 → 집중 모드 → + → 사용자 설정")
        PageCounter(current: 2, total: 3)
            .padding(Theme.Spacing.s3)
            .background(Theme.Colors.viewerBg)
    }
    .padding(Theme.Spacing.margin)
    .background(Theme.Colors.bg)
}
