//
//  Animals.swift
//  SoundClassification
//
//  Created by Shailesh Patel on 30/12/2020.
//

import Foundation
import UIKit

enum Animal: String, CaseIterable {
    case dog, pig, cow, frog, cat, insects, sheep, crow, chicken
    
    init?(rawValue: String) {
        if let match = Self.allCases.first(where: { $0.rawValue == rawValue }) {
            self = match
        } else if rawValue == "rooster" || rawValue == "hen" {
            self = .chicken
        } else {
            return nil
        }
    }
    
    var icon: String {
        switch self {
        case .dog: return "🐶"
        case .pig: return "🐷"
        case .cow: return "🐮"
        case .frog: return "🐸"
        case .cat: return "🐱"
        case .insects: return "🐝"
        case .sheep: return "🐑"
        case .crow: return "🐦"
        case .chicken: return "🐔"
        }
    }
    
    var color: UIColor {
        switch self {
        case .dog: return .systemRed
        case .pig: return .systemBlue
        case .cow: return .systemOrange
        case .frog: return .systemYellow
        case .cat: return .systemTeal
        case .insects: return .systemPink
        case .sheep: return .systemPurple
        case .crow: return .systemGreen
        case .chicken: return .systemIndigo
        }
    }
}
