//
//  LocationHelper.swift
//  LambdaTimeline
//
//  Created by De MicheliStefano on 18.10.18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import Foundation
import CoreLocation

class LocationHelper: NSObject, CLLocationManagerDelegate {
    
    // MARK: - Properties
    
    lazy var locationManager: CLLocationManager = {
        var result = CLLocationManager()
        result.delegate = self
        return result
    }()
    
    // MARK: - Public
    
    func requestAuthorization() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    func getLocation() -> CLLocation? {
        locationManager.requestLocation()
        return locationManager.location
    }
    
    // MARK: - CLLocationManagerDelegate
    
}
