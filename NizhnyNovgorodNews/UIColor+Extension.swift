//
//  UIColor+Extension.swift
//  iTunesProject
//
//  Created by Anton on 11.10.18.
//  Copyright © 2018 iTunesProject_App. All rights reserved.
//

import UIKit

extension UIColor {

    //Gray sideMenu color   -   FBF7F5
    
    //Krasnoyarsk           -   f81000
    //Saint Petersburg      -   0095da
    //Novosibirsk           -   18537e
    //Yekaterinburg         -   e9b400
    //Nijnii Novgorod       -   cd201a
    
    class func color_redMain() -> UIColor {
        return hexStringToUIColor("#914853")
    }
    
    class func color_grayMain() -> UIColor {
        return hexStringToUIColor("#cbcbcb")
    }
    
    class func color_grayDark() -> UIColor {
        return hexStringToUIColor("#959595")
    }
    
    class func color_lightGrayMain() -> UIColor {
        return hexStringToUIColor("#ebebeb")
    }
    
    class func hexStringToUIColor(_ hex:String) -> UIColor {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }
        if ((cString.count) != 6) {
            return UIColor.gray
        }
        var rgbValue:UInt32 = 0
        Scanner(string: cString).scanHexInt32(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
}
