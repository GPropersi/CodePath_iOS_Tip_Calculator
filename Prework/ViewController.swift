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

    @IBOutlet weak var billAmountTextField: UITextField!
    @IBOutlet weak var tipAmountLabel: UILabel!
    @IBOutlet weak var tipControl: UISegmentedControl!
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var tipPercentSlider: UISlider!
    @IBOutlet weak var tipPercentOutput: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Tip Calculator"
        // Do any additional setup after loading the view.
    }
    
    @IBAction func get_tip_perc(_ sender: Any) {
        // Capture the user chosen percentage from the slider
        // Recalculates tip/bill based on new chosen tip percentage
        let tip_perc = Int(round(tipPercentSlider.value * 100))
        
        tipPercentOutput.text = String(format: "%2i%%", tip_perc)
        
        change_segment_tips(tip_perc)
        
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
    
    func change_segment_tips(_ slider_tip: Int) {
        // Changes the segments based on the slider tips
        // If tip percent is >= Max Tip - 5, then slider segments are
        // set to [Max - 5, Max - 2, Max]
        // If tip percent <= Min tip, then force slider segments to be 0, 3, and 5
        
        // Change this to user default setting value
        let max_tip = 50
        var new_tips: [String] = []
        
        // Better way to do this? Forces segments based on 3 sets of conditions
        if slider_tip >= max_tip - 5 {
            new_tips = [String(format: "%2i%%", max_tip - 5), String(format: "%2i%%", max_tip - 2), String(format: "%2i%%", max_tip)]
        }
        else if slider_tip <= 5 {
            new_tips = ["0%", "3%", "5%"]
        }
        else {
            new_tips = [String(format: "%2i%%", slider_tip - 5), String(format: "%2i%%", slider_tip - 2), String(format: "%2i%%", slider_tip)]
        }

        for segment in new_tips.indices {
            tipControl.setTitle(new_tips[segment], forSegmentAt: segment)
        }

    }
    

}

