//
//  BorderedStackView.swift
//  chatgpt-ios
//
//  Created by Spiros Raptis on 3/25/23.
//

import Foundation
import UIKit

class BorderedStackView: UIStackView {
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.borderWidth = 1
        layer.borderColor = UIColor.gray.cgColor
    }
}
