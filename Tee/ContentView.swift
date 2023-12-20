//
//  ContentView.swift
//  Tee
//
//  Created by Dylan Elliott on 26/11/2023.
//

import SwiftUI
import CoreLocation
import DylKit

struct AddressRow {
    let title: String
    let value: String
    let showTitle: Bool
}

extension Array where Element == AddressRow {
    var untitledRows: [AddressRow] { filter { !$0.showTitle } }
    var titledRows: [AddressRow] { filter { $0.showTitle } }
}

class ContentViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    let locationManager: LocationManager
    let geocoder: CLGeocoder = .init()
    
    @Published var rows: [AddressRow]
    @Published var hasLocationPermission: Bool
    var hasRequestedLocation: Bool { locationManager.authorizationStatus != .notDetermined}
    
    override init() {
        self.locationManager = .init()
        self.rows = []
        self.hasLocationPermission = locationManager.authorized
        super.init()
        locationManager.delegate = self
    }
    
    func onAppear() {
        if locationManager.authorized {
            locationManager.startUpdatingLocation()
        } else {
            locationManager.requestWhenInUseAuthorization()
        }
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        hasLocationPermission = locationManager.authorized
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        geocoder.reverseGeocodeLocation(location, completionHandler: { placemarks, error in
            placemarks?.forEach { placemark in
                let values: [(String, String?, Bool)] = [
                    ("name", placemark.nameIfDifferentFromThoroughfare, false),
                    ("subThoroughfare", placemark.subThoroughfare, false),
                    ("thoroughfare", placemark.thoroughfare, false),
                    ("locality", placemark.locality, false),
                    ("administrativeArea", placemark.administrativeArea, false),
                    ("postalCode", placemark.postalCode, false),
                    ("country", placemark.country, false),
                    ("Inland Water", placemark.inlandWater, true),
                    ("Ocean", placemark.ocean, true),
                    ("Areas of Interest", placemark.areasOfInterest?.joined(), true),
                    ("Sub-Locality", placemark.subLocality, true),
                    ("Sub-Administrative Area", placemark.subAdministrativeArea, true),
                ]
                
                self.rows = values.compactMap {
                    guard let value = $0.1 else { return nil }
                    return .init(title: $0.0, value: value, showTitle: $0.2)
                }
            }
        })
    }
}

struct ContentView: View {
    @StateObject var viewModel: ContentViewModel = .init()
    var body: some View {
        ZStack {
            Rectangle().foregroundColor(Color.rainbowColors[0]).ignoresSafeArea()
            if !viewModel.hasRequestedLocation  {
                
            } else if !viewModel.hasLocationPermission{
                Text("""
                You have denied location access for this app
                
                This app requires your location in order to function
                
                Enable location in Settings to use this app
                """)
                .font(.largeTitle.weight(.semibold).italic())
                .multilineTextAlignment(.center)
                .padding(30)
            } else if viewModel.rows.isEmpty {
                ProgressView().progressViewStyle(.circular)
            } else {
                VStack(spacing: 0) {
                    Rectangle().foregroundColor(Color.rainbowColors[0])
                    Rectangle().foregroundColor(Color.rainbowColors[looping: viewModel.rows.lastIndex ?? 0])
                }
                .ignoresSafeArea()
                GeometryReader { geometry in
                    ScrollView {
                        VStack(spacing: 0) {
                            ForEach(enumerated: viewModel.rows.untitledRows) { (index, row) in
                                self.row(row, index: index)
                            }
                            .frame(
                                minHeight: geometry.size.height / CGFloat(viewModel.rows.untitledRows.count)
                            )
                            
                            ForEach(enumerated: viewModel.rows.titledRows) { (index, row) in
                                self.row(row, index: viewModel.rows.untitledRows.count + index)
                            }
                            .frame(
                                minHeight: geometry.size.height / CGFloat(viewModel.rows.untitledRows.count)
                            )
                        }
                    }
                }
            }
        }
        .onAppear(perform: {
            viewModel.onAppear()
        })
    }
    
    private func row(_ row: AddressRow, index: Int) -> some View {
        VStack(alignment: .center) {
            Spacer()
            if row.showTitle {
                Text(row.title).font(.footnote).bold()
            }
            Text(row.value).font(.largeTitle).bold()
            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.rainbowColors[looping: index])
    }
}

#Preview {
    ContentView()
}

extension CLPlacemark {
    var fullThoroughfare: String? {
        guard let thoroughfare = thoroughfare, let subthoroughfare = subThoroughfare else { return nil }
        return "\(subthoroughfare) \(thoroughfare)"
    }
    
    var nameIfDifferentFromThoroughfare: String? {
        let name = name
        let fullThoroughfare = fullThoroughfare
        return name != fullThoroughfare ? name : nil
    }
}

extension CLAuthorizationStatus {
    var authorized: Bool {
        return [.authorizedAlways, .authorizedWhenInUse].contains(self)
    }
}

extension CLLocationManager {
    var authorized: Bool {
        return authorizationStatus.authorized
    }
}
