//
//  ViewController.swift
//  Prework
//
//  Created by Giovanni Propersi on 12/27/21.
//
//Icon = https://icons8.com/icon/113854/money

import UIKit

extension Decimal {
    var formattedAmount: String? {
        let formatter = NumberFormatter()
        formatter.generatesDecimalNumbers = true
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        return formatter.string(from: self as NSDecimalNumber)
    }
}

extension Decimal {
    func roundDecimal() -> String {
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = 2
        return formatter.string(from: self as NSDecimalNumber)!
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
    let LAST_BILL_DECIMAL = "LastBillDecimal"
    let LAST_BILL_STRING_LENGTH = "LastBillSStringLength"
    let TEXT_COLOR_LIGHT_MODE : UIColor = UIColor.init(red: -0.027515370398759842, green: 0.32696807384490967, blue: -0.07128610461950302, alpha: 1.0)
    let TEXT_COLOR_DARK_MODE : UIColor = UIColor.systemGreen
    let SLIDER_SETTING = "SliderSetting"
    let EMPTY_BILL = "EmptyBill"
    let CHANGED_SCREENS = "ChangedScreens"
    let CURRENCY_SELECTION = "CurrencySelection"
    let ORIGINAL_MARGIN = "OriginalMargin"
    
    @IBOutlet weak var billAmountTextField: UITextField!
    @IBOutlet weak var tipAmountLabel: UILabel!
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var tipPercentSlider: UISlider!
    @IBOutlet weak var tipPercentOutput: UILabel!
    @IBOutlet weak var maxSliderLabel: UILabel!
    @IBOutlet weak var totaltextLabel: UILabel!
    @IBOutlet weak var minSliderLabel: UILabel!
    @IBOutlet weak var tipTextLabel: UILabel!
    @IBOutlet weak var tipPercentTextLabel: UILabel!
    @IBOutlet weak var enterBillText: UILabel!
    
    @IBOutlet weak var movableLeftEdge: NSLayoutConstraint!
    @IBOutlet weak var movableRightEdge: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        billAmountTextField.delegate = self
        
        self.title = "Tip Calculator"
        
        billAmountTextField.becomeFirstResponder()

        // Define original margins
        defaults.set([movableLeftEdge.constant, movableRightEdge.constant], forKey:ORIGINAL_MARGIN)
        
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
        
        // Set dark or light mode, and set text color
        // Set title color depending on dark or light mode
        //https://stackoverflow.com/questions/26008536/navigationbar-bar-tint-and-title-text-color-in-ios-8
        setDarkOrLightModeSettings(default_view_mode)

        // Set UserDefault values, and slider setting
        setSliderMax(default_max!)
        setTipSliderSelectedValue(default_tip!)
        setTipPercentLabel(default_tip!)
        
        // Check if 10 minutes have passed since User last entered bill, if so reset
        let last_entered_bill = defaults.string(forKey: LAST_BILL) ?? convert_to_currency(0.0)
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
    
    @IBSegueAction func changeViews(_ coder: NSCoder) -> SettingsViewController? {
        // Using to slide in initial text again
        defaults.set(true, forKey: CHANGED_SCREENS)
        
        // Force UserDefaults to save.
        defaults.synchronize()
        return SettingsViewController(coder: coder)
    }
    
    func hideEverythingBelowBill() {
        // Hide everything not needed when bill is empty
        self.movableLeftEdge!.constant += self.view.bounds.width
        self.movableRightEdge!.constant -= self.view.bounds.width
        self.view.layoutIfNeeded()
        
        // To remember if everything has been hidden before
        defaults.set(true, forKey: EMPTY_BILL)
        
        // Force UserDefaults to save.
        defaults.synchronize()
    }
    
    func slideInEverything() {
        // Slide everything back into view after user types in bill
        // Hide get started text
        // https://www.twilio.com/blog/2018/04/constraint-animations-ios-apps-xcode-swift.html

        let ANIMATION_SPEED : Double = 0.4
        
        self.view.layoutIfNeeded()
        UIView.animate(withDuration: ANIMATION_SPEED, delay: 0.0, options: [], animations: {
            self.enterBillText.alpha = 0
            self.view.layoutIfNeeded()
        }, completion: nil)
        
        self.view.layoutIfNeeded()
        UIView.animate(withDuration: ANIMATION_SPEED, delay: 0.0, options: [], animations: {
            self.movableLeftEdge.constant -= self.view.bounds.width
            self.view.layoutIfNeeded()
        }, completion: nil)
        
        self.view.layoutIfNeeded()
        UIView.animate(withDuration: ANIMATION_SPEED, delay: 0.0, options: [], animations: {
            self.movableRightEdge!.constant += self.view.bounds.width
            self.view.layoutIfNeeded()
        }, completion: nil)
         
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
            self.navigationController?.navigationBar.backgroundColor = UIColor.black
            let standard = self.navigationController?.navigationBar.standardAppearance
            self.navigationController?.navigationBar.scrollEdgeAppearance = standard
            
        default:
            for label_color in LABELS {
                label_color.textColor = TEXT_COLOR_LIGHT_MODE
            }
            billAmountTextField.textColor = TEXT_COLOR_LIGHT_MODE
            self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black]
            self.navigationController?.navigationBar.backgroundColor = UIColor.darkGray
            let standard = self.navigationController?.navigationBar.standardAppearance
            self.navigationController?.navigationBar.scrollEdgeAppearance = standard
        }
    }
    
    func resetMargins() {
        let original_margins: [CGFloat] = defaults.object(forKey: ORIGINAL_MARGIN) as! [CGFloat]
        self.movableLeftEdge!.constant = original_margins[0]
        self.movableRightEdge!.constant = original_margins[1]
        self.view.layoutIfNeeded()
    }
    
    func checkIfTenMinutesSinceLastEntry(_ last_bill_time: Int, _ last_bill: String) {
        // Check if 10 minutes passed since last entry, if not then keep last bill in input
        let current_time = Int(Date().timeIntervalSince1970)
        
        if current_time - last_bill_time > 60 {
            // More than 10 minutes have passed since last restart, use empty bill
            billAmountTextField.text = convert_to_currency(0.0)
            hideEverythingBelowBill()
            defaults.set(convert_to_currency(0.0), forKey: LAST_BILL)
            
            // Force UserDefaults to save.
            defaults.synchronize()
            
            if defaults.bool(forKey: CHANGED_SCREENS) {
                // If enough time has passed on setting screen, show the initial text again
                self.view.layoutIfNeeded()
                UIView.animate(withDuration: 0.4, delay: 0.0, animations: {
                    self.enterBillText.alpha = 1
                    self.view.layoutIfNeeded()
                }, completion: nil)
                
                defaults.set(false, forKey: CHANGED_SCREENS)
                
                // Force UserDefaults to save.
                defaults.synchronize()
            }
        }
        else {
            // Less than 10 minutes have passed, use previous bill, but convert
            // currency if user changed currency
            self.enterBillText.alpha = 0
            let last_bill_dec_as_string: String = defaults.string(forKey: LAST_BILL_DECIMAL) ?? "0.0"
            let last_bill_dec: Decimal = Decimal(string: last_bill_dec_as_string)!
            billAmountTextField.text = convert_to_currency(last_bill_dec)
            calculateTip(last_bill_dec)
        }
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
        
        let last_bill = convert_to_decimal_from_currency(billAmountTextField.text!)

        calculateTip(last_bill)
    }
    
    func convert_to_currency(_ input: Decimal) -> String {
        // Converts decimal to string using currencyFormatter
        let currencyFormatter = getCurrencyFormatter()
        
        return currencyFormatter.string(from: NSDecimalNumber(decimal: input))!
    }
    
    func convert_to_decimal_from_currency(_ string_input: String) -> Decimal {
        // Converts from currency to decimal
        let currencyFormatter = getCurrencyFormatter()
        
        let currency_symbol: String = currencyFormatter.currencySymbol!
        let grouping_symbol: String = currencyFormatter.groupingSeparator!
        
        var string_input_modded = string_input
        
        string_input_modded = string_input_modded.replacingOccurrences(of: currency_symbol, with: "")
        string_input_modded = string_input_modded.replacingOccurrences(of: grouping_symbol, with: "")

        return Decimal(string: string_input_modded)!
    }

    @IBAction func validateBillInputs(_ textField: UITextField) {
        // Calculates the tip based on the total Bill
        // and selected tip amount. Responds directly to editing
        // of the bill amount.
        
        let currencyFormatter = getCurrencyFormatter()

        let currency_symbol: String = currencyFormatter.currencySymbol!
        let decimal_symbol: String = currencyFormatter.decimalSeparator!
        let grouping_symbol: String = currencyFormatter.groupingSeparator!
        
        let everything_is_hidden = defaults.bool(forKey: EMPTY_BILL)
        let last_entered_bill = defaults.string(forKey: LAST_BILL) ?? convert_to_currency(0.0)
        let last_entered_bill_decimal_format_as_string: String = defaults.string(forKey: LAST_BILL_DECIMAL) ?? "0.0"
        let last_entered_bill_as_decimal: Decimal = Decimal(string: last_entered_bill_decimal_format_as_string)!
        
        if everything_is_hidden {
            // Slide in all inputs if everything is hidden after user begins to type in values
            defaults.set(false, forKey: EMPTY_BILL)
            slideInEverything()
            resetMargins()
        }
        
        var bill_amount = billAmountTextField.text!
        
        let contains_invalid_chars : Bool = validateCurrencyOnly(bill_amount, currency_symbol, decimal_symbol, grouping_symbol)
        
        // Validate inputs for currency values
        if contains_invalid_chars {
            billAmountTextField.text = last_entered_bill
            return
        }
        
        let last_bill_length = defaults.integer(forKey: LAST_BILL_STRING_LENGTH)
        var user_pressed_delete: Bool
        
        if last_bill_length > bill_amount.count {
            // Length of current input is shorter than before -> user pressed delete
            user_pressed_delete = true
        }
        else {
            user_pressed_delete = false
        }
        
        bill_amount = bill_amount.replacingOccurrences(of: currency_symbol, with: "")
        bill_amount = bill_amount.replacingOccurrences(of: grouping_symbol, with: "")
        var bill_amount_to_decimal: Decimal
        
        if user_pressed_delete {
            // Slide digits over one to the right
            if !bill_amount.contains(decimal_symbol) {
                bill_amount_to_decimal = Decimal(string: bill_amount) ?? 0
            }
            else {
                bill_amount_to_decimal = (Decimal(string: bill_amount) ?? 0) / 10
            }
        }
        
        else {
            // Slide digits over to the left
            if !bill_amount.contains(decimal_symbol) {
                // Certain currencies contain no decimal
                bill_amount_to_decimal = Decimal(string: bill_amount)!
            }
            else if last_entered_bill_as_decimal == (Decimal(string: bill_amount) ?? 0) {
                // Off chance that user switches to a currency that doesn't use decimals.
                // Delete would then multiply by 10 instead since previous bill would've been
                // longer. i.e. YEN 10000 is shorter than $10000.00, so deleting with locale as
                // USD would make it $100000.00
                // if length of new > length of old, multiply by 10
                if bill_amount.count > last_entered_bill_decimal_format_as_string.count {
                    bill_amount_to_decimal = Decimal(string: bill_amount)! * 10
                }
                else {
                    bill_amount_to_decimal = Decimal(string: bill_amount)! / 10
                }
                
            }
            else {
                bill_amount_to_decimal = Decimal(string: bill_amount)! * 10
            }
        }
        
        let bill_amount_to_string = currencyFormatter.string(from: NSDecimalNumber(decimal: bill_amount_to_decimal))

        billAmountTextField.text = bill_amount_to_string
        calculateTip(bill_amount_to_decimal)
        
        defaults.set(bill_amount_to_string!.count, forKey: LAST_BILL_STRING_LENGTH)
        defaults.set(Int(Date().timeIntervalSince1970), forKey: LAST_BILL_TIME)
        defaults.set(bill_amount_to_string, forKey: LAST_BILL)
        defaults.set(bill_amount_to_decimal.formattedAmount, forKey: LAST_BILL_DECIMAL)
  
        // Force UserDefaults to save.
        defaults.synchronize()
    }
    
    func validateCurrencyOnly(_ user_input: String, _ currency_symbol: String, _ decimal_sep: String, _ grouping_sep: String) -> Bool {
        // Validates user input to prevent copy-pasting non-currency values
        // Provides true if values in string are only related to the locale's currency
        let valid_characters = CharacterSet.init(charactersIn: "1234567890" + currency_symbol + decimal_sep + grouping_sep).union(CharacterSet.whitespaces)
        let user_input_set : CharacterSet = CharacterSet.init(charactersIn: user_input)
        
        if user_input_set.isSubset(of: valid_characters) {
            return false
        }
        else {
            return true
        }
    }
    
    func calculateTip(_ bill: Decimal) {
        // Calculates tip and total based on input values
        // Get tip by multiplying bill by tip percentage
        var tip_percent = Decimal.init(floatLiteral: Double(tipPercentSlider.value))
        tip_percent = Decimal(string: tip_percent.roundDecimal())!

        let tip = bill * tip_percent

        // Get total by adding bill and total amount
        let total = bill + tip

        // Update the tip label
        tipAmountLabel.text = convert_to_currency(tip)
        
        // Update the total label
        totalLabel.text = convert_to_currency(total)
    }
    
    func getCurrencyFormatter() -> NumberFormatter {
        // Returns a formatter for currency
        let currencyFormatter = NumberFormatter()
        currencyFormatter.usesGroupingSeparator = true
        currencyFormatter.numberStyle = .currency
        // Localize
        currencyFormatter.currencyCode = defaults.string(forKey: CURRENCY_SELECTION)
        return currencyFormatter
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

