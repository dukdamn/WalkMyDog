//
//  ViewModelType.swift
//  WalkMyDog
//
//  Created by κΉνν on 2021/02/16.
//

import Foundation
import RxSwift

protocol ViewModelType {
    associatedtype Input
    associatedtype Output
    
    var bag: DisposeBag { get set }
}
