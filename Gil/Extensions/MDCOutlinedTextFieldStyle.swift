//
//  MDCOutlinedTextFieldStyle.swift
//  Gil
//
//  Created by Antonio Banda  on 10/06/25.
//

import UIKit
import MaterialComponents

extension MDCOutlinedTextField {
    func applyValidStyle(color: UIColor = Constants.Colors.secondary!) {
        self.leadingAssistiveLabel.text = nil
        self.setOutlineColor(color, for: .normal)
        self.setOutlineColor(color, for: .editing)
        self.setFloatingLabelColor(color, for: .normal)
        self.setFloatingLabelColor(color, for: .editing)
        self.setNormalLabelColor(color, for: .normal)
    }
    
    func applyErrorStyle(errorMessage: String, color: UIColor = .red) {
        self.leadingAssistiveLabel.text = errorMessage
        self.setOutlineColor(color, for: .normal)
        self.setOutlineColor(color, for: .editing)
        self.setFloatingLabelColor(color, for: .normal)
        self.setFloatingLabelColor(color, for: .editing)
        self.setNormalLabelColor(color, for: .normal)
    }
}
