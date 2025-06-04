//
//  LocationManager.swift
//  Tee
//
//  Created by Dylan Elliott on 27/11/2023.
//

import CoreLocation

class LocationManager {
    private var isTests: Bool { ProcessInfo.processInfo.arguments.contains("testMode") }
    let locationManager: CLLocationManager
    var delegate: CLLocationManagerDelegate? {
        get { locationManager.delegate }
        set { locationManager.delegate = newValue }
    }
    
    init() {
        let locationManager =  CLLocationManager()
        self.locationManager = locationManager
    }
    var authorizationStatus: CLAuthorizationStatus {
        isTests ? .authorizedAlways : locationManager.authorizationStatus
    }
    
    var authorized: Bool {
        authorizationStatus.authorized
    }
    
    func requestWhenInUseAuthorization() {
        if !isTests {
            locationManager.requestWhenInUseAuthorization()
        } else {
            locationManager.delegate?.locationManagerDidChangeAuthorization?(locationManager)
        }
    }
    
    func startUpdatingLocation() {
        if !isTests {
            locationManager.startUpdatingLocation()
        } else {
            locationManager.delegate?.locationManager?(locationManager, didUpdateLocations: [
                .init(latitude: 37.334606, longitude: -122.009102)
            ])
        }
    }
}

