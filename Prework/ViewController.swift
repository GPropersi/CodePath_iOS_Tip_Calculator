//
//  ViewController.swift
//  Prework
//
//  Created by Giovanni Propersi on 12/27/21.
//
//Icon = https://icons8.com/icon/113854/money
// TODO - Try keeping only decimal
// TODO - String constants, look into best practice
// TODO - Clean up free functions, replace with methods or properties

import UIKit

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

class ViewController: UIViewController, UITextFieldDelegate {
    
    let defaults = UserDefaults.standard
    let USER_DEFINED_TIP = "UserDefinedTip"
    let USER_DEFINED_MAX = "UserDefinedMax"
    let USER_DEFINED_APPEARANCE = "UserDefinedAppearance"
    let VIEW_MODE: [String : UIUserInterfaceStyle] = [
        "Dark": .dark,
        "Light" : .light
    ]
    let LAST_BILL_TIME_KEY = "LastBillTime"
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
        
        // Retrieve default/user preferred values for max, default tip, and light mode
        let defaultTip = Int(defaults.string(forKey: USER_DEFINED_TIP) ?? "25")
        let defaultMax = Int(defaults.string(forKey:  USER_DEFINED_MAX) ?? "50")
        let defaultViewMode = defaults.string(forKey: USER_DEFINED_APPEARANCE) ?? "Light"
        
        // Set unsafe area to system background color
        // https://developer.apple.com/forums/thread/682420
        
        // Set dark or light mode, and set text color
        // Set title color depending on dark or light mode
        //https://stackoverflow.com/questions/26008536/navigationbar-bar-tint-and-title-text-color-in-ios-8
        setDarkOrLightModeSettings(defaultViewMode)

        // Set UserDefault values, and slider setting
        setSliderMax(defaultMax!)
        setTipSliderSelectedValue(defaultTip!)
        setTipPercentLabel(defaultTip!)
        
        // Check if 10 minutes have passed since User last entered bill, if so reset
        let lastEnteredBillTime: Int = defaults.integer(forKey: LAST_BILL_TIME_KEY)       // Default value is 0
        
        if lastEnteredBillTime != 0 {
            checkIfTenMinutesSinceLastEntry(lastEnteredBillTime)
        }
        else {
            // Slides everything away on first time
            billAmountTextField.text = convertToCurrency(0.0)
            hideEverythingBelowBill()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // Couldn't figure out how to lock view in portrait mode without code below
        // https://stackoverflow.com/questions/40413567/overriding-shouldautorotate-not-working-in-swift-3
        super.viewDidAppear(animated)
        AppDelegate.AppUtility.lockOrientation(.portrait)
    }
    
    @IBSegueAction func changeViews(_ coder: NSCoder) -> SettingsViewController? {
        // Used to slide in initial text again if time has passed while on setting screen
        defaults.set(true, forKey: CHANGED_SCREENS)
        
        // Force UserDefaults to save.
        defaults.synchronize()
        return SettingsViewController(coder: coder)
    }
    
    func hideEverythingBelowBill() {
        // Hide everything not needed when first opening or after 10 minutes
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
        // Hide get started text by fading it out
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
    
    func setDarkOrLightModeSettings(_ chosenViewMode: String) {
        // Sets the view to chosen dark/light mode, and alters text to match the mode. Default is Light mode
        overrideUserInterfaceStyle = VIEW_MODE[chosenViewMode]!
        
        let LABELS : [UILabel] = [tipAmountLabel, totalLabel, tipPercentOutput]
        
        switch chosenViewMode {
        case "Dark":
            for labelColor in LABELS {
                labelColor.textColor = TEXT_COLOR_DARK_MODE
            }
            billAmountTextField.textColor = TEXT_COLOR_DARK_MODE
            self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
            self.navigationController?.navigationBar.backgroundColor = UIColor.black
            let standard = self.navigationController?.navigationBar.standardAppearance
            self.navigationController?.navigationBar.scrollEdgeAppearance = standard
            
        default:
            for labelColor in LABELS {
                labelColor.textColor = TEXT_COLOR_LIGHT_MODE
            }
            billAmountTextField.textColor = TEXT_COLOR_LIGHT_MODE
            self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black]
            self.navigationController?.navigationBar.backgroundColor = UIColor.darkGray
            let standard = self.navigationController?.navigationBar.standardAppearance
            self.navigationController?.navigationBar.scrollEdgeAppearance = standard
        }
    }
    
