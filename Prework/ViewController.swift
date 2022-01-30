//
//  ViewController.swift
//  Prework
//
//  Created by Giovanni Propersi on 12/27/21.
//
//Icon = https://icons8.com/icon/113854/money
// TODO - Clean up free functions, replace with methods or properties

import UIKit

class ViewController: UIViewController, UITextFieldDelegate {
    
    let defaults = UserDefaults.standard
    
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
        
        self.title = "Tip Calculator"
        
        billAmountTextField.delegate = self
        
        billAmountTextField.becomeFirstResponder()

        // Define original margins
        defaults.set([movableLeftEdge.constant, movableRightEdge.constant], forKey:Constants.Storyboard.originalMargin)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Retrieve default/user preferred values for max, default tip, and light mode
        let defaultTip = Int(defaults.string(forKey: Constants.Storyboard.userDefinedTip) ?? "25")
        let defaultMax = Int(defaults.string(forKey:  Constants.Storyboard.userDefinedMax) ?? "50")
        let darkOrLightViewMode = defaults.string(forKey: Constants.Storyboard.userDefinedAppearance) ?? "Light"
        
        // Set unsafe area to system background color
        // https://developer.apple.com/forums/thread/682420
        
        // Set dark or light mode, and set text color
        // Set title color depending on dark or light mode
        //https://stackoverflow.com/questions/26008536/navigationbar-bar-tint-and-title-text-color-in-ios-8
        
        let allOutputLabels : [UILabel] = [tipAmountLabel, totalLabel, tipPercentOutput]
        
        self.view.setDarkOrLightViewModeForTipCalculatorScreen(darkOrLight: darkOrLightViewMode, billTextField: billAmountTextField, textOutputLabels: allOutputLabels)
        
        navigationController?.setDarkOrLightNavigationMode(darkOrLight: darkOrLightViewMode)

        // Set UserDefault values, and slider setting
        maxSliderLabel.text = "\(defaultMax!)" + "%"
        tipPercentSlider.setTipSliderMaxAndSelectedValues(defaultMax: defaultMax!, selectedTip:  defaultTip!)
        tipPercentOutput.setTipPercentOutput(defaultTip!)
        
        // Check if 10 minutes have passed since User last entered bill, if so reset
        let lastEnteredBillTime: Int = defaults.integer(forKey: Constants.Storyboard.lastBillTimeKey)       // Default value is 0
        
        if lastEnteredBillTime != 0 {
            checkIfTenMinutesSinceLastEntry(previousTime: lastEnteredBillTime)
        }
        else {
            // Slides everything away on first time
            billAmountTextField.text = convertDecimalToCurrency(0.0)
            self.view.hideEverythingBelowBill(leftConstraint: movableLeftEdge, rightConstrant: movableRightEdge)
            defaults.set(true, forKey: Constants.Storyboard.emptyBill)
            defaults.synchronize()
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
        defaults.set(true, forKey: Constants.Storyboard.changedScreens)
        
        // Force UserDefaults to save.
        defaults.synchronize()
        return SettingsViewController(coder: coder)
    }
    
    func checkIfTenMinutesSinceLastEntry(previousTime lastBillTime: Int) {
        // Check if 10 minutes passed since last entry, if not then keep last bill in input
        let currentTime = Int(Date().timeIntervalSince1970)
        
        if currentTime - lastBillTime > 600 {
            // More than 10 minutes have passed since last restart, use empty bill
            billAmountTextField.text = convertDecimalToCurrency(0.0)
            self.view.hideEverythingBelowBill(leftConstraint: movableLeftEdge, rightConstrant: movableRightEdge)
            
            defaults.set(true, forKey: Constants.Storyboard.emptyBill)
            defaults.set(convertDecimalToCurrency(0.0), forKey: Constants.Storyboard.lastBill)
            
            // Force UserDefaults to save.
            defaults.synchronize()
            
            if defaults.bool(forKey: Constants.Storyboard.changedScreens) {
                // If enough time has passed on setting screen, show the initial text again
                self.view.layoutIfNeeded()
                self.enterBillText.fadeIn()
                
                defaults.set(false, forKey: Constants.Storyboard.changedScreens)
                
                // Force UserDefaults to save.
                defaults.synchronize()
            }
        }
        else {
            // Less than 10 minutes have passed, use previous bill, but convert to
            // currency if user changed currency
            self.enterBillText.alpha = 0
            let lastBillDecimalAsString: String = defaults.string(forKey: Constants.Storyboard.lastBillDecimal) ?? "0.0"
            let lastBillDecimal: Decimal = Decimal(string: lastBillDecimalAsString)!
            billAmountTextField.text = convertDecimalToCurrency(lastBillDecimal)
            calculateTip(lastBillDecimal)
        }
    }
    
