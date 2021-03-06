//
//  PuppyModel.swift
//  WalkMyDog
//
//  Created by κΉνν on 2021/02/05.
//  

import Foundation

protocol Identifiable {
    var id: String? { get set }
}

struct Puppy: Codable, Identifiable {
    var id: String? = nil
    var name: String
    var age: String
    var gender: Bool
    var weight: Double
    var species: String
    var imageUrl: String?
    
    init(name: String, age: String, gender: Bool, weight: Double, species: String) {
        self.name = name
        self.age = age
        self.gender = gender
        self.weight = weight
        self.species = species
    }
}

struct Record: Codable, Identifiable {
    var id: String? = nil
    let timeStamp: String
    let walkInterval: String
    let walkDistance: String
    let walkCalories: Double
    
    init(timeStamp: String, walkInterval: String, walkDistance: String, walkCalories: Double) {
        self.timeStamp = timeStamp
        self.walkInterval = walkInterval
        self.walkDistance = walkDistance
        self.walkCalories = walkCalories
    }
}
