//
//  Constants.swift
//  Tip Calc 3000
//
//  Created by Giovanni Propersi on 1/29/22.
//  Hardcoded strings stored here.

import Foundation
import UIKit

struct Constants {
    
    struct Storyboard {
        
        static let userDefinedTip = "UserDefinedTip"
        static let userDefinedMax = "UserDefinedMax"
        static let userDefinedAppearance = "UserDefinedAppearance"
        static let viewMode: [String : UIUserInterfaceStyle] = [
                                "Dark": .dark,
                                "Light" : .light
                                ]
        static let lastBillTimeKey = "LastBillTime"
        static let lastBill = "LastBill"
        static let lastBillDecimal = "LastBillDecimal"
        static let textColorLightMode : UIColor = UIColor.init(red: -0.027515370398759842, green: 0.32696807384490967,                                               blue: -0.07128610461950302, alpha: 1.0)
        static let textColorDarkMode : UIColor = UIColor.systemGreen
        static let sliderSetting = "SliderSetting"
        static let emptyBill = "EmptyBill"
        static let changedScreens = "ChangedScreens"
        static let currencySelection = "CurrencySelection"
        static let originalMargin = "OriginalMargin"
    }
}