    func resetMargins() {
        // Reset the layout to its original margins
        let originalMargins: [CGFloat] = defaults.object(forKey: ORIGINAL_MARGIN) as! [CGFloat]
        self.movableLeftEdge!.constant = originalMargins[0]
        self.movableRightEdge!.constant = originalMargins[1]
        self.view.layoutIfNeeded()
    }
    
    func checkIfTenMinutesSinceLastEntry(_ lastBillTime: Int) {
        // Check if 10 minutes passed since last entry, if not then keep last bill in input
        let currentTime = Int(Date().timeIntervalSince1970)
        
        if currentTime - lastBillTime > 600 {
            // More than 10 minutes have passed since last restart, use empty bill
            print("Hit here")
            billAmountTextField.text = convertToCurrency(0.0)
            hideEverythingBelowBill()
            defaults.set(convertToCurrency(0.0), forKey: LAST_BILL)
            
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
            // Less than 10 minutes have passed, use previous bill, but convert to
            // currency if user changed currency
            self.enterBillText.alpha = 0
            let lastBillDecimalAsString: String = defaults.string(forKey: LAST_BILL_DECIMAL) ?? "0.0"
            let lastBillDecimal: Decimal = Decimal(string: lastBillDecimalAsString)!
            billAmountTextField.text = convertToCurrency(lastBillDecimal)
            calculateTip(lastBillDecimal)
        }
    }
    
    @IBAction func getTipPerc(_ sender: Any) {
        // Capture the user chosen percentage from the slider
        // Recalculates tip/bill based on new chosen tip percentage
        // Sets slider to rounded value so it 'clicks' into place
        
        let smoothSliderSetting = defaults.bool(forKey: SLIDER_SETTING)
        let sliderTip = Int(round(tipPercentSlider.value * 100))
        let sliderRoundedValue = Float(sliderTip) / 100.0
        if !smoothSliderSetting {
            tipPercentSlider.value = sliderRoundedValue
        }
        setTipPercentLabel(sliderTip)
        
        let lastBill = convertToDecimalFromCurrency(billAmountTextField.text!)

        calculateTip(lastBill)
    }
    
    func convertToCurrency(_ input: Decimal) -> String {
        // Converts decimal to string using currencyFormatter
        let currencyFormatter = getCurrencyFormatter()
        
        return currencyFormatter.string(from: NSDecimalNumber(decimal: input))!
    }
    
    func convertToDecimalFromCurrency(_ stringInput: String) -> Decimal {
        // Converts from currency to decimal
        let currencyFormatter = getCurrencyFormatter()
        
        let currencySymbol: String = currencyFormatter.currencySymbol!
        let groupingSymbol: String = currencyFormatter.groupingSeparator!
        
        var stringInputModded = stringInput
        
        stringInputModded = stringInputModded.replacingOccurrences(of: currencySymbol, with: "")
        stringInputModded = stringInputModded.replacingOccurrences(of: groupingSymbol, with: "")

        return Decimal(string: stringInputModded)!
    }

