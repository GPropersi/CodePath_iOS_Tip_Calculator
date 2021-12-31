//
//  ViewController.swift
//  Prework
//
//  Created by Giovanni Propersi on 12/27/21.
//
// TODO: GUI enhancements - keyboard present on load,

import UIKit

extension String {
    //https://stackoverflow.com/questions/31746223/number-of-occurrences-of-substring-in-string-in-swift
    func numberOfOccurrencesOf(string: String) -> Int {
        return self.components(separatedBy:string).count - 1
    }
}

class ViewController: UIViewController, UITextFieldDelegate {
    
    let defaults = UserDefaults.standard
    let USER_DEFINED_TIP = "UserDefinedTip"
    let USER_DEFINED_MAX = "UserDefinedMax"
    let USER_DEFINED_APPEARANCE = "UserDefinedAppearance"
    let VIEW_MODE: [String : UIUserInterfaceStyle] = [
        "Dark": .dark,
        "Light" : .light
    ]
    let LAST_BILL_TIME = "LastBillTime"
    let LAST_BILL = "LastBill"
    let TEXT_COLOR_LIGHT_MODE : UIColor = UIColor.init(red: -0.027515370398759842, green: 0.32696807384490967, blue: -0.07128610461950302, alpha: 1.0)
    let TEXT_COLOR_DARK_MODE : UIColor = UIColor.systemGreen
    let SLIDER_SETTING = "SliderSetting"
    
    @IBOutlet weak var billAmountTextField: UITextField!
    @IBOutlet weak var tipAmountLabel: UILabel!
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var tipPercentSlider: UISlider!
    @IBOutlet weak var tipPercentOutput: UILabel!
    @IBOutlet weak var maxSliderLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        billAmountTextField.delegate = self
        
        self.title = "Tip Calculator"
        
        billAmountTextField.becomeFirstResponder()
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Retrieve default/user preferred values for max and default tip
        let default_tip = Int(defaults.string(forKey: USER_DEFINED_TIP) ?? "25")
        let default_max = Int(defaults.string(forKey:  USER_DEFINED_MAX) ?? "50")
        let default_view_mode = defaults.string(forKey: USER_DEFINED_APPEARANCE) ?? "Light"
        
        // Set unsafe area to system background color
        // https://developer.apple.com/forums/thread/682420
        self.navigationController?.navigationBar.backgroundColor = UIColor.systemBackground
        let standard = self.navigationController?.navigationBar.standardAppearance
        self.navigationController?.navigationBar.scrollEdgeAppearance = standard
        
        // Set dark or light mode, and set text color
        // Set title color depending on dark or light mode
        //https://stackoverflow.com/questions/26008536/navigationbar-bar-tint-and-title-text-color-in-ios-8
        setDarkOrLightModeSettings(default_view_mode)

        // Set UserDefault values, and slider setting
        setSliderMax(default_max!)
        setTipSliderSelectedValue(default_tip!)
        setTipPercentLabel(default_tip!)
        
        // Check if 10 minutes have passed since User last entered bill, if so reset
        let last_entered_bill = defaults.string(forKey: LAST_BILL) ?? ""
        let last_entered_bill_time = defaults.integer(forKey: LAST_BILL_TIME)
        
        if last_entered_bill_time != 0 {
            checkIfTenMinutesSinceLastEntry(last_entered_bill_time, last_entered_bill)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // Couldn't figure out how to lock view in portrait mode without code below
        // https://stackoverflow.com/questions/40413567/overriding-shouldautorotate-not-working-in-swift-3
        super.viewDidAppear(animated)
        AppDelegate.AppUtility.lockOrientation(.portrait)
    }
    
