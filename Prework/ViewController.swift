//
//  ViewController.swift
//  Prework
//
//  Created by Giovanni Propersi on 12/27/21.
//
// TODO: Set default values and user memory
// TODO: GUI enhancements

import UIKit

class ViewController: UIViewController {
    
    let defaults = UserDefaults.standard

    @IBOutlet weak var billAmountTextField: UITextField!
    @IBOutlet weak var tipAmountLabel: UILabel!
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var tipPercentSlider: UISlider!
    @IBOutlet weak var tipPercentOutput: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Tip Calculator"
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let default_tip = Int(defaults.string(forKey: "UserDefinedTip")!) ?? 25
        print("User default tip is: \(default_tip)")
        
        set_tip_slider_selected_value(default_tip)
        set_tip_percent_label(default_tip)
        
        //get_tip_perc(self)
        // This is a good place to retrieve the default tip percentage from UserDefaults
        // and use it to update the tip amount
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
    
    func set_tip_slider_selected_value(_ default_tip: Int) {
        // Set the tip slider selected value based user preferred value, or default value
        tipPercentSlider.value = Float(default_tip) / 100.0
    }
    
    func set_tip_percent_label(_ tip_for_label: Int) {
        // Set the tip percent label based on user preferred value, or default value
        tipPercentOutput.text = String(format: "%2i%%", tip_for_label)
    }
    

}