    @IBAction func validateBillInputs(_ textField: UITextField) {
        // Calculates the tip based on the total Bill
        // and selected tip amount. Responds directly to editing
        // of the bill amount.
        
        let currencyFormatter = getCurrencyFormatter()

        let currencySymbol: String = currencyFormatter.currencySymbol!
        let decimalSymbol: String = currencyFormatter.decimalSeparator!
        let groupingSymbol: String = currencyFormatter.groupingSeparator!
        
        let everythingIsHidden = defaults.bool(forKey: EMPTY_BILL)
        let lastEnteredBillString = defaults.string(forKey: LAST_BILL) ?? convertToCurrency(0.0)
        let lastEnteredBillDecimalAsString: String = defaults.string(forKey: LAST_BILL_DECIMAL) ?? "0.0"
        let lastEnteredBillDecimalFromString: Decimal = Decimal(string: lastEnteredBillDecimalAsString)!
        
        print(lastEnteredBillString)
        print(lastEnteredBillDecimalAsString)
        
        var billAmount = billAmountTextField.text!
        let containsDecimalSymbol: Bool = lastEnteredBillString.contains(decimalSymbol)
        
        if everythingIsHidden {
            // Slide in all inputs if everything is hidden after user begins to type in values
            defaults.set(false, forKey: EMPTY_BILL)
            slideInEverything()
            resetMargins()
        }
        
        let containsInvalidChars : Bool = validateCurrencyOnly(billAmount, currencySymbol, decimalSymbol, groupingSymbol)
        
        // Validate inputs for currency values
        if containsInvalidChars {
            billAmountTextField.text = lastEnteredBillString
            return
        }
        
        let lastBillLength = defaults.integer(forKey: LAST_BILL_STRING_LENGTH)
        var userPressedDelete: Bool
        
        if lastBillLength > billAmount.count {
            // Length of current input is shorter than before -> user pressed delete
            userPressedDelete = true
        }
        else {
            userPressedDelete = false
        }
        
        billAmount = billAmount.replacingOccurrences(of: currencySymbol, with: "")
        billAmount = billAmount.replacingOccurrences(of: groupingSymbol, with: "")
        var billAmountToDecimal: Decimal
        
        if userPressedDelete {
            // Slide digits over one to the right
            if !billAmount.contains(decimalSymbol) {
                billAmountToDecimal = Decimal(string: billAmount) ?? 0
            }
            else {
                billAmountToDecimal = (Decimal(string: billAmount) ?? 0) / 10
            }
        }
        
        else {
            // Slide digits over to the left
            if !billAmount.contains(decimalSymbol) {
                // Certain currencies contain no decimal, just shift over
                billAmountToDecimal = Decimal(string: billAmount)!
                
                if everythingIsHidden && containsDecimalSymbol{
                    // When user first opens the app, should start at the first cent, but only if currency contains a decimal
                    billAmountToDecimal /= 100
                }
                
            }
            else if lastEnteredBillDecimalFromString == (Decimal(string: billAmount) ?? 0) {
                // Off chance that user switches to a currency that doesn't use decimals.
                // Delete would then multiply by 10 instead since previous bill would've been
                // longer. i.e. YEN 10000 is shorter than $10000.00, so deleting with locale as
                // USD would make it $100000.00
                if billAmount.count > lastEnteredBillDecimalAsString.count {
                    // Occurs when user adds a 0, so shift values to left
                    
                    billAmountToDecimal = Decimal(string: billAmount)! * 10
                }
                else {
                    billAmountToDecimal = Decimal(string: billAmount)! / 10
                }
            }
            else {
                // When value contains a decimal and user adds a value to the end, shift values to left
                
                billAmountToDecimal = Decimal(string: billAmount)! * 10
            }
        }
        
        let billAmountToString = currencyFormatter.string(from: NSDecimalNumber(decimal: billAmountToDecimal))

        billAmountTextField.text = billAmountToString
        calculateTip(billAmountToDecimal)
        
        defaults.set(billAmountToString!.count, forKey: LAST_BILL_STRING_LENGTH)
        defaults.set(Int(Date().timeIntervalSince1970), forKey: LAST_BILL_TIME_KEY)
        defaults.set(billAmountToString, forKey: LAST_BILL)
        defaults.set(billAmountToDecimal.formattedAmount, forKey: LAST_BILL_DECIMAL)
  
        // Force UserDefaults to save.
        defaults.synchronize()
    }
    
    func validateCurrencyOnly(_ userInput: String, _ currencySymbol: String, _ decimalSep: String, _ groupingSep: String) -> Bool {
        // Validates user input to prevent copy-pasting non-currency values
        // Provides true if values in string are only related to the locale's currency
        let validCharacters = CharacterSet.init(charactersIn: "1234567890" + currencySymbol + decimalSep + groupingSep).union(CharacterSet.whitespaces)
        let userInputSet : CharacterSet = CharacterSet.init(charactersIn: userInput)
        
        if userInputSet.isSubset(of: validCharacters) {
            return false
        }
        else {
            return true
        }
    }
    
    func calculateTip(_ bill: Decimal) {
        // Calculates tip and total based on input values
        // Get tip by multiplying bill by tip percentage
        var tipPercent = Decimal.init(floatLiteral: Double(tipPercentSlider.value))
        tipPercent = Decimal(string: tipPercent.formattedAmount!)!

        let tip = bill * tipPercent

        // Get total by adding bill and total amount
        let total = bill + tip

        // Update the tip label
        tipAmountLabel.text = convertToCurrency(tip)
        
        // Update the total label
        totalLabel.text = convertToCurrency(total)
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
    
    func setSliderMax(_ maxTip: Int) {
        // Update slider max label, and the slider itself with the max value
        maxSliderLabel.text = "\(maxTip)" + "%"
        tipPercentSlider.maximumValue = Float(maxTip) / 100.0
    }
    
    func setTipSliderSelectedValue(_ defaultTip: Int) {
        // Set the tip slider selected value based user preferred value, or default value
        tipPercentSlider.value = Float(defaultTip) / 100.0
    }
    
    func setTipPercentLabel(_ tipForLabel: Int) {
        // Set the tip percent label based on user preferred value, or default value
        tipPercentOutput.text = String(format: "%2i%%", tipForLabel)
    }
}

