//
//  SettingHeaderTableViewCell.swift
//  WalkMyDog
//
//  Created by κΉνν on 2021/04/04.
//

import UIKit

class SettingHeaderTableViewCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    
    func bindData(with title: String) {
        titleLabel.text = title
    }
}
