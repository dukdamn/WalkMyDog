//
//  CheckButton.swift
//  WalkMyDog
//
//  Created by κΉνν on 2021/03/05.
//

import UIKit

class CheckButton: UIButton {
    
    let checkedImage = UIImage(systemName: "checkmark.circle.fill")?.resized(to: CGSize(width: 25, height: 25)).withTintColor(UIColor(named: "customTintColor")!)
    let uncheckedImage = UIImage(systemName: "circle")?.resized(to: CGSize(width: 25, height: 25)).withTintColor(UIColor(named: "customTintColor")!)
    
    
    var isChecked: Bool = false {
        didSet {
            if isChecked == true {
                self.setImage(checkedImage, for: .normal)
            } else {
                self.setImage(uncheckedImage, for: .normal)
            }
        }
    }
    
    override func awakeFromNib() {
        self.isChecked = false
        self.addTarget(self, action: #selector(buttonTapped(sender:)), for: .touchUpInside)
    }
    
    @objc
    func buttonTapped(sender: UIButton) {
        if sender == self {
            isChecked = !isChecked
        }
    }
}
