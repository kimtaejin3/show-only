import SwiftUI

/// pen.dev `design/show-only.pen`의 변수와 1:1로 맞춘 디자인 토큰.
/// 화면 코드는 직접 색·크기를 쓰지 말고 이 토큰만 참조합니다.
enum Theme {
    enum Colors {
        static let bg = Color(hex: 0xF4F6F6)
        static let surface = Color(hex: 0xFFFFFF)
        static let primary = Color(hex: 0x0F7C6F)
        static let primaryPressed = Color(hex: 0x0B6359)
        static let onPrimary = Color(hex: 0xFFFFFF)
        static let accentSoft = Color(hex: 0xE3F2EF)
        static let accentSoftPressed = Color(hex: 0xD3EAE5)
        static let disabledFill = Color(hex: 0xC9D3D1)
        static let disabledSoftFill = Color(hex: 0xEEF1F0)
        static let disabledText = Color(hex: 0xA7B2B0)

        static let text = Color(hex: 0x111716)
        static let text2 = Color(hex: 0x5C6A68)
        static let text3 = Color(hex: 0x8A9694)
        static let separator = Color(hex: 0xE2E8E7)
        static let hairline = Color(hex: 0xD7DAD9)
        static let skeleton = Color(hex: 0xEEF1F0)

        static let warning = Color(hex: 0xAB6400)
        static let danger = Color(hex: 0xCE2C31)

        static let lockBg = Color(hex: 0x0B0F0F)
        static let lockSurface = Color(hex: 0x131919)
        static let lockHairline = Color(hex: 0x243030)
        static let lockText = Color(hex: 0xF1F5F4)
        static let lockText2 = Color(hex: 0x97A6A3)
        static let lockPrimary = Color(hex: 0x3CC7AE)
        static let lockOnPrimary = Color(hex: 0x04211C)
        static let lockDanger = Color(hex: 0xFF9592)

        static let viewerBg = Color.black
    }

    /// 시안의 IBM Plex Sans KR / Mono 대신 시스템 SF Pro / SF Mono를 씁니다.
    enum Fonts {
        static let largeTitle = Font.system(size: 32, weight: .bold)
        static let lockTitle = Font.system(size: 34, weight: .bold)
        static let title = Font.system(size: 22, weight: .bold)
        static let section = Font.system(size: 19, weight: .bold)
        static let body = Font.system(size: 16)
        static let bodyEmphasis = Font.system(size: 17, weight: .semibold)
        static let subhead = Font.system(size: 15)
        static let subheadEmphasis = Font.system(size: 15, weight: .semibold)
        static let caption = Font.system(size: 13)
        static let captionEmphasis = Font.system(size: 13, weight: .semibold)
        static let numeric = Font.system(size: 13, weight: .medium, design: .monospaced)
    }

    /// Large Title/Lock Title에 쓰는 자간 (-0.8 ~ -0.9).
    enum Tracking {
        static let largeTitle: CGFloat = -0.8
        static let title: CGFloat = -0.5
        static let section: CGFloat = -0.3
    }

    enum Spacing {
        static let s1: CGFloat = 4
        static let s2: CGFloat = 8
        static let s3: CGFloat = 12
        static let s4: CGFloat = 16
        static let s5: CGFloat = 24
        static let s6: CGFloat = 32
        static let margin: CGFloat = 20
        static let lockMargin: CGFloat = 24
    }

    enum Radius {
        static let sm: CGFloat = 10
        static let md: CGFloat = 14
        static let lg: CGFloat = 20
        static let banner: CGFloat = 12
    }

    enum Size {
        static let buttonHeight: CGFloat = 54
        static let textButtonHeight: CGFloat = 44
        static let thumbnailHeight: CGFloat = 150
    }
}

extension Color {
    init(hex: UInt32) {
        self.init(
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255
        )
    }
}
