//
//  SettingsViewController.swift
//  Prework
//
//  Created by Giovanni Propersi on 12/27/21.
//

import UIKit

class SettingsViewController: UIViewController, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    
    let defaults = UserDefaults.standard

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
        defaultTip.text = defaults.string(forKey: Constants.Storyboard.userDefinedTip) ?? "25"
        defaultTip.text = defaultTip.text! + "%"
        
        defaultMaxTip.text = defaults.string(forKey: Constants.Storyboard.userDefinedMax) ?? "50"
        defaultMaxTip.text = defaultMaxTip.text! + "%"
        
        // Set slider setting, based on user preference
        let smoothToggleSetting = defaults.bool(forKey: Constants.Storyboard.sliderSetting)
        
        smoothSliderToggle.setOn(smoothToggleSetting, animated: true)
        
        let darkOrLight = defaults.string(forKey: Constants.Storyboard.userDefinedAppearance) ?? "Light"
        let textInputFields: [UITextField] = [defaultTip, defaultMaxTip, currencyPicker]
        
        switch darkOrLight {
        case "Light":
            darkModeToggle.setOn(false, animated: true)
            self.view.setDarkOrLightViewModeForSettingsScreen(darkOrLight: "Light", textInputFields: textInputFields, darkModeToggle: darkModeToggle)
            navigationController?.setDarkOrLightNavigationMode(darkOrLight: "Light")
        
        default :
            darkModeToggle.setOn(true, animated: true)
            self.view.setDarkOrLightViewModeForSettingsScreen(darkOrLight: "Dark", textInputFields: textInputFields, darkModeToggle: darkModeToggle)
            navigationController?.setDarkOrLightNavigationMode(darkOrLight: "Dark")
        }
        
        let currencyChosen = defaults.string(forKey: Constants.Storyboard.currencySelection) ?? Locale.current.currencyCode
        
        currencies = Locale.isoCurrencyCodes
        
        picker.isHidden = true
        currencyPicker.text = currencyChosen
        
        // Picker view
        // https://stackoverflow.com/questions/36193009/uipickerview-pop-up

        self.currencyPicker.delegate = self
        self.picker.delegate = self
        self.picker.dataSource = self
        
        let currencyIndex = currencies.firstIndex(of: currencyChosen!)
        picker.selectRow(currencyIndex!, inComponent: 0, animated: false)
        
        self.defaultTip.keyboardType = .numberPad
        
        // Do any additional setup after loading the view.
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
        defaults.set(currencies[row], forKey: Constants.Storyboard.currencySelection)
        
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
    
    @objc private func didTapDone() {
        defaultTip.resignFirstResponder()
        defaultMaxTip.resignFirstResponder()
    }
    
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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
