//
//  DesignSystem.swift
//  LeaveNow
//
//  Refined Biomech Literati — Clark's design tokens
//

import SwiftUI

enum DS {
    // MARK: - Colors (白瓷 Porcelain theme)

    /// 朱砂 cinnabar — the seal red, the brand's only accent
    static let accent = Color(red: 0x8E / 255, green: 0x2A / 255, blue: 0x1E / 255)
    static let accentHi = Color(red: 0xA3 / 255, green: 0x33 / 255, blue: 0x23 / 255)
    static let accentLo = Color(red: 0x6E / 255, green: 0x1F / 255, blue: 0x14 / 255)

    /// Sandgold parchment — primary background
    static let bg = Color(red: 0xE9 / 255, green: 0xDF / 255, blue: 0xC8 / 255)
    static let bgSecondary = Color(red: 0xED / 255, green: 0xE7 / 255, blue: 0xDB / 255)
    static let bgSunk = Color(red: 0xE5 / 255, green: 0xDE / 255, blue: 0xCF / 255)

    /// ink — primary foreground
    static let ink = Color(red: 0x1A / 255, green: 0x16 / 255, blue: 0x14 / 255)
    static let inkFaded = Color(red: 0x5C / 255, green: 0x54 / 255, blue: 0x4B / 255)
    static let inkLight = Color(red: 0x96 / 255, green: 0x8B / 255, blue: 0x7D / 255)
    static let inkHint = Color(red: 0xC0 / 255, green: 0xB7 / 255, blue: 0xA6 / 255)

    /// hairlines
    static let hairline = Color(red: 0xC9 / 255, green: 0xC1 / 255, blue: 0xB3 / 255)
    static let hairlineSoft = Color(red: 0xDD / 255, green: 0xD5 / 255, blue: 0xC4 / 255)

    /// 控制玉 — antique gold medal (used at most once per screen)
    static let medal = Color(red: 0xC9 / 255, green: 0xA9 / 255, blue: 0x61 / 255)

    // MARK: - Status semantic

    static let ok = Color(red: 0x4A / 255, green: 0x6B / 255, blue: 0x3E / 255)
    static let warn = medal

    // MARK: - Fonts

    /// Display headlines — system new-style serif
    static func display(_ size: CGFloat, weight: Font.Weight = .medium) -> Font {
        .system(size: size, weight: weight, design: .serif)
    }

    /// Italic display (numerals, hero numbers)
    static func displayItalic(_ size: CGFloat, weight: Font.Weight = .medium) -> Font {
        .system(size: size, weight: weight, design: .serif).italic()
    }

    /// Body text — system serif
    static func body(_ size: CGFloat = 16, weight: Font.Weight = .regular) -> Font {
        .system(size: size, weight: weight, design: .serif)
    }

    /// Eyebrow / caption — monospaced, uppercase-friendly
    static func mono(_ size: CGFloat = 11, weight: Font.Weight = .medium) -> Font {
        .system(size: size, weight: weight, design: .monospaced)
    }

    // MARK: - Radii — system commits to sharp

    static let radius: CGFloat = 2
    static let radiusMd: CGFloat = 4

    // MARK: - Hairline thickness

    static let hair: CGFloat = 0.5
}

// MARK: - View modifiers

extension View {
    /// Apply the brand's hairline divider at the bottom of a view
    func hairlineDivider() -> some View {
        overlay(alignment: .bottom) {
            Rectangle()
                .fill(DS.hairline)
                .frame(height: DS.hair)
        }
    }
}

// MARK: - Seal (印章) ornament

/// A small cinnabar seal stamp with a single character. Used as a brand accent.
/// Uses the SealOut image asset to match the app icon.
struct SealMark: View {
    var character: String = "出"
    var size: CGFloat = 28

    var body: some View {
        Image("SealOut")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: size, height: size)
            .clipShape(RoundedRectangle(cornerRadius: size * 0.18, style: .continuous))
            .accessibilityHidden(true)
    }
}

// MARK: - Eyebrow label

/// Mono, uppercase, tracked label used as section eyebrow.
struct Eyebrow: View {
    let text: String
    var body: some View {
        Text(text.uppercased())
            .font(DS.mono(11, weight: .medium))
            .tracking(2.0)
            .foregroundStyle(DS.inkFaded)
    }
}
