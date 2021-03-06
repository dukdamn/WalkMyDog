//
//  UIImage.swift
//  WalkMyDog
//
//  Created by κΉνν on 2021/03/09.
//

import Foundation
import UIKit

extension UIImage {
    func resized(to newSize: CGSize) -> UIImage {
        return UIGraphicsImageRenderer(size: newSize).image { _ in
            draw(in: CGRect(origin: .zero, size: newSize))
        }
    }
}
