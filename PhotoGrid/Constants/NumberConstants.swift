//
//  Constants.swift
//  PhotoGrid
//
//  Created by Saggy on 09/01/24.
//

import Foundation

enum APIConstants {
    static let endpoint = "https://jsonblob.com/api/jsonBlob/1182735235283804160"
}

enum AlertConstants {
    static let messageBody = "Failed to fetch photo"
    static let okButton = "OK"
    static let title = "Error"
}

enum NumberConstants {
    static let minimumInteritemSpacing: CGFloat         = 5
    static let imageResizePercentage: CGFloat           = 0.09
    static let photoGridColumnCount: CGFloat             = 3
    static let minimumLineSpacing: CGFloat                 = 5
    static let photoWidth: CGFloat                                 = 20
    static let titleLabelFontSize: CGFloat                       = 25
    
}

enum StringConstants {
    static let dateFormat = "MMM d, yyyy"
    static let fatalError = "init(coder:) has not been implemented"
}


enum AccessibilityConstants {
    static let fullImageView         = "FullImageView"
}
