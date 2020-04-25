//
//  Extensions.swift
//  ToDoApp
//
//  Created by Phoenix McKnight on 4/21/20.
//  Copyright © 2020 Phoenix McKnight. All rights reserved.
//

import UIKit

extension Date {
    
    public func returnCurrentDate() -> String {
       
              let formatter = DateFormatter()
              formatter.dateFormat = "MM/dd/yyyy"
              return formatter.string(from: self)
    }
}
extension UIView {
func setGradientBackground(colorTop: UIColor, colorBottom: UIColor) {
    let gradientLayer = CAGradientLayer()
    gradientLayer.colors = [colorBottom.cgColor, colorTop.cgColor]
    gradientLayer.startPoint = CGPoint(x: 0.0, y: 1.0)
    gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.0)
    gradientLayer.locations = [0, 1]
    gradientLayer.frame = self.bounds
    
    self.layer.insertSublayer(gradientLayer, at: 0)
}
}

extension UITableViewCell {
    public func cellAnimation(indexPath:IndexPath) {
           self.alpha = 0.0
                   self.transform = CGAffineTransform(scaleX: 0, y: 0).translatedBy(x: self.contentView.frame.width / 2, y: 0)
                   UIView.animate(
                       withDuration: 1.0,
                       delay: 0.5 * Double(indexPath.row),
                       animations: {
                           self.alpha = 1
                           self.transform = .identity
                   })
       }
}

extension UIToolbar {
    public func createToolBar(textField:UITextField,doneButton:UIBarButtonItem) -> UIToolbar {
        
        
             let toolbar =  UIToolbar(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: (textField.inputView?.frame.width)!, height: CGFloat(44))))
           
           toolbar.barStyle = UIBarStyle.black
           toolbar.isTranslucent = true
           
           
           let leftFlexSpaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
           
           let rightFlexSpaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
           toolbar.setItems([leftFlexSpaceButton, doneButton,rightFlexSpaceButton], animated: true)
           toolbar.isUserInteractionEnabled = true
           toolbar.sizeToFit()
           return toolbar
       }
}
