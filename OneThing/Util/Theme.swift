//
//  Theme.swift
//  OneThing
//
//  Created by Carl Henningsson on 2019-06-19.
//  Copyright © 2019 Carl Henningsson. All rights reserved.
//

import UIKit

protocol ThemeProtocal {
    var mainTextColor: UIColor { get }
    var subTextColor: UIColor { get }
    var backgroundColor: UIColor { get }
    var shadowColor: UIColor { get }
}

class Theme {
    static var isDarkMode: Bool = false
    static var currentTheme: ThemeProtocal = LightTheme()
}

class LightTheme: ThemeProtocal {
    var mainTextColor: UIColor = .black
    var subTextColor: UIColor = .lightGray
    var backgroundColor: UIColor = .white
    var shadowColor: UIColor = .black
}

class DarkTheme: ThemeProtocal {
    var mainTextColor: UIColor = .white
    var subTextColor: UIColor = .lightGray
    var backgroundColor: UIColor = darkModeBackgroundColor
    var shadowColor: UIColor = .white
}
