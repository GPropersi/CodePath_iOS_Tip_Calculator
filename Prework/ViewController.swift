//
//  ViewController.swift
//  Prework
//
//  Created by Giovanni Propersi on 12/27/21.
//
// Made tip calculator respond

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var billAmountTextField: UITextField!
    @IBOutlet weak var tipAmountLabel: UILabel!
    @IBOutlet weak var tipControl: UISegmentedControl!
    @IBOutlet weak var totalLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func calculateTip(_ sender: Any) {
        // Calculates the tip based on the total Bill
        // and selected tip amount. Responds directly to editing
        // of the bill amount.
        
        let bill = Double(billAmountTextField.text!) ?? 0
        
        // Get tip by multiplying bill by tip percentage
        let tip_percentages = [0.15, 0.18, 0.2]
        let tip = bill * tip_percentages[tipControl.selectedSegmentIndex]
        
        // Get total by adding bill and total amount
        let total = bill + tip
        
        // Update the tip label
        tipAmountLabel.text = String(format: "$%.2f", tip)
        
        // Update the total label
        totalLabel.text = String(format: "$%.2f", total)
        
    }
    

}

