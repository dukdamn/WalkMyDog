//
//  PuppyTableViewCell.swift
//  WalkMyDog
//
//  Created by κΉνν on 2021/02/21.
//

import UIKit

class PuppyTableViewCell: UITableViewCell {

    @IBOutlet weak var puppyNameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.selectionStyle = .none
    }
    
    func bindData(with data: Puppy) {
        puppyNameLabel.text = data.name
    }
}
