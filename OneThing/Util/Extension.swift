//
//  Extension.swift
//  Freedom
//
//  Created by Carl Henningsson on 2019-04-19.
//  Copyright © 2019 Carl Henningsson. All rights reserved.
//

import UIKit
import DeviceKit

typealias CompletionHandler = (_ success: Bool) -> ()

func textToImage(drawText text: String, inImage image: UIImage, atPoint point: CGPoint) -> UIImage {
    let textColor = yellow
    let textFont = UIFont(name: SansationBold, size: 56)!
    
    let scale = UIScreen.main.scale
    UIGraphicsBeginImageContextWithOptions(image.size, false, scale)
    
    let textFontAttributes = [
        NSAttributedString.Key.font: textFont,
        NSAttributedString.Key.foregroundColor: textColor,
        ] as [NSAttributedString.Key : Any]
    image.draw(in: CGRect(origin: CGPoint.zero, size: image.size))
    
    let rect = CGRect(origin: point, size: CGSize(width: image.size.width - 670, height: image.size.height))
    text.draw(in: rect, withAttributes: textFontAttributes)
    
    let newImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    return newImage!
}

func timestampToReadableData(date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd"
    
    let readableData = formatter.string(from: date)
    
    return readableData
}

func rearrange<T>(array: Array<T>, fromIndex: Int, toIndex: Int) -> Array<T>{
    var arr = array
    let element = arr.remove(at: fromIndex)
    arr.insert(element, at: toIndex)
    
    return arr
}

func numberFormatter(number: Double, style: NumberFormatter.Style) -> String {
    let numberFormatter = NumberFormatter()
    numberFormatter.numberStyle = style
    numberFormatter.locale = Locale.current
    numberFormatter.maximumFractionDigits = 2
    
    return numberFormatter.string(from: NSNumber(value: number))!
}

func randomString(length: Int) -> String {
    let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    return String((0..<length).map{ _ in letters.randomElement()! })
}

extension UITextField {
    func setLeftPaddingPoints(_ amount:CGFloat){
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.leftView = paddingView
        self.leftViewMode = .always
    }
    func setRightPaddingPoints(_ amount:CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.rightView = paddingView
        self.rightViewMode = .always
    }
}

extension String {
    func height(withConstrainedWidth width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [.font: font], context: nil)
        
        return ceil(boundingBox.height)
    }
    
    func width(withConstrainedHeight height: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [.font: font], context: nil)
        
        return ceil(boundingBox.width)
    }
}

extension UIView {
    
    func anchorToTop(_ top: NSLayoutYAxisAnchor? = nil, left: NSLayoutXAxisAnchor? = nil, bottom: NSLayoutYAxisAnchor? = nil, right: NSLayoutXAxisAnchor? = nil) {
        anchorWithConstantsToTop(top, left: left, bottom: bottom, right: right, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0)
    }
    
    func anchorWithConstantsToTop(_ top: NSLayoutYAxisAnchor? = nil, left: NSLayoutXAxisAnchor? = nil, bottom: NSLayoutYAxisAnchor? = nil, right: NSLayoutXAxisAnchor? = nil, topConstant: CGFloat = 0, leftConstant: CGFloat = 0, bottomConstant: CGFloat = 0, rightConstant: CGFloat = 0) {
        
        _ = anchor(top, left: left, bottom: bottom, right: right, topConstant: topConstant, leftConstant: leftConstant, bottomConstant: bottomConstant, rightConstant: rightConstant)
    }
    
    func anchor(_ top: NSLayoutYAxisAnchor? = nil, left: NSLayoutXAxisAnchor? = nil, bottom: NSLayoutYAxisAnchor? = nil, right: NSLayoutXAxisAnchor? = nil, topConstant: CGFloat = 0, leftConstant: CGFloat = 0, bottomConstant: CGFloat = 0, rightConstant: CGFloat = 0, widthConstant: CGFloat = 0, heightConstant: CGFloat = 0) -> [NSLayoutConstraint] {
        translatesAutoresizingMaskIntoConstraints = false
        
        var anchors = [NSLayoutConstraint]()
        
        if let top = top {
            anchors.append(topAnchor.constraint(equalTo: top, constant: topConstant))
        }
        
        if let left = left {
            anchors.append(leftAnchor.constraint(equalTo: left, constant: leftConstant))
        }
        
        if let bottom = bottom {
            anchors.append(bottomAnchor.constraint(equalTo: bottom, constant: -bottomConstant))
        }
        
        if let right = right {
            anchors.append(rightAnchor.constraint(equalTo: right, constant: -rightConstant))
        }
        
        if widthConstant > 0 {
            anchors.append(widthAnchor.constraint(equalToConstant: widthConstant))
        }
        
        if heightConstant > 0 {
            anchors.append(heightAnchor.constraint(equalToConstant: heightConstant))
        }
        
        anchors.forEach({$0.isActive = true})
        
        return anchors
    }
}

extension NSMutableAttributedString {
    public func setAsLink(textToFind:String, linkURL:String) -> Bool {
        let foundRange = self.mutableString.range(of: textToFind)
        if foundRange.location != NSNotFound {
            self.addAttribute(.link, value: linkURL, range: foundRange)
            return true
        }
        return false
    }
}

let groupOfSmalliPhones: [Device] = [.iPhoneSE, .iPhone5, .iPhone5c, .iPhone4s, .iPhone4, .iPodTouch6, .iPodTouch5]

