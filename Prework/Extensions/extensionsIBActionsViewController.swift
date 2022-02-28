//
//  extensionsViewController.swift
//  Tip Calc 3000
//
//  Created by Giovanni Propersi on 1/30/22.
//  Extension for ViewController that includes all IBActions.

import UIKit

// MARK: - IBActions, ViewController
extension ViewController {
    @IBAction func getTipPerc(_ slider: UISlider) {
        // Capture the user chosen percentage from the slider
        // Recalculates tip/bill based on new chosen tip percentage
        // Sets slider to rounded value so it 'clicks' into place
        
        let smoothSliderSetting = defaults.bool(forKey: Constants.Storyboard.sliderSetting)
        let sliderRoundedTip = Int(round(tipPercentSlider.value * 100))
        
        if !smoothSliderSetting {
            tipPercentSlider.value = Float(sliderRoundedTip) / 100.0
        }
        tipPercentOutput.setTipPercentOutput(sliderRoundedTip)
        
        let lastBill = convertToDecimalFromCurrency(billAmountTextField.text!)

        calculateTip(lastBill)
    }
    
    @IBAction func validateBillInputs(_ textField: UITextField) {
        // Calculates the tip based on the total Bill and selected tip amount. Responds directly to editing of the bill amount.
        
        let currencyFormatter: NumberFormatter = getCurrencyFormatter()

        let currencySymbol: String = currencyFormatter.currencySymbol
        let decimalSymbol: String = currencyFormatter.decimalSeparator
        let groupingSymbol: String = currencyFormatter.groupingSeparator
        
        let everythingIsHidden = defaults.bool(forKey: Constants.Storyboard.emptyBill)
        let lastEnteredBillString = defaults.string(forKey: Constants.Storyboard.lastBill) ?? convertDecimalToCurrencyString(0.0)
        let lastEnteredBillDecimalAsString = defaults.string(forKey: Constants.Storyboard.lastBillDecimal) ?? "0.0"
        let lastEnteredBillDecimal = Decimal(string: lastEnteredBillDecimalAsString)!

        var billAmount = billAmountTextField.text!
        
        let containsInvalidChars : Bool = validateCharactersAreCurrencyOnly(billAmount, currencySymbol, decimalSymbol, groupingSymbol)
        
        // Validate inputs for currency values
        guard !containsInvalidChars else {
            billAmountTextField.text = convertDecimalToCurrencyString(lastEnteredBillDecimal)
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
        var billAmountToDecimal: Decimal = Decimal(string: billAmount) ?? 0.0
        
        if userPressedDelete && billAmount.contains(decimalSymbol){
            // Slide digits over one to the right
            billAmountToDecimal /= 10
        }
        
        else if lastEnteredBillDecimal == billAmountToDecimal {
            // Slide digits over to the left
                // Off chance that user switches to a currency that doesn't use decimals.
                // Delete would then multiply by 10 instead since previous bill would've been
                // longer. i.e. YEN 10000 is shorter than $10000.00, so deleting with locale as
                // USD would make it $100000.00
            if billAmount.count > lastEnteredBillDecimalAsString.count {
                // Occurs when user adds a 0, so shift values to left
                billAmountToDecimal *= 10
            }
            else {
                billAmountToDecimal /= 10
            }
        }
                
        else if billAmount.contains(decimalSymbol) {
            // Certain currencies contain no decimal, just shift over
            billAmountToDecimal *= 10
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
}
