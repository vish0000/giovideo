//
//  ViewController.swift
//  geovideo
//
//  Created by Vish Patel on 7/29/19.
//  Copyright © 2019 kent state university. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation 
import AVKit
import MobileCoreServices
import AVFoundation

class ViewController: UIViewController,CLLocationManagerDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate {

 
    @IBOutlet weak var recodeNewVideo: UIButton!
    @IBOutlet weak var showAllVideoButton: MKMapView!
    @IBOutlet weak var map: MKMapView!
    let manager = CLLocationManager()


    override func viewDidLoad() {
        
        super.viewDidLoad()
        UIApplication.shared.isIdleTimerDisabled = true
    //    map.bringSubviewToFront(showAllVideoButton)
  //      map.bringSubviewToFront(recodeNewVideo)
        manager.delegate = self
        manager.desiredAccuracy=kCLLocationAccuracyBest
        manager.requestWhenInUseAuthorization()
        
        manager.startUpdatingLocation()
        // Do any additional setup after loading the view.
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let location = locations[0];
        
        let span:MKCoordinateSpan = MKCoordinateSpan(latitudeDelta: 0.01,longitudeDelta: 0.01)
        let mylocation:CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        let region: MKCoordinateRegion = MKCoordinateRegion(center: mylocation, span: span)
        map.setRegion(region, animated: true)
        self.map.showsUserLocation = true;
      
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
}

