//
//  ViewController.swift
//
//
//  Created by Giovanni Propersi on 12/27/21.
//  ViewController for main screen of Tip Calculator App. Where the tip gets calculated.
//  Icon = https://icons8.com/icon/113854/money

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
    
    // MARK: - Checks if user sat on settings screen longer than 10 minutes
    @IBSegueAction func changeViews(_ coder: NSCoder) -> SettingsViewController? {
        // Used to slide in initial text again if time has passed while on setting screen
        defaults.set(true, forKey: Constants.Storyboard.changedScreens)
        
        // Force UserDefaults to save.
        defaults.synchronize()
        return SettingsViewController(coder: coder)
    }
    
    // MARK: - Timer to insert stored bill if less than 10 minutes have passed
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
    
    // MARK: - Calculate the tip and total to be displayed
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
