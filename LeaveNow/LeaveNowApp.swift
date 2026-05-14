//
//  LeaveNowApp.swift
//  LeaveNow
//
//  Created by Clark Kuang on 2/24/26.
//

import SwiftUI
import UIKit

@main
struct LeaveNowApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    init() {
        MonitorService.registerBackgroundTask()
        configureAppearance()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .tint(DS.accent)
                .task {
                    MonitorService.shared.restoreIfNeeded()
                }
        }
    }

    /// Navigation bar — serif italic large title, rice-paper background, hairline shadow.
    private func configureAppearance() {
        let ink = UIColor(DS.ink)
        let paper = UIColor(DS.bg)

        let nav = UINavigationBarAppearance()
        nav.configureWithOpaqueBackground()
        nav.backgroundColor = paper
        nav.shadowColor = UIColor(DS.hairline)

        if let serif = UIFontDescriptor
            .preferredFontDescriptor(withTextStyle: .largeTitle)
            .withDesign(.serif) {
            nav.largeTitleTextAttributes = [
                .font: UIFont(descriptor: serif, size: 32),
                .foregroundColor: ink,
            ]
        }
        if let smallSerif = UIFontDescriptor
            .preferredFontDescriptor(withTextStyle: .headline)
            .withDesign(.serif) {
            nav.titleTextAttributes = [
                .font: UIFont(descriptor: smallSerif, size: 17),
                .foregroundColor: ink,
            ]
        }

        UINavigationBar.appearance().standardAppearance = nav
        UINavigationBar.appearance().scrollEdgeAppearance = nav
        UINavigationBar.appearance().compactAppearance = nav
    }
}

private extension UIFont {
    func withTraits(_ traits: UIFontDescriptor.SymbolicTraits) -> UIFont? {
        guard let descriptor = fontDescriptor.withSymbolicTraits(traits) else { return nil }
        return UIFont(descriptor: descriptor, size: 0)
    }
}
