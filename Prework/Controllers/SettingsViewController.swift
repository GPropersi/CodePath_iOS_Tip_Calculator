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
    
}
