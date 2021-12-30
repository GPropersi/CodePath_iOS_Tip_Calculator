//
//  SettingsViewController.swift
//  Prework
//
//  Created by Giovanni Propersi on 12/27/21.
//

import UIKit

class SettingsViewController: UIViewController, UITextFieldDelegate {
    
    let defaults = UserDefaults.standard
    let USER_DEFINED_TIP = "UserDefinedTip"
    let USER_DEFINED_MAX = "UserDefinedMax"
    let USER_DEFINED_APPEARANCE = "UserDefinedAppearance"
    let VIEW_MODE: [String : UIUserInterfaceStyle] = [
        "Dark": .dark,
        "Light" : .light
    ]

    @IBOutlet weak var defaultTip: UITextField!
    @IBOutlet weak var defaultMaxTip: UITextField!
    @IBOutlet weak var defaultTipError: UILabel!
    @IBOutlet weak var maxTipError: UILabel!
    @IBOutlet weak var darkModeToggle: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Settings"
        defaultTip.delegate = self
        defaultMaxTip.delegate = self
        
        // Set to user defined tip if previously defined
        defaultTip.text = defaults.string(forKey: USER_DEFINED_TIP) ?? "25"
        defaultTip.text = defaultTip.text! + "%"
        
        defaultMaxTip.text = defaults.string(forKey: USER_DEFINED_MAX) ?? "50"
        defaultMaxTip.text = defaultMaxTip.text! + "%"
        
        let dark_or_light = defaults.string(forKey: USER_DEFINED_APPEARANCE) ?? "Light"
        
        setViewMode(dark_or_light)
        setTitleTextColor(dark_or_light)
        
        // Do any additional setup after loading the view.
    }
    
    func setTitleTextColor(_ dark_or_white: String) {
        // Set title color depending on "Light" or "Dark"
        if dark_or_white == "Light" {
            self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black]
        }
        else {
            self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        // When ending editing for the two settings, add % to the
        // textfields. Run comparisons to verify valid inputs for max and default tip percentages.
        // https://developer.apple.com/documentation/uikit/uitextfielddelegate/1619591-textfielddidendediting
        // Border editing - https://stackoverflow.com/questions/53682936/how-to-change-uitextfield-border-when-selected/53683159
    
        let current_text_field = textField
        let current_tip_default = defaults.string(forKey: USER_DEFINED_TIP)
        let current_tip_max = defaults.string(forKey: USER_DEFINED_MAX)
        
        if current_text_field == defaultTip {
            
            var current_text_field_text = textField.text ?? current_tip_default
            
            if current_text_field_text == "" {
                // User switched field input boxes, restore previously used value
                current_text_field.text = current_tip_default! + "%"
                return
            }
            
            current_text_field_text = current_text_field_text!.replacingOccurrences(of: "%", with: "")
            
            let current_text_field_integer = Int(current_text_field_text!)!
            
            if Int(current_tip_max!)! < current_text_field_integer {
                // Tip default can't be greater than tip max
                current_text_field.layer.borderColor = UIColor.red.cgColor
                current_text_field.layer.borderWidth = 2.0
                defaultTipError.text = "Default tip greater than max."
                defaultTip.text = current_tip_default! + "%"
                return
            }
            
            else if current_text_field_integer < 0 || current_text_field_integer > 100 {
                // User input tip percent cannot be below 0 or above 100
                current_text_field.layer.borderColor = UIColor.red.cgColor
                current_text_field.layer.borderWidth = 2.0
                defaultTipError.text = "Max tip less than default."
                defaultTip.text = current_tip_default! + "%"
                return
            }
            
            else {
                // User input for default tip is valid, store in UserDefaults
                current_text_field.layer.borderWidth = 0
                defaultTipError.text = ""
                defaults.set(current_text_field_text, forKey: USER_DEFINED_TIP)
                defaultTip.text = current_text_field_text! + "%"
                return
            }
        }
            
        else if current_text_field == defaultMaxTip {
            
            var current_text_field_text = textField.text ?? current_tip_max
            
            if current_text_field_text == "" {
                // User switched field input boxes, restore previously used value
                current_text_field.text = current_tip_max! + "%"
                return
            }
            
            current_text_field_text = current_text_field_text!.replacingOccurrences(of: "%", with: "")
            
            let current_text_field_integer = Int(current_text_field_text!)!
            
            if Int(current_tip_default!)! > current_text_field_integer {
                // Tip max can't be less than tip max
                current_text_field.layer.borderColor = UIColor.red.cgColor
                current_text_field.layer.borderWidth = 2.0
                maxTipError.text = "Max tip cannot less than default tip."
                defaultMaxTip.text = current_tip_max! + "%"
                return
            }
            
            else if current_text_field_integer < 15 || current_text_field_integer > 100 {
                // User input max default cannot be less than 15 or greater than 100
                current_text_field.layer.borderColor = UIColor.red.cgColor
                current_text_field.layer.borderWidth = 2.0
                maxTipError.text = "Value must be >15%, and <100%."
                defaultMaxTip.text = current_tip_max! + "%"
                return
            }
            
            else {
                // User input for max tip percentage is valid
                current_text_field.layer.borderWidth = 0
                maxTipError.text = ""
                defaults.set(current_text_field_text, forKey: USER_DEFINED_MAX)
                defaultMaxTip.text = current_text_field_text! + "%"
                return
            }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // https://stackoverflow.com/questions/34501364/swift-text-field-keyboard-return-key-not-working
        // Set auto-return key on the textbox
        textField.resignFirstResponder()
        return true
    }
    
    @IBAction func setUserDefaultViewMode(_ sender: Any) {
        // Set user default view mode based on change toggle value
        if darkModeToggle.isOn {
            defaults.set("Dark", forKey: USER_DEFINED_APPEARANCE)
            overrideUserInterfaceStyle = VIEW_MODE["Dark"]!
            setTitleTextColor("Dark")
            defaultTip.backgroundColor = UIColor.systemGray2
            defaultMaxTip.backgroundColor = UIColor.systemGray2
        }
        else {
            defaults.set("Light", forKey: USER_DEFINED_APPEARANCE)
            overrideUserInterfaceStyle = VIEW_MODE["Light"]!
            setTitleTextColor("Light")
            defaultTip.backgroundColor = UIColor.systemBackground
            defaultMaxTip.backgroundColor = UIColor.systemBackground
        }
    }
    
    func setViewMode(_ dark_or_light: String) {
        // Sets the view mode for dark or light
        if dark_or_light == "Dark" {
            darkModeToggle.setOn(true, animated: true)
            overrideUserInterfaceStyle = VIEW_MODE[dark_or_light]!
            defaultTip.backgroundColor = UIColor.systemGray2
            defaultMaxTip.backgroundColor = UIColor.systemGray2
        }
        else {
            darkModeToggle.setOn(false, animated: false)
            overrideUserInterfaceStyle = VIEW_MODE[dark_or_light]!
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
