//
//  AdMobBannerView.swift
//  LeaveNow
//

import SwiftUI
import UIKit
import GoogleMobileAds

/// Bottom-anchored adaptive banner. Use test ID in dev so ads always load; use real ID for release.
struct AdMobBannerView: View {
    var body: some View {
        // Use screen width for an anchored adaptive banner.
        let width = UIScreen.main.bounds.width
        let adSize = largeAnchoredAdaptiveBanner(width: width)
        BannerViewContainer(adSize)
            .frame(width: adSize.size.width, height: adSize.size.height)
    }
}

private struct BannerViewContainer: UIViewRepresentable {
    typealias UIViewType = BannerView
    let adSize: AdSize

    init(_ adSize: AdSize) {
        self.adSize = adSize
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    func makeUIView(context: Context) -> BannerView {
        let banner = BannerView(adSize: adSize)
        #if DEBUG
        // Google sample banner – always has fill so you can verify layout.
        banner.adUnitID = "ca-app-pub-3940256099942544/2934735716"
        #else
        banner.adUnitID = "ca-app-pub-6569136319623541/1697738087"
        #endif
        banner.delegate = context.coordinator
        banner.load(Request())
        return banner
    }

    func updateUIView(_ uiView: BannerView, context: Context) {}

    final class Coordinator: NSObject, BannerViewDelegate {
        func bannerViewDidReceiveAd(_ bannerView: BannerView) {
            #if DEBUG
            print("AdMob banner loaded.")
            #endif
        }

        func bannerView(_ bannerView: BannerView, didFailToReceiveAdWithError error: Error) {
            #if DEBUG
            print("AdMob banner failed to load: \(error.localizedDescription)")
            #endif
        }
    }
}