//let deviceModel = UIDevice.modelName
//let iPadArray = ["iPad 2", "iPad 3", "iPad 4", "iPad Air", "iPad Air 2", "iPad 5", "iPad Mini", "iPad Mini 2", "iPad Mini 3", "iPad Mini 4", "iPad Pro 9.7 Inch", "iPad Pro 12.9 Inch", "iPad Pro 12.9 Inch 2. Generation", "iPad Pro 10.5 Inch", "iPad Pro (12.9-inch) (3rd generation)", "iPad Pro (11-inch)"]
//let iPhoneEight = ["iPhone 8 Plus", "iPhone 8", "iPhone 7 Plus", "iPhone 7", "iPhone 6s Plus", "iPhone 6s", "iPhone 6 Plus", "iPhone 6"]
//let iPhoneX = ["iPhone XR", "iPhone XS Max", "iPhone XS", "iPhone X"]
//let iPhoneSE = ["iPhone SE", "iPhone 5s", "iPhone 5c", "iPhone 5", "iPhone 4s", "iPhone 4", "iPod Touch 6", "iPod Touch 5"]
//
//public extension UIDevice {
//    
//    static let modelName: String = {
//        var systemInfo = utsname()
//        uname(&systemInfo)
//        let machineMirror = Mirror(reflecting: systemInfo.machine)
//        let identifier = machineMirror.children.reduce("") { identifier, element in
//            guard let value = element.value as? Int8, value != 0 else { return identifier }
//            return identifier + String(UnicodeScalar(UInt8(value)))
//        }
//        
//        func mapToDevice(identifier: String) -> String { // swiftlint:disable:this cyclomatic_complexity
//            #if os(iOS)
//            switch identifier {
//            case "iPod5,1":                                 return "iPod Touch 5"
//            case "iPod7,1":                                 return "iPod Touch 6"
//            case "iPhone3,1", "iPhone3,2", "iPhone3,3":     return "iPhone 4"
//            case "iPhone4,1":                               return "iPhone 4s"
//            case "iPhone5,1", "iPhone5,2":                  return "iPhone 5"
//            case "iPhone5,3", "iPhone5,4":                  return "iPhone 5c"
//            case "iPhone6,1", "iPhone6,2":                  return "iPhone 5s"
//            case "iPhone7,2":                               return "iPhone 6"
//            case "iPhone7,1":                               return "iPhone 6 Plus"
//            case "iPhone8,1":                               return "iPhone 6s"
//            case "iPhone8,2":                               return "iPhone 6s Plus"
//            case "iPhone9,1", "iPhone9,3":                  return "iPhone 7"
//            case "iPhone9,2", "iPhone9,4":                  return "iPhone 7 Plus"
//            case "iPhone8,4":                               return "iPhone SE"
//            case "iPhone10,1", "iPhone10,4":                return "iPhone 8"
//            case "iPhone10,2", "iPhone10,5":                return "iPhone 8 Plus"
//            case "iPhone10,3", "iPhone10,6":                return "iPhone X"
//            case "iPhone11,2":                              return "iPhone XS"
//            case "iPhone11,4", "iPhone11,6":                return "iPhone XS Max"
//            case "iPhone11,8":                              return "iPhone XR"
//            case "iPad2,1", "iPad2,2", "iPad2,3", "iPad2,4":return "iPad 2"
//            case "iPad3,1", "iPad3,2", "iPad3,3":           return "iPad 3"
//            case "iPad3,4", "iPad3,5", "iPad3,6":           return "iPad 4"
//            case "iPad4,1", "iPad4,2", "iPad4,3":           return "iPad Air"
//            case "iPad5,3", "iPad5,4":                      return "iPad Air 2"
//            case "iPad6,11", "iPad6,12":                    return "iPad 5"
//            case "iPad7,5", "iPad7,6":                      return "iPad 6"
//            case "iPad2,5", "iPad2,6", "iPad2,7":           return "iPad Mini"
//            case "iPad4,4", "iPad4,5", "iPad4,6":           return "iPad Mini 2"
//            case "iPad4,7", "iPad4,8", "iPad4,9":           return "iPad Mini 3"
//            case "iPad5,1", "iPad5,2":                      return "iPad Mini 4"
//            case "iPad6,3", "iPad6,4":                      return "iPad Pro (9.7-inch)"
//            case "iPad6,7", "iPad6,8":                      return "iPad Pro (12.9-inch)"
//            case "iPad7,1", "iPad7,2":                      return "iPad Pro (12.9-inch) (2nd generation)"
//            case "iPad7,3", "iPad7,4":                      return "iPad Pro (10.5-inch)"
//            case "iPad8,1", "iPad8,2", "iPad8,3", "iPad8,4":return "iPad Pro (11-inch)"
//            case "iPad8,5", "iPad8,6", "iPad8,7", "iPad8,8":return "iPad Pro (12.9-inch) (3rd generation)"
//            case "AppleTV5,3":                              return "Apple TV"
//            case "AppleTV6,2":                              return "Apple TV 4K"
//            case "AudioAccessory1,1":                       return "HomePod"
//            case "i386", "x86_64":                          return "Simulator \(mapToDevice(identifier: ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"] ?? "iOS"))"
//            default:                                        return identifier
//            }
//            #elseif os(tvOS)
//            switch identifier {
//            case "AppleTV5,3": return "Apple TV 4"
//            case "AppleTV6,2": return "Apple TV 4K"
//            case "i386", "x86_64": return "Simulator \(mapToDevice(identifier: ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"] ?? "tvOS"))"
//            default: return identifier
//            }
//            #endif
//        }
//        
//        return mapToDevice(identifier: identifier)
//    }()
//}
