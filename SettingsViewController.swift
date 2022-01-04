//
//  SettingsViewController.swift
//  Prework
//
//  Created by Giovanni Propersi on 12/27/21.
//

import UIKit

class SettingsViewController: UIViewController, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    
    let defaults = UserDefaults.standard
    let USER_DEFINED_TIP = "UserDefinedTip"
    let USER_DEFINED_MAX = "UserDefinedMax"
    let USER_DEFINED_APPEARANCE = "UserDefinedAppearance"
    let VIEW_MODE: [String : UIUserInterfaceStyle] = [
        "Dark": .dark,
        "Light" : .light
    ]
    let SLIDER_SETTING = "SliderSetting"
    let CHANGED_SCREENS = "ChangedScreens"
    let CURRENCY_SELECTION = "CurrencySelection"

    @IBOutlet weak var defaultTip: UITextField!
    @IBOutlet weak var defaultMaxTip: UITextField!
    @IBOutlet weak var defaultTipError: UILabel!
    @IBOutlet weak var maxTipError: UILabel!
    @IBOutlet weak var darkModeToggle: UISwitch!
    @IBOutlet weak var smoothSliderToggle: UISwitch!
    
    @IBOutlet weak var currencyPicker: UITextField!
    @IBOutlet weak var picker: UIPickerView!
    
    var currencies:[String] = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Settings"
        defaultTip.delegate = self
        defaultMaxTip.delegate = self
        
        
        
        // "Done" button above keyboard for accepting user input values
        // https://www.youtube.com/watch?v=M_fP2i0tl0Q
        addDoneToKeyboard(defaultTip)
        addDoneToKeyboard(defaultMaxTip)
        
        // Set to user defined tip if previously defined
        defaultTip.text = defaults.string(forKey: USER_DEFINED_TIP) ?? "25"
        defaultTip.text = defaultTip.text! + "%"
        
        defaultMaxTip.text = defaults.string(forKey: USER_DEFINED_MAX) ?? "50"
        defaultMaxTip.text = defaultMaxTip.text! + "%"
        
        // Set slider setting, based on user preference
        let smooth_toggle_setting = defaults.bool(forKey: SLIDER_SETTING)
        
        smoothSliderToggle.setOn(smooth_toggle_setting, animated: true)
        
        let dark_or_light = defaults.string(forKey: USER_DEFINED_APPEARANCE) ?? "Light"
        
        setViewMode(dark_or_light)
        
        let currency_chosen = defaults.string(forKey: CURRENCY_SELECTION) ?? Locale.current.currencyCode
        
        currencies = Locale.isoCurrencyCodes
        
        picker.isHidden = true
        currencyPicker.text = currency_chosen
        
        // Picker view
        // https://stackoverflow.com/questions/36193009/uipickerview-pop-up

        self.currencyPicker.delegate = self
        self.picker.delegate = self
        self.picker.dataSource = self
        
        let currency_index = currencies.firstIndex(of: currency_chosen!)
        picker.selectRow(currency_index!, inComponent: 0, animated: false)
        
        self.defaultTip.keyboardType = .numberPad
        
        // Do any additional setup after loading the view.
    }
    
    @objc private func didTapDone() {
        defaultTip.resignFirstResponder()
        defaultMaxTip.resignFirstResponder()
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return currencies.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return currencies[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.currencyPicker.isHidden = false
        self.picker.isHidden = true
        self.currencyPicker.text = currencies[row]
        defaults.set(currencies[row], forKey: CURRENCY_SELECTION)
        
        // Synchronize for currency code
        defaults.synchronize()
    }
 
    func textFieldShouldBeginEditing(_ textfield: UITextField) -> Bool {
        switch textfield {
        case currencyPicker:
            self.currencyPicker.isHidden = true
            self.picker.isHidden = false
            return false
        default:
            return true
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func addDoneToKeyboard(_ frame: UITextField) {
        // Add done to the keyboard for each input option
        // https://www.youtube.com/watch?v=M_fP2i0tl0Q
        view.addSubview(frame)
        let toolBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 50))
        
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace,
                                            target: self,
                                            action: nil)
        
        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(didTapDone))
        toolBar.items = [flexibleSpace, doneButton]
        toolBar.sizeToFit()
        frame.inputAccessoryView = toolBar
    }
    
    @IBAction func defaultTipEndedEditing(_ sender: UITextField) {
        // When ending editing for the default tip textbox, add % to the
        // textfields. Run comparisons to verify valid input for default tip percentages.
        // https://developer.apple.com/documentation/uikit/uitextfielddelegate/1619591-textfielddidendediting
        // Border editing - https://stackoverflow.com/questions/53682936/how-to-change-uitextfield-border-when-selected/53683159
        
        // Pull current valid inputs of default tip and max tip for comparison
        let current_tip_default = defaults.string(forKey: USER_DEFINED_TIP) ?? "25"
        let current_tip_max = defaults.string(forKey: USER_DEFINED_MAX) ?? "50"
        
        var default_tip_text_input : String = defaultTip.text!
        
        guard default_tip_text_input != "" else {
            // Text is empty, replace with default on exit
            defaultTip.text = current_tip_default + "%"
            return
        }
        
        default_tip_text_input = default_tip_text_input.replacingOccurrences(of: "%", with: "")
        
        let default_tip_text_input_integer = Int(default_tip_text_input)!
        
        if default_tip_text_input_integer > Int(current_tip_max)! {
            // Tip default can't be greater than tip max
            defaultTip.layer.borderColor = UIColor.red.cgColor
            defaultTip.layer.borderWidth = 2.0
            defaultTipError.text = "Default tip greater than max."
            defaultTip.text = current_tip_default + "%"
            return
        }
        else if default_tip_text_input_integer < 0 {
            // User input tip percent cannot be below 0
            defaultTip.layer.borderColor = UIColor.red.cgColor
            defaultTip.layer.borderWidth = 2.0
            defaultTipError.text = "Default tip cannot be less than 0%."
            defaultTip.text = current_tip_default + "%"
            return
        }
        else {
            // User input for default tip is valid, store in UserDefaults, display
            defaultTip.layer.borderWidth = 0            // Clear error border
            defaultTipError.text = ""                   // Clear error
            defaults.set(default_tip_text_input, forKey: USER_DEFINED_TIP)
            defaultTip.text = default_tip_text_input + "%"
            
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
        let current_tip_default = defaults.string(forKey: USER_DEFINED_TIP) ?? "25"
        let current_tip_max = defaults.string(forKey: USER_DEFINED_MAX) ?? "50"
        
        var max_tip_text_input : String = sender.text!
        
        guard max_tip_text_input != "" else {
            // Text is empty, replace with default on exit
            defaultMaxTip.text = current_tip_max + "%"
            return
        }
        
        max_tip_text_input = max_tip_text_input.replacingOccurrences(of: "%", with: "")
                                      
        let max_tip_text_input_integer = Int(max_tip_text_input)!
        
        if Int(current_tip_default)! > max_tip_text_input_integer {
            // Tip max can't be less than tip max
            defaultMaxTip.layer.borderColor = UIColor.red.cgColor
            defaultMaxTip.layer.borderWidth = 2.0
            maxTipError.text = "Max tip cannot be less than default tip."
            defaultMaxTip.text = current_tip_max + "%"
            return
        }
        
        else if max_tip_text_input_integer < 15 || max_tip_text_input_integer > 100 {
            // User input max default cannot be less than 15 or greater than 100
            defaultMaxTip.layer.borderColor = UIColor.red.cgColor
            defaultMaxTip.layer.borderWidth = 2.0
            maxTipError.text = "Value must be >15%, and <100%."
            defaultMaxTip.text = current_tip_max + "%"
            return
        }
        
        else {
            // User input for max tip percentage is valid
            defaultMaxTip.layer.borderWidth = 0         // Clear error border
            maxTipError.text = ""                       // Clear error
            defaults.set(max_tip_text_input_integer, forKey: USER_DEFINED_MAX)
            defaultMaxTip.text = max_tip_text_input + "%"
            
            // Force UserDefaults to save.
            defaults.synchronize()
            return
        }
    }
    
    @IBAction func setUserDefaultViewMode(_ sender: Any) {
        // Set user default view mode based on change toggle value
        if darkModeToggle.isOn {
            defaults.set("Dark", forKey: USER_DEFINED_APPEARANCE)
            setViewMode("Dark")
        }
        else {
            defaults.set("Light", forKey: USER_DEFINED_APPEARANCE)
            setViewMode("Light")
        }
        
        // Force UserDefaults to save.
        defaults.synchronize()
    }
    
    func setViewMode(_ dark_or_light: String) {
        // Sets the view mode for dark or light
        
        switch dark_or_light {
        case "Dark" :
            darkModeToggle.setOn(true, animated: true)
            overrideUserInterfaceStyle = VIEW_MODE[dark_or_light]!
            defaultTip.backgroundColor = UIColor.systemGray2
            defaultMaxTip.backgroundColor = UIColor.systemGray2
            currencyPicker.backgroundColor = UIColor.systemGray2
            self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
            self.navigationController?.navigationBar.backgroundColor = UIColor.black
            let standard = self.navigationController?.navigationBar.standardAppearance
            self.navigationController?.navigationBar.scrollEdgeAppearance = standard
            
        default :
            darkModeToggle.setOn(false, animated: true)
            self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black]
            overrideUserInterfaceStyle = VIEW_MODE[dark_or_light]!
            defaultTip.backgroundColor = UIColor.systemBackground
            defaultMaxTip.backgroundColor = UIColor.systemBackground
            currencyPicker.backgroundColor = UIColor.systemBackground
            self.navigationController?.navigationBar.backgroundColor = UIColor.darkGray
            let standard = self.navigationController?.navigationBar.standardAppearance
            self.navigationController?.navigationBar.scrollEdgeAppearance = standard
            
        }
    }
    
    @IBAction func toggleSliderSetting(_ sender: Any) {
        // Set smooth slider default value
        let current_value = defaults.bool(forKey: SLIDER_SETTING)
        
        if current_value {
            defaults.set(false, forKey: SLIDER_SETTING)
        }
        else {
            defaults.set(true, forKey: SLIDER_SETTING)
        }
        
        // Force UserDefaults to save.
        defaults.synchronize()
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