    @IBAction func getTipPerc(_ sender: Any) {
        // Capture the user chosen percentage from the slider
        // Recalculates tip/bill based on new chosen tip percentage
        // Sets slider to rounded value so it 'clicks' into place
        
        let smoothSliderSetting = defaults.bool(forKey: Constants.Storyboard.sliderSetting)
        let sliderTip = Int(round(tipPercentSlider.value * 100))
        let sliderRoundedValue = Float(sliderTip) / 100.0
        if !smoothSliderSetting {
            tipPercentSlider.value = sliderRoundedValue
        }
        tipPercentOutput.setTipPercentOutput(sliderTip)
        
        let lastBill = convertToDecimalFromCurrency(billAmountTextField.text!)

        calculateTip(lastBill)
    }

    @IBAction func validateBillInputs(_ textField: UITextField) {
        // Calculates the tip based on the total Bill and selected tip amount. Responds directly to editing of the bill amount.
        
        let currencyFormatter = getCurrencyFormatter()

        let currencySymbol: String = currencyFormatter.currencySymbol!
        let decimalSymbol: String = currencyFormatter.decimalSeparator!
        let groupingSymbol: String = currencyFormatter.groupingSeparator!
        
        let everythingIsHidden = defaults.bool(forKey: Constants.Storyboard.emptyBill)
        let lastEnteredBillString = defaults.string(forKey: Constants.Storyboard.lastBill) ?? convertDecimalToCurrency(0.0)
        let lastEnteredBillDecimalAsString: String = defaults.string(forKey: Constants.Storyboard.lastBillDecimal) ?? "0.0"
        let lastEnteredBillDecimalFromString: Decimal = Decimal(string: lastEnteredBillDecimalAsString)!

        var billAmount = billAmountTextField.text!
        
        let containsInvalidChars : Bool = validateCharactersAreCurrencyOnly(billAmount, currencySymbol, decimalSymbol, groupingSymbol)
        
        // Validate inputs for currency values
        if containsInvalidChars {
            billAmountTextField.text = lastEnteredBillString
            return
        }
        
        let lastBillLength = lastEnteredBillString.count
        
        var userPressedDelete: Bool
        
        if lastBillLength > billAmount.count && !everythingIsHidden {
            // Length of current input is shorter than before -> user pressed delete
            userPressedDelete = true
        }
        else {
            userPressedDelete = false
        }
        
        if everythingIsHidden {
            // Slide in all inputs if everything is hidden after user begins to type in values
            defaults.set(false, forKey: Constants.Storyboard.emptyBill)
            self.view.slideInFromRightAndHidePrompt(prompt: enterBillText, leftConstraint: movableLeftEdge, rightConstraint: movableRightEdge)
            
            let originalMargins: [CGFloat] = defaults.object(forKey: Constants.Storyboard.originalMargin) as! [CGFloat]
            self.view.resetLayoutMargins(leftConstraint: movableLeftEdge, rightConstraint: movableRightEdge, originalMargins: originalMargins)
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
        
        defaults.set(Int(Date().timeIntervalSince1970), forKey: Constants.Storyboard.lastBillTimeKey)
        defaults.set(billAmountToString, forKey: Constants.Storyboard.lastBill)
        defaults.set(billAmountToDecimal.formattedAmount, forKey: Constants.Storyboard.lastBillDecimal)
  
        // Force UserDefaults to save.
        defaults.synchronize()
    }
    
    func getCurrencyFormatter() -> NumberFormatter {
        // Returns a formatter for currency
        let currencyFormatter = NumberFormatter()
        currencyFormatter.usesGroupingSeparator = true
        currencyFormatter.numberStyle = .currency
        // Localize
        currencyFormatter.currencyCode = defaults.string(forKey: Constants.Storyboard.currencySelection)
        return currencyFormatter
    }
    
    func convertDecimalToCurrency(_ input: Decimal) -> String {
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
    
    func validateCharactersAreCurrencyOnly(_ userInput: String, _ currencySymbol: String, _ decimalSep: String, _ groupingSep: String) -> Bool {
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
        tipAmountLabel.text = convertDecimalToCurrency(tip)
        
        // Update the total label
        totalLabel.text = convertDecimalToCurrency(total)
    }
    
}
