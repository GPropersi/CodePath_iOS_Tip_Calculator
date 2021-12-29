//
//  ViewController.swift
//  Prework
//
//  Created by Giovanni Propersi on 12/27/21.
//
// TODO: GUI enhancements - keyboard present on load,

import UIKit

class ViewController: UIViewController {
    
    let defaults = UserDefaults.standard
    let USER_DEFINED_TIP = "UserDefinedTip"
    let USER_DEFINED_MAX = "UserDefinedMax"

    @IBOutlet weak var billAmountTextField: UITextField!
    @IBOutlet weak var tipAmountLabel: UILabel!
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var tipPercentSlider: UISlider!
    @IBOutlet weak var tipPercentOutput: UILabel!
    @IBOutlet weak var maxSliderLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Tip Calculator"
        billAmountTextField.becomeFirstResponder()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Retrieve default/user preferred values for max and default tip
        let default_tip = Int(defaults.string(forKey: USER_DEFINED_TIP)!) ?? 25
        let default_max = Int(defaults.string(forKey:  USER_DEFINED_MAX)!) ?? 50

        set_slider_max(default_max)
        set_tip_slider_selected_value(default_tip)
        set_tip_percent_label(default_tip)
        
    }
    
    @IBAction func get_tip_perc(_ sender: Any) {
        // Capture the user chosen percentage from the slider
        // Recalculates tip/bill based on new chosen tip percentage
        print("Hit this block")
        
        let slider_tip = Int(round(tipPercentSlider.value * 100))
        
        set_tip_percent_label(slider_tip)
        
        calculateTip(self)
        
    }

    @IBAction func calculateTip(_ sender: Any) {
        // Calculates the tip based on the total Bill
        // and selected tip amount. Responds directly to editing
        // of the bill amount.
        
        let bill = Double(billAmountTextField.text!) ?? 0
        
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
        
    }
    
    func set_slider_max(_ max_tip: Int) {
        // Update slider max label, and the slider itself with the max value
        maxSliderLabel.text = "\(max_tip)" + "%"
        tipPercentSlider.maximumValue = Float(max_tip) / 100.0
    }
    
    func set_tip_slider_selected_value(_ default_tip: Int) {
        // Set the tip slider selected value based user preferred value, or default value
        tipPercentSlider.value = Float(default_tip) / 100.0
    }
    
    func set_tip_percent_label(_ tip_for_label: Int) {
        // Set the tip percent label based on user preferred value, or default value
        tipPercentOutput.text = String(format: "%2i%%", tip_for_label)
    }
    

}

