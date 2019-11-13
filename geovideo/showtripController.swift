//
//  File.swift
//  geovideo
//
//  Created by Vish Patel on 7/30/19.
//  Copyright © 2019 kent state university. All rights reserved.
//

import UIKit
import MapKit
import SQLite3
import AVFoundation
import AVKit




class showtripController: UIViewController,MKMapViewDelegate {
   
    var idofvide = 0
    var videourl = ""
 var db1 : OpaquePointer?
    override func viewDidLoad() {
        super.viewDidLoad()
        //addAnnotations()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
         testcoords = []
        query()
        playVideo()
    }
    @IBOutlet weak var map: MKMapView!
    var testcoords:[CLLocationCoordinate2D] = []
    func query() {
    testcoords = []
        let fileurl = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent("geoVideoDatabase121.sqlite")
        if sqlite3_open(fileurl.path,&db1) != SQLITE_OK{
            print("error")
            return
        }
        
        let queryStatementString = "SELECT * FROM UserLocation where videoid = \(idofvide)"
        var queryStatement: OpaquePointer? = nil
        // 1
        var latmin:Double = 90
        var latmax:Double = -90
        var longmin:Double = 180
        var longmax:Double = -180
        
        if sqlite3_prepare_v2(db1, queryStatementString, -1, &queryStatement, nil) == SQLITE_OK {
            // 2
            while sqlite3_step(queryStatement) == SQLITE_ROW {

                let queryResultCol1 = sqlite3_column_double(queryStatement, 1)
                let queryResultCol2 = sqlite3_column_double(queryStatement, 2)
               // let queryResultCol3 = sqlite3_column_int(queryStatement,3)
                
                if(queryResultCol1 < latmin)
                {
                    latmin = queryResultCol1
                }
                if(queryResultCol1 > latmax)
                {
                    latmax = queryResultCol1
                }
                if(queryResultCol2 < longmin)
                {
                    longmin = queryResultCol2
                }
                if(queryResultCol2 > longmax)
                {
                    longmax = queryResultCol2
                }
              //  print(queryResultCol3);
                
                testcoords.append(CLLocationCoordinate2D(latitude:queryResultCol1 , longitude: queryResultCol2))
            }
        } else {
            print("SELECT statement could not be prepared")
        }
        
        // 6
        sqlite3_finalize(queryStatement)
        if(testcoords.count > 0 )
        {
        let testline = MKPolyline(coordinates: testcoords, count: testcoords.count)
        //Add `MKPolyLine` as an overlay.
        map.addOverlay(testline)
        var centerofallcoord = CLLocationCoordinate2D(latitude: (latmax + latmin)/2, longitude: (longmax + longmin)/2)
        map.delegate = self as MKMapViewDelegate
        
        map.centerCoordinate = testcoords[0]
    
        let region = MKCoordinateRegion(center: centerofallcoord, span: MKCoordinateSpan(latitudeDelta: (latmax - latmin)+0.0005, longitudeDelta: (longmax - longmin)+0.0005))
        
        map.setRegion(region, animated: true)
        }
    }
    private let myAnnotation = mypointAnnotation()
    func mapanimation()
    {
       
        
        if(testcoords.count > 0)
        {
        myAnnotation.coordinate = testcoords[0]
        myAnnotation.pinTintcolor = .red
        map.addAnnotation(myAnnotation)
        let startannotation = mypointAnnotation()
               
        startannotation.coordinate = testcoords[0]
        startannotation.pinTintcolor = .green
        map.addAnnotation(startannotation)
        let endanotation = mypointAnnotation()
        endanotation.coordinate = testcoords[testcoords.count - 1]
        endanotation.pinTintcolor = .red
        map.addAnnotation(endanotation)
        weak var timer: Timer?
         var i = 0
     
            // Set timer to run after 5 seconds.
            timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
                // Set animation to last 4 seconds.
                
                UIView.animate(withDuration: 1, animations: {
                    // Update annotation coordinate to be the destination coordinate
                    self.myAnnotation.coordinate = self.testcoords[i]
                    if(i < (self.testcoords.count - 1) )
                    {
                        i  += 1
                    }
                    else
                    {
                        timer.invalidate()
                    }
                }, completion: nil)
               
            
        }
        }
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        //Return an `MKPolylineRenderer` for the `MKPolyline` in the `MKMapViewDelegate`s method
        if let polyline = overlay as? MKPolyline {
            let testlineRenderer = MKPolylineRenderer(polyline: polyline)
            testlineRenderer.strokeColor = .blue
            testlineRenderer.lineWidth = 5.0
            return testlineRenderer
        }
        fatalError("Something wrong...")
        //return MKOverlayRenderer()
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "myAnnotation") as? MKPinAnnotationView

        if annotationView == nil {
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "myAnnotation")
        } else {
            annotationView?.annotation = annotation
        }

        if let annotation = annotation as? mypointAnnotation {
            annotationView?.pinTintColor = annotation.pinTintcolor
        }

        return annotationView
    }
    
    var player : AVPlayer? = nil
    
    @IBOutlet weak var videofream: UIView!
    func playVideo() {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentdirec = paths[0]
        let videopath = documentdirec + "/" + videourl
        
        let fileurl = URL(fileURLWithPath: videopath)
        // Create an AVPlayer, passing it the HTTP Live Streaming URL.
         player = AVPlayer(url: fileurl) // your video url
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame =  self.videofream.bounds
        playerLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        videofream.layer.addSublayer(playerLayer)
        player!.play()
        mapanimation()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
            player!.pause()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "gotowebview")
        {
            let info = segue.destination as! webviewViewController
            info.idofvide = idofvide
            info.videourl = videourl
        }
    }

}
class mypointAnnotation : MKPointAnnotation
{
    var pinTintcolor : UIColor?
}
