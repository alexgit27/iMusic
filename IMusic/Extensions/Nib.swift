//
//  Nib.swift
//  IMusic
//
//  Created by Alexandr on 30.03.2021.
//

import UIKit

extension UIView {
    class func loadFromNib<T: UIView>() -> T {
        return Bundle.main.loadNibNamed(String(describing: T.self), owner: nil, options: nil)![0] as! T
    }
}
