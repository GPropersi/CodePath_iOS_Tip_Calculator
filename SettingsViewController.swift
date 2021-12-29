//
//  SettingsViewController.swift
//  Prework
//
//  Created by Giovanni Propersi on 12/27/21.
//

import UIKit

class SettingsViewController: UIViewController, UITextFieldDelegate {
    
    let defaults = UserDefaults.standard

    @IBOutlet weak var defaultTip: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Settings"
        defaultTip.delegate = self
        
        // Set to user defined tip if previously defined
        defaultTip.text = defaults.string(forKey: "UserDefinedTip") ?? nil
        addTipPercSuffix(self)

        // Do any additional setup after loading the view.
    }
    
    @IBAction func addTipPercSuffix (_ sender: Any) {
        // Add a % sign to the user's input
        
        var default_tip_perc = defaultTip.text ?? nil
        
        // If value does not contain a % sign at end, include % sign
        if default_tip_perc!.suffix(1) != "%" {
            
            // Replace all % signs with empty strings to read the value
            default_tip_perc = default_tip_perc!.replacingOccurrences(of: "%", with: "")
            
            if Int(default_tip_perc!)! < 0 || Int(default_tip_perc!)! > 100 {
                // User input tip percent cannot be below 0 or above 100
                return
            }
            else {
                defaultTip.text = default_tip_perc! + "%"
            }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // https://stackoverflow.com/questions/34501364/swift-text-field-keyboard-return-key-not-working
        // Set auto-return key on the textbox
        textField.resignFirstResponder()
        setDefaultTipFromUser()
        
        return true
    }
    
    func setDefaultTipFromUser() {
        // Save the user defined tip into UserDefaults
        
        let default_tip = defaultTip.text!.replacingOccurrences(of: "%", with: "")
        defaults.set(default_tip, forKey: "UserDefinedTip")
        
        // Force UserDefaults to save
        defaults.synchronize()
        
    }

    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
