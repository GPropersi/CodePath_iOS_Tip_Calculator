//
//  extensionsForCurrency.swift
//  Tip Calc 3000
//
//
//  Created by Giovanni Propersi on 1/30/22.
//  Extension functions for converting between decimal and currency (string) values.

import UIKit

extension ViewController {
    // MARK: - Helper functions to convert between string currency and decimal values
    func getCurrencyFormatter() -> NumberFormatter {
        // Returns a formatter for currency
        let currencyFormatter = NumberFormatter()
        currencyFormatter.usesGroupingSeparator = true
        currencyFormatter.numberStyle = .currency
        // Localize
        currencyFormatter.currencyCode = defaults.string(forKey: Constants.Storyboard.currencySelection)
        return currencyFormatter
    }
    
    func convertDecimalToCurrencyString(_ input: Decimal) -> String {
        // Converts decimal to string using currencyFormatter
        let currencyFormatter = getCurrencyFormatter()
        
        return currencyFormatter.string(from: NSDecimalNumber(decimal: input))!
    }
    
    func convertToDecimalFromCurrency(_ stringInput: String) -> Decimal {
        // Converts from currency to decimal
        let currencyFormatter: NumberFormatter = getCurrencyFormatter()
        
        let currencySymbol: String = currencyFormatter.currencySymbol
        let groupingSymbol: String = currencyFormatter.groupingSeparator
        
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
}
