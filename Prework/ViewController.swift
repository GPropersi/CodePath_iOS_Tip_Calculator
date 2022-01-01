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
    let EMPTY_BILL = "EmptyBill"
    
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
    
    @IBOutlet weak var tipPercentLeftEdge: NSLayoutConstraint!
    @IBOutlet weak var minSliderPercentLeftEdge: NSLayoutConstraint!
    @IBOutlet weak var sliderLeftEdge: NSLayoutConstraint!
    @IBOutlet weak var totalLabelLeftEdge: NSLayoutConstraint!
    @IBOutlet weak var tipLabelLeftEdge: NSLayoutConstraint!
    
    @IBOutlet weak var totalRightEdge: NSLayoutConstraint!
    @IBOutlet weak var tipAmountRightEdge: NSLayoutConstraint!
    @IBOutlet weak var tipPercentRightEdge: NSLayoutConstraint!
    @IBOutlet weak var maxSliderPercentRightEdge: NSLayoutConstraint!
    @IBOutlet weak var sliderRightEdge: NSLayoutConstraint!
    
    @IBOutlet weak var getStartedTopEdge: NSLayoutConstraint!
    
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
        
        // Set dark or light mode, and set text color
        // Set title color depending on dark or light mode
        //https://stackoverflow.com/questions/26008536/navigationbar-bar-tint-and-title-text-color-in-ios-8
        setDarkOrLightModeSettings(default_view_mode)

        // Set UserDefault values, and slider setting
        setSliderMax(default_max!)
        setTipSliderSelectedValue(default_tip!)
        setTipPercentLabel(default_tip!)
        
        // Check if 10 minutes have passed since User last entered bill, if so reset
        defaults.set("", forKey: LAST_BILL)
        let last_entered_bill = defaults.string(forKey: LAST_BILL) ?? ""
        let last_entered_bill_time = defaults.integer(forKey: LAST_BILL_TIME)
        
        // Do animations for sliding stuff in
        if last_entered_bill == "" {
            // Hide everything
            hideEverythingBelowBill()
            defaults.set(true, forKey: EMPTY_BILL)
        }
        
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
    
    func hideEverythingBelowBill() {
        // Hide everything not needed when bill is empty
        let things_to_hide = [tipPercentLeftEdge, minSliderPercentLeftEdge, sliderLeftEdge, totalLabelLeftEdge, tipLabelLeftEdge, totalRightEdge, tipAmountRightEdge, tipPercentRightEdge, maxSliderPercentRightEdge, sliderRightEdge]
        
        for object in things_to_hide {
            switch object {
            case sliderRightEdge:
                object!.constant += self.view.bounds.width
            default:
                object!.constant -= self.view.bounds.width
            }
        }
    }
    
    func slideInEverything() {
        // Slide everything back into view after user types in bill
        // Hide get started text
        let things_to_slide = [tipPercentLeftEdge, minSliderPercentLeftEdge, sliderLeftEdge, totalLabelLeftEdge, tipLabelLeftEdge, totalRightEdge, tipAmountRightEdge, tipPercentRightEdge, maxSliderPercentRightEdge, sliderRightEdge]
        
        let ANIMATION_SPEED : Double = 0.4
        
        UIView.animate(withDuration: ANIMATION_SPEED, delay: 0.0, options: [], animations: {
            self.getStartedTopEdge.constant += self.view.bounds.height
            self.view.layoutIfNeeded()
        }, completion: nil)
        
        for object in things_to_slide {
            
            // Slider needs to move as one object, so right edge needs to move from right to left even though constrained to right
            switch object {
            case sliderRightEdge:
                UIView.animate(withDuration: ANIMATION_SPEED, delay: 0.0, options: [], animations: {
                    object!.constant -= self.view.bounds.width
                    self.view.layoutIfNeeded()
                }, completion: nil)
            
            default:
                UIView.animate(withDuration: ANIMATION_SPEED, delay: 0.0, options: [], animations: {
                    object!.constant += self.view.bounds.width
                    self.view.layoutIfNeeded()
                }, completion: nil)
            }
        }
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
    
    func checkIfTenMinutesSinceLastEntry(_ last_bill_time: Int, _ last_bill: String) {
        // Check if 10 minutes passed since last entry, if not then keep last bill in input
        let current_time = Int(Date().timeIntervalSince1970)
        
        if current_time - last_bill_time < 1 {
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
        let everything_is_hidden = defaults.bool(forKey: EMPTY_BILL)
        
        if everything_is_hidden {
            defaults.set(false, forKey: EMPTY_BILL)
            slideInEverything()
        }
        
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