    func setDarkOrLightModeSettings(_ chosen_view_mode: String) {
        // Sets the view to chosen dark/light mode, and alters text to match the mode. Default is Light mode
        overrideUserInterfaceStyle = VIEW_MODE[chosen_view_mode]!
        
        let LABELS : [UILabel] = [tipAmountLabel, totalLabel, tipPercentOutput]
        
        switch chosen_view_mode {
        case "Dark":
            for label_color in LABELS {
                label_color.textColor = TEXT_COLOR_DARK_MODE
            }
            billAmountTextField.textColor = TEXT_COLOR_DARK_MODE
            self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
            
        default:
            for label_color in LABELS {
                label_color.textColor = TEXT_COLOR_LIGHT_MODE
            }
            billAmountTextField.textColor = TEXT_COLOR_LIGHT_MODE
            self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black]
        }
        }
    
    
    func checkIfTenMinutesSinceLastEntry(_ last_bill_time: Int, _ last_bill: String) {
        // Check if 10 minutes passed since last entry, if not then keep last bill in input
        let current_time = Int(Date().timeIntervalSince1970)
        
        if current_time - last_bill_time < 600 {
            // Less than 10 minutes have passed since last restart, use previous bill entry
            billAmountTextField.text = String(last_bill)
            calculateTip(billAmountTextField)
        }
    }
    
    func addDollerSign(_ textField: UITextField) {
        // Add $ sign to bill input text
        let current_text_field = textField
        let current_text_field_text = current_text_field.text!.replacingOccurrences(of: "$", with: "")
        
        current_text_field.text = "$" + current_text_field_text
    }
    
    @IBAction func getTipPerc(_ sender: Any) {
        // Capture the user chosen percentage from the slider
        // Recalculates tip/bill based on new chosen tip percentage
        // Sets slider to rounded value so it 'clicks' into place
        
        let smooth_slider_setting = defaults.bool(forKey: SLIDER_SETTING)
        let slider_tip = Int(round(tipPercentSlider.value * 100))
        let slider_rounded_value = Float(slider_tip) / 100.0
        if !smooth_slider_setting {
            tipPercentSlider.value = slider_rounded_value
        }
        setTipPercentLabel(slider_tip)
        calculateTip(billAmountTextField)
    }

    @IBAction func calculateTip(_ textField: UITextField) {
        // Calculates the tip based on the total Bill
        // and selected tip amount. Responds directly to editing
        // of the bill amount.
        var bill_amount = billAmountTextField.text!
        
        let period_occ: Int = bill_amount.numberOfOccurrencesOf(string: ".")
        
        guard period_occ <= 1 else {
            // Do not allow user to enter more than one period
            billAmountTextField.text = String(bill_amount.dropLast(1))
            return
        }
        
        // Create array with strings before and after period. User should not be inputting
        // values with more than two digits after period. Check for this.
        let strings_with_period = bill_amount.split(separator: ".")

        if strings_with_period.count > 1 && strings_with_period[1].count > 2{
            billAmountTextField.text = String(bill_amount.dropLast(1))
            return
        }
        
        bill_amount = bill_amount.replacingOccurrences(of: "$", with: "")
        
        let bill = Double(bill_amount) ?? 0
        
        // Round tip percent to 2 decimal digits
        let tip_percent = round(Double(tipPercentSlider.value) * 100) / 100.0
        
        // Get tip by multiplying bill by tip percentage
        let tip = bill * tip_percent
        
        // Get total by adding bill and total amount
        let total = bill + tip
        
        // Update the tip label
        tipAmountLabel.text = String(format: "$%.2f", tip)
        
        // Update the total label
        totalLabel.text = String(format: "$%.2f", total)
        
        defaults.set(Int(Date().timeIntervalSince1970), forKey: LAST_BILL_TIME)
        defaults.set(bill_amount, forKey: LAST_BILL)
        
        // Add doller sign to user input
        addDollerSign(textField)
    }
    
    func setSliderMax(_ max_tip: Int) {
        // Update slider max label, and the slider itself with the max value
        maxSliderLabel.text = "\(max_tip)" + "%"
        tipPercentSlider.maximumValue = Float(max_tip) / 100.0
    }
    
    func setTipSliderSelectedValue(_ default_tip: Int) {
        // Set the tip slider selected value based user preferred value, or default value
        tipPercentSlider.value = Float(default_tip) / 100.0
    }
    
    func setTipPercentLabel(_ tip_for_label: Int) {
        // Set the tip percent label based on user preferred value, or default value
        tipPercentOutput.text = String(format: "%2i%%", tip_for_label)
    }
}

