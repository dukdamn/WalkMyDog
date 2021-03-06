//
//  LocationManager.swift
//  WalkMyDog
//
//  Created by κΉνν on 2021/02/16.
//

import Foundation
import RxCocoa
import RxSwift
import RxCoreLocation
import CoreLocation

final public class LocationManager {
    // MARK: - Properties
    static let shared = LocationManager()
    private let locationManager = CLLocationManager()
    private (set) var location = ReplaySubject<CLLocation>.create(bufferSize: 3)
    private (set) var placemark = ReplaySubject<CLPlacemark>.create(bufferSize: 3)
    private (set) var authorizedStatus = PublishSubject<Bool>()
    private var bag = DisposeBag()
    
    // MARK: - Initializer
    private init() {
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        
        locationManager.rx
            .didChangeAuthorization
            .subscribe(onNext: { [weak self] _, status in
                switch status {
                case .denied:
                    self?.authorizedStatus.onNext(false)
                case .notDetermined:
                    self?.locationManager.requestWhenInUseAuthorization()
                    self?.authorizedStatus.onNext(false)
                case .restricted:
                    self?.authorizedStatus.onNext(false)
                case .authorizedAlways, .authorizedWhenInUse:
                    self?.authorizedStatus.onNext(true)
                    self?.authorizedStatus.onCompleted()
                @unknown default:
                    print("Dev Alert: Unknown case of status in handleAuth\(status)")
                }
            })
            .disposed(by: bag)
        
        locationManager.rx
            .placemark
            .subscribe(onNext: { [weak self] placemark in
                self?.placemark.onNext(placemark)
            })
            .disposed(by: bag)
        
        locationManager.rx
            .location
            .subscribe(onNext: { [weak self] location in
                self?.locationManager.stopUpdatingLocation()
                guard let location = location else { return }
                self?.location.onNext(location)
            })
            .disposed(by: bag)
        
        requestAuthroization()
        locationManager.startUpdatingLocation()
    }

    // MARK: - Methods
    func requestAuthroization() {
        locationManager.requestWhenInUseAuthorization()
    }
}
