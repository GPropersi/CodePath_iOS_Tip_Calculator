//
//  extensionsUIViewAnimations.swift
//  Tip Calc 3000
//
//  Created by Giovanni Propersi on 1/30/22.
//  Extensions for the UIView that account for animations - fading in and out, and sliding in and out, as well as
//      causing dark mode or light mode transitions.

import UIKit

// MARK: - UIView Extensions, animation related, dark/light view related
extension UIView {
    
    func fadeIn() {
        // Fade in
        self.layoutIfNeeded()
        UIView.animate(withDuration: 0.4, delay: 0.0, animations: {
            self.alpha = 1
            self.layoutIfNeeded()
        }, completion: nil)
    }
    
    func fadeOut() {
        // Fade Out
        self.layoutIfNeeded()
        UIView.animate(withDuration: 0.3, delay: 0.0, animations: {
            self.alpha = 0
            self.layoutIfNeeded()
        }, completion: nil)
    }
    
    func resetLayoutMargins(leftConstraint: NSLayoutConstraint, rightConstraint: NSLayoutConstraint, originalMargins: [CGFloat]) {
        // Reset the layout to its original margins

        leftConstraint.constant = originalMargins[0]
        rightConstraint.constant = originalMargins[1]
        self.layoutIfNeeded()
    }
    
    func slideInFromRightBorder(leftConstraint: NSLayoutConstraint, rightConstraint: NSLayoutConstraint) {
        // Left constraint defined against left border, right constraint defined against right border.
        // Subtracting view width to left constraint sends it to left, and adding to right constraint sends it to left
        self.layoutIfNeeded()
        UIView.animate(withDuration: 0.4, delay: 0.0, options: [], animations: {
            leftConstraint.constant -= self.bounds.width
            self.layoutIfNeeded()
        }, completion: nil)
        
        self.layoutIfNeeded()
        UIView.animate(withDuration: 0.4, delay: 0.0, options: [], animations: {
            rightConstraint.constant += self.bounds.width
            self.layoutIfNeeded()
        }, completion: nil)
    }
    
    func slideInFromRightAndHidePrompt(prompt: UILabel, leftConstraint: NSLayoutConstraint, rightConstraint: NSLayoutConstraint) {
        // Slides in everything from right as user begins typing in bill
        prompt.fadeOut()
        self.slideInFromRightBorder(leftConstraint: leftConstraint, rightConstraint: rightConstraint)
    }
    
    func hideEverythingBelowBill(leftConstraint: NSLayoutConstraint, rightConstrant: NSLayoutConstraint)
    {
        // Hide everything not needed when first opening or after 10 minutes
        // Hides by moving the left and right constraints all labels are fixed to, to the right.
        // Subtracting view width to left constraint sends it to left, and adding to right constraint sends it to left
        
        leftConstraint.constant += self.bounds.width
        rightConstrant.constant -= self.bounds.width
        
        self.layoutIfNeeded()
        
    }
    
    func setDarkOrLightViewModeForTipCalculatorScreen(darkOrLight chosenViewMode: String, billTextField: UITextField, textOutputLabels: [UILabel]) {
        // Sets the view to chosen dark/light mode, and alters text to match the mode. Default is Light mode
        overrideUserInterfaceStyle = Constants.Storyboard.viewMode[chosenViewMode]!
        
        switch chosenViewMode {
        case "Dark":
            for labelColor in textOutputLabels {
                labelColor.textColor = Constants.Storyboard.textColorDarkMode
            }
            billTextField.textColor = Constants.Storyboard.textColorDarkMode
            
        default:
            for labelColor in textOutputLabels {
                labelColor.textColor = Constants.Storyboard.textColorLightMode
            }
            billTextField.textColor = Constants.Storyboard.textColorLightMode
        }
    }
    
    func setDarkOrLightViewModeForSettingsScreen(darkOrLight: String, textInputFields: [UITextField], darkModeToggle: UISwitch) {
        
        switch darkOrLight {
        case "Dark" :
            darkModeToggle.setOn(true, animated: true)
            overrideUserInterfaceStyle = Constants.Storyboard.viewMode[darkOrLight]!
            
            for inputField in textInputFields {
                inputField.backgroundColor = UIColor.systemGray2
            }
            
        default :
            darkModeToggle.setOn(false, animated: true)
            overrideUserInterfaceStyle = Constants.Storyboard.viewMode[darkOrLight]!
            
            for inputField in textInputFields {
                inputField.backgroundColor = UIColor.systemBackground
            }
        }
    }
}
