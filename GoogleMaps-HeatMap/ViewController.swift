//
//  ViewController.swift
//  GoogleMaps-HeatMap
//
//  Created by 123456 on 7/7/20.
//  Copyright © 2020 123456. All rights reserved.
//

import UIKit
import GoogleMaps
import GoogleMapsUtils

class ViewController: UIViewController {

    var mapView:GMSMapView!
    var zoomLevel: Float = 15.0
    
    private var heatmapLayer: GMUHeatmapTileLayer!
    private var gradientColors = [UIColor.green, UIColor.red]
    private var gradientStartPoints = [0.2, 1.0] as [NSNumber]
    
    lazy var locationManager:CLLocationManager = CLLocationManager()
    var currentLocation:CLLocation!
    
    let timesSquareLocation = CLLocation(latitude: 40.7580, longitude: -73.9855)
    //timesSquare,grandcentral,empirestate building, flatiron, madison square park, union square, central park, chrysler building, herald square , bryant parl
    let fakeData:[CLLocationCoordinate2D] = [
            CLLocationCoordinate2D(latitude: 40.7580, longitude: -73.9855),
            CLLocationCoordinate2D(latitude: 40.7527, longitude: -73.9772),
            CLLocationCoordinate2D(latitude: 40.7484, longitude: -73.9857),
            CLLocationCoordinate2D(latitude: 40.7411, longitude: -73.9897),
            CLLocationCoordinate2D(latitude: 40.7425999, longitude: -73.9877701),
            CLLocationCoordinate2D(latitude: 40.7359, longitude: -73.9911),
            CLLocationCoordinate2D(latitude: 40.7812, longitude: -73.9665),
            CLLocationCoordinate2D(latitude: 40.7516, longitude: -73.9755),
            CLLocationCoordinate2D(latitude: 40.7502, longitude: -73.9877),
            CLLocationCoordinate2D(latitude: 40.7536, longitude: 73.9832)]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        let camera = GMSCameraPosition.camera(withLatitude: timesSquareLocation.coordinate.latitude, longitude: timesSquareLocation.coordinate.longitude, zoom: zoomLevel)
        
        mapView = GMSMapView(frame: view.bounds, camera: camera)
        
        mapView.translatesAutoresizingMaskIntoConstraints = false
        mapView.isMyLocationEnabled = true
        mapView.settings.myLocationButton = true
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        self.view.addSubview(mapView)
        
        NSLayoutConstraint.activate([
            mapView.topAnchor.constraint(equalTo: view.topAnchor),
            mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        // Initialize the location manager.
        locationManager = CLLocationManager()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.distanceFilter = 50
        locationManager.startUpdatingLocation()
        locationManager.delegate = self
        
       heatmapLayer = GMUHeatmapTileLayer()
        heatmapLayer.radius = 80
        heatmapLayer.opacity = 0.8
        heatmapLayer.gradient = GMUGradient(colors: gradientColors,
                                            startPoints: gradientStartPoints,
                                            colorMapSize: 256)
        addHeatMap()
        heatmapLayer.map = mapView
        
    }
    
    func addHeatMap(){
        //eventually put code here to pull from server
        var list = [GMUWeightedLatLng]()
        // Add the latlngs to the heatmap layer.
        
        for data in fakeData{
            let intensity = Float.random(in: 2000...100000)
            print("intensity: \(intensity), coordinate: \(data)")
            let coords = GMUWeightedLatLng(coordinate: data, intensity: intensity)
            list.append(coords)
        }
         heatmapLayer.weightedData = list
    }


}

extension ViewController:CLLocationManagerDelegate{
    // Handle incoming location events.
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
      let location: CLLocation = locations.last!
      print("Location: \(location)")

      let camera = GMSCameraPosition.camera(withLatitude: location.coordinate.latitude,
                                            longitude: location.coordinate.longitude,
                                            zoom: zoomLevel)

      if mapView.isHidden {
        mapView.isHidden = false
        mapView.camera = camera
      } else {
        mapView.animate(to: camera)
      }
    }
    
    // Handle authorization for the location manager.
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
      switch status {
      case .restricted:
        print("Location access was restricted.")
      case .denied:
        print("User denied access to location.")
        // Display the map using the default location.
        mapView.isHidden = false
      case .notDetermined:
        print("Location status not determined.")
      case .authorizedAlways: fallthrough
      case .authorizedWhenInUse:
        print("Location status is OK.")
      @unknown default:
        fatalError()
      }
    }
    
    // Handle location manager errors.
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
      locationManager.stopUpdatingLocation()
      print("Error: \(error)")
    }
}
