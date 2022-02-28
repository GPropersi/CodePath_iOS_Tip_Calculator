//
//  extensions.swift
//  Tip Calc 3000
//
//  Created by Giovanni Propersi on 1/30/22.
//  Smaller extensions for other types/classes, Decimal, UINavigationController, UISlider, UILabel, UITextField

import UIKit

// MARK: - Standard Extensions
extension Decimal {
    // Extension to convert decimal to string with a max of 2 decimal places
    var formattedAmount: String? {
        let formatter = NumberFormatter()
        formatter.generatesDecimalNumbers = true
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        return formatter.string(from: self as NSDecimalNumber)
    }
}

// MARK: - UINavigation Controller Extension, for dark or light mode
extension UINavigationController {
    func setDarkOrLightNavigationMode(darkOrLight chosenViewMode: String) {
        switch chosenViewMode {
        case "Dark":
            self.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
            self.navigationBar.backgroundColor = UIColor.black
            let standard = self.navigationBar.standardAppearance
            self.navigationBar.scrollEdgeAppearance = standard
            
        default:
            self.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black]
            self.navigationBar.backgroundColor = UIColor.darkGray
            let standard = self.navigationBar.standardAppearance
            self.navigationBar.scrollEdgeAppearance = standard
        }
    }
}

// MARK: - UISlider Extensions, for calculating max and selected slider values
extension UISlider {
    func setTipSliderMaxAndSelectedValues (defaultMax: Int, selectedTip: Int) {
        self.maximumValue = Float(defaultMax) / 100.0
        self.value = Float(selectedTip) / 100.0
    }
}

// MARK: - UILabel Extensions, for setting the tip percentage
extension UILabel {
    func setTipPercentOutput(_ tipForLabel: Int) {
        // Set the tip percent label based on user preferred value, or default value
        self.text = String(format: "%2i%%", tipForLabel)
    }
}

// MARK: - UITextField Extensions, for setting errors around settings text inputs
extension UITextField {
    func addErrorOutlineAndColor() {
        self.layer.borderColor = UIColor.red.cgColor
        self.layer.borderWidth = 2.0
    }
    
    func removeErrorOutlineAndColor() {
        self.layer.borderWidth = 0            // Clear error border
    }
}
