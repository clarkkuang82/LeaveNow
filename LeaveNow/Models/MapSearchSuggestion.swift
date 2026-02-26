//
//  MapSearchSuggestion.swift
//  LeaveNow
//

import Foundation
import MapKit

/// Address/place suggestion from Apple MapKit (MKLocalSearchCompletion).
enum MapSearchSuggestion: Identifiable {
    case apple(MKLocalSearchCompletion)

    var id: String { "\(title)-\(subtitle)" }
    var title: String { if case .apple(let c) = self { return c.title }; return "" }
    var subtitle: String { if case .apple(let c) = self { return c.subtitle }; return "" }
}
