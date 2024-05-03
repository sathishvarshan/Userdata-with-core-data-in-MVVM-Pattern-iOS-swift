//
//  Extensions.swift
//  LocalData
//
//  Created by Sathish on 29/04/24.
//

import Foundation
import UIKit

extension UIView{
    
    func roundView(){
        self.layer.cornerRadius = self.frame.size.height/2
        self.clipsToBounds = true
    }
    
    func setBorder(value: CGFloat){
        self.layer.borderWidth = value
        self.layer.borderColor = UIColor.blue.cgColor
    }
    
}
