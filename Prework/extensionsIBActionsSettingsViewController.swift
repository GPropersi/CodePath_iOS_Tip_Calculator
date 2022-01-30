//
//  extensionsSettingsViewController.swift
//  Tip Calc 3000
//
//  Created by Giovanni Propersi on 1/30/22.
//  Extension for SettingsViewController that includes all IBActions.

import UIKit

// MARK: - IBAction, SettingsViewController
extension SettingsViewController {
    @IBAction func defaultTipEndedEditing(_ sender: UITextField) {
        // When ending editing for the default tip textbox, add % to the
        // textfields. Run comparisons to verify valid input for default tip percentages.
        // https://developer.apple.com/documentation/uikit/uitextfielddelegate/1619591-textfielddidendediting
        // Border editing - https://stackoverflow.com/questions/53682936/how-to-change-uitextfield-border-when-selected/53683159
        
        // Pull current valid inputs of default tip and max tip for comparison
        let currentTipDefault = defaults.string(forKey: Constants.Storyboard.userDefinedTip) ?? "25"
        let currentTipMax = defaults.string(forKey: Constants.Storyboard.userDefinedMax) ?? "50"
        
        var defaultTipTextInput : String = defaultTip.text!
        
        guard defaultTipTextInput != "" else {
            // Text is empty, replace with default on exit
            defaultTip.text = currentTipDefault + "%"
            return
        }
        
        defaultTipTextInput = defaultTipTextInput.replacingOccurrences(of: "%", with: "")
        
        let defaultTipTextInputInteger = Int(defaultTipTextInput)!
        
        if defaultTipTextInputInteger > Int(currentTipMax)! {
            // Tip default can't be greater than tip max
            defaultTip.addErrorOutlineAndColor()
            defaultTipError.text = "Default tip greater than max."
            defaultTip.text = currentTipDefault + "%"
            return
        }
        else if defaultTipTextInputInteger < 0 {
            // User input tip percent cannot be below 0
            defaultTip.addErrorOutlineAndColor()
            defaultTipError.text = "Default tip cannot be less than 0%."
            defaultTip.text = currentTipDefault + "%"
            return
        }
        else {
            // User input for default tip is valid, store in UserDefaults, display
            defaultTip.removeErrorOutlineAndColor()           // Clear error border
            defaultTipError.text = ""                   // Clear error
            defaults.set(defaultTipTextInput, forKey: Constants.Storyboard.userDefinedTip)
            defaultTip.text = defaultTipTextInput + "%"
            
            // Force UserDefaults to save.
            defaults.synchronize()
            return
        }
    }
    
    @IBAction func maxTipEndedEditing(_ sender: UITextField) {
        // When ending editing for the max tip textbox, add % to the
        // textfields. Run comparisons to verify valid input for max tip percentages.
        // https://developer.apple.com/documentation/uikit/uitextfielddelegate/1619591-textfielddidendediting
        // Border editing - https://stackoverflow.com/questions/53682936/how-to-change-uitextfield-border-when-selected/53683159
        
        // Pull current valid inputs of default tip and max tip for comparison
        let currentTipDefault = defaults.string(forKey: Constants.Storyboard.userDefinedTip) ?? "25"
        let currentTipMax = defaults.string(forKey: Constants.Storyboard.userDefinedMax) ?? "50"
        
        var maxTipTextInput : String = sender.text!
        
        guard maxTipTextInput != "" else {
            // Text is empty, replace with default on exit
            defaultMaxTip.text = currentTipMax + "%"
            return
        }
        
        maxTipTextInput = maxTipTextInput.replacingOccurrences(of: "%", with: "")
                                      
        let maxTipTextInputInteger = Int(maxTipTextInput)!
        
        if Int(currentTipDefault)! > maxTipTextInputInteger {
            // Tip max can't be less than tip max
            defaultMaxTip.addErrorOutlineAndColor()
            maxTipError.text = "Max tip cannot be less than default tip."
            defaultMaxTip.text = currentTipMax + "%"
            return
        }
        
        else if maxTipTextInputInteger < 15 || maxTipTextInputInteger > 100 {
            // User input max default cannot be less than 15 or greater than 100
            defaultMaxTip.addErrorOutlineAndColor()
            maxTipError.text = "Value must be >15%, and <100%."
            defaultMaxTip.text = currentTipMax + "%"
            return
        }
        
        else {
            // User input for max tip percentage is valid
            defaultMaxTip.removeErrorOutlineAndColor()  // Clear error border
            maxTipError.text = ""                       // Clear error
            defaults.set(maxTipTextInputInteger, forKey: Constants.Storyboard.userDefinedMax)
            defaultMaxTip.text = maxTipTextInput + "%"
            
            // Force UserDefaults to save.
            defaults.synchronize()
            return
        }
    }
    
    @IBAction func setUserDefaultViewMode(_ sender: Any) {
        // Set user default view mode based on change toggle value
        let textInputFields: [UITextField] = [defaultTip, defaultMaxTip, currencyPicker]
        if darkModeToggle.isOn {
            defaults.set("Dark", forKey: Constants.Storyboard.userDefinedAppearance)
            self.view.setDarkOrLightViewModeForSettingsScreen(darkOrLight: "Dark", textInputFields: textInputFields, darkModeToggle: darkModeToggle)
            navigationController?.setDarkOrLightNavigationMode(darkOrLight: "Dark")
        }
        else {
            defaults.set("Light", forKey: Constants.Storyboard.userDefinedAppearance)
            self.view.setDarkOrLightViewModeForSettingsScreen(darkOrLight: "Light", textInputFields: textInputFields, darkModeToggle: darkModeToggle)
            navigationController?.setDarkOrLightNavigationMode(darkOrLight: "Light")
        }
        
        // Force UserDefaults to save.
        defaults.synchronize()
    }
    
    @IBAction func toggleSliderSetting(_ sender: Any) {
        // Set smooth slider default value
        let currentValue = defaults.bool(forKey: Constants.Storyboard.sliderSetting)
        
        if currentValue {
            defaults.set(false, forKey: Constants.Storyboard.sliderSetting)
        }
        else {
            defaults.set(true, forKey: Constants.Storyboard.sliderSetting)
        }
        
        // Force UserDefaults to save.
        defaults.synchronize()
    }
}

