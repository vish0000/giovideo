//
//  newViewController.swift
//  geovideo
//
//  Created by Vish Patel on 8/14/19.
//  Copyright © 2019 kent state university. All rights reserved.
//

import UIKit
import AVFoundation
import SQLite3
import CoreLocation
import MapKit
import CoreServices
import MapKit

class newViewController: UIViewController,CLLocationManagerDelegate,UINavigationControllerDelegate,AVCaptureFileOutputRecordingDelegate {

   @IBOutlet weak var timingLabel: UILabel!
    @IBOutlet weak var camPreview: UIView!
    
    @IBOutlet weak var rollingButton: UIButton!
    let cameraButton = UIView()
    
    let captureSession = AVCaptureSession()
    
    let movieOutput = AVCaptureMovieFileOutput()
    
    var previewLayer = AVCaptureVideoPreviewLayer()
    
    var activeInput: AVCaptureDeviceInput!
    var videoCaptureDevice : AVCaptureDevice?
    var outputURL: URL!
    
    var videourl = ""
    var db : OpaquePointer?
    let manager = CLLocationManager()
    var videoid  = 1
    var isstartrecoding = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(appMovedToinactive), name: UIApplication.willResignActiveNotification, object: nil)
        
        
        camPreview.bringSubviewToFront(timingLabel)
        camPreview.bringSubviewToFront(rollingButton)
        createDataBase()
      
        manager.delegate = self
        manager.desiredAccuracy=kCLLocationAccuracyBest
        manager.requestWhenInUseAuthorization()
 
 avCaptureVideoSetUp()
        
    }
    func avCaptureVideoSetUp(){
        
        if let devices = AVCaptureDevice.devices(for: AVMediaType.video) as? [AVCaptureDevice] {
            for device in devices {
                if device.hasMediaType(AVMediaType.video) {
                    if device .position == AVCaptureDevice.Position.back{
                        videoCaptureDevice = device
                    }
                }
            }
            if videoCaptureDevice != nil {
                do {
                    // Add Video Input
                    try self.captureSession.addInput(AVCaptureDeviceInput(device: videoCaptureDevice!))
                    // Get Audio Device
                    let audioInput = AVCaptureDevice.default(for: AVMediaType.audio)
                    //Add Audio Input
                    try self.captureSession.addInput(AVCaptureDeviceInput(device: audioInput!))
                    self.previewLayer = AVCaptureVideoPreviewLayer(session: self.captureSession)
                    previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
                    previewLayer.connection!.videoOrientation = AVCaptureVideoOrientation.portrait
                    self.camPreview.layer.addSublayer(self.previewLayer)
                    //Add File Output
                    self.captureSession.addOutput(self.movieOutput)
                    captureSession.startRunning()
                }catch {
                    print(error)
                }
            }
            else{
                print("no device for recoding")
                self.performSegue(withIdentifier: "backtomainview", sender: nil)
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let bounds: CGRect = camPreview.layer.bounds
        previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        previewLayer.bounds = bounds
        previewLayer.position = CGPoint(x: bounds.midX, y: bounds.midY)
    }
    
    @IBAction func recordVideoAction(_ sender: UIButton) {
        if movieOutput.isRecording {
             rollingButton.backgroundColor = UIColor.gray
             rollingButton.setTitle("Start", for: .normal)
            movieOutput.stopRecording()
            manager.stopUpdatingLocation()
            timer?.invalidate()
            isstartrecoding = false
            
        } else {
            if(!isstartrecoding)
            {
            rollingButton.backgroundColor = UIColor.red
            rollingButton.setTitle("End", for: .normal)
             isstartrecoding = true
            insertDummyrow()
           getLastVideoID()
            manager.startUpdatingLocation()
            updatelocation()
            let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
            videourl = "output" + String(videoid) + ".mp4"
            let fileUrl = paths[0].appendingPathComponent(videourl)
            try? FileManager.default.removeItem(at: fileUrl)
            //manager.startUpdatingLocation()
            movieOutput.startRecording(to: fileUrl, recordingDelegate: self as AVCaptureFileOutputRecordingDelegate)
            }
        }
    }
    
   
    //String format 00:00
 //   NSString* timeNow = [NSString stringWithFormat:@"%02d:%02d", self.timeMin, self.timeSec];
    //Display on your label
    //self.labelTime.text= timeNow;
  //  }

    func createDataBase() {
        
        let fileurl = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent("geoVideoDatabase121.sqlite")
        if sqlite3_open(fileurl.path,&db) != SQLITE_OK{
            print("error")
            return
        }
        let createLocationtableTable = " CREATE TABLE IF NOT EXISTS UserLocation ( locationid INTEGER PRIMARY KEY  AUTOINCREMENT,LATITUDE DOUBLE ,LONGITUDE DOUBLE,videoid INTEGER)"
        
        if sqlite3_exec(db, createLocationtableTable, nil, nil, nil) != SQLITE_OK{
            print("error");
            return
        }
        let createVideoIfoTable = " CREATE TABLE IF NOT EXISTS VideoInfo ( videoid INTEGER PRIMARY KEY AUTOINCREMENT,videoname TEXT,videodatetime TEXT,location Text,videourl TEXT,videosize TEXT, videotime TEXT,videodurtion TEXT)"
        
    
        if sqlite3_exec(db, createVideoIfoTable, nil, nil, nil) != SQLITE_OK{
            print("error");
            return
        }
        print("good")
    }

    var location : CLLocation?
    
func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    
     location = locations[0];
   
    }
     var contents = "date,time,latitude,longitude,mediatime\n"
    weak var timer: Timer?
    
    func updatelocation() {
        var timesec = 0;
        var timemin = 0;
        var timehour = 0;
        
        

         timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            var stmt: OpaquePointer?
            let insertintouserlocation = "INSERT INTO UserLocation (LATITUDE,LONGITUDE,videoid) VALUES (?,?,?)"
            
            sqlite3_prepare(self.db, insertintouserlocation, -1, &stmt, nil)
            sqlite3_bind_double(stmt,1, (self.location?.coordinate.latitude)!)
            sqlite3_bind_double(stmt,2, (self.location?.coordinate.longitude)!)
            sqlite3_bind_int(stmt,3,Int32(self.videoid))
            
            if(sqlite3_step(stmt) == SQLITE_DONE){
                print("goodgood");
                //  sqlite3_close(stmt)
            }
            
           
            
          
            timesec += 1
            if(timesec == 60)
            {
                timesec = 0
                timemin  += 1
            }
            if(timemin == 60)
            {
                timehour += 1
                timemin = 0
            }
            let timeString = String(format: "%02d:%02d:%02d",timehour, timemin, timesec)
            
            let df = DateFormatter()
            df.dateFormat = "MM-dd-yy"
            let nowdate = df.string(from: Date())
            df.dateFormat = "hh:mm:ss"
            let nowtime = df.string(from: Date())
            
            self.contents.append("\(nowdate),\(nowtime),\((self.location?.coordinate.latitude)!),\((self.location?.coordinate.longitude)!),\(timeString) \n")
            
         self.timingLabel.text = timeString
            
        }
    }
    
    func insertDummyrow()
    {

        
        var stmt: OpaquePointer?
        
        print(db)
        

        let insertintouserlocation = "INSERT INTO VideoInfo (videoname,videodatetime,location,videourl,videosize,videotime,videodurtion) VALUES (?,?,?,?,?,?,?)"
        
        sqlite3_prepare(db, insertintouserlocation, -1, &stmt, nil)
       sqlite3_bind_text(stmt,1,"xyz",-1,nil)
       sqlite3_bind_text(stmt,2,"xyz",-1,nil)
        sqlite3_bind_text(stmt,3,"xyz",-1,nil)
        sqlite3_bind_text(stmt,4,"xyz",-1,nil)
         sqlite3_bind_text(stmt,5,"xyz",-1,nil)
         sqlite3_bind_text(stmt,6,"xyz",-1,nil)
         sqlite3_bind_text(stmt,7,"xyz",-1,nil)
        if(sqlite3_step(stmt) == SQLITE_DONE){
            print("goodgood");
            //  sqlite3_close(stmt)
        }
        
    }
    func getLastVideoID(){
    
         var getlastidofvideos = "SELECT * FROM VideoInfo ORDER BY videoid DESC LIMIT 1"
        
        var queryStatement: OpaquePointer? = nil
        // 1
        if sqlite3_prepare_v2(db, getlastidofvideos, -1, &queryStatement, nil) == SQLITE_OK {
            // 2
            while sqlite3_step(queryStatement) == SQLITE_ROW {
                
                videoid = Int(sqlite3_column_int(queryStatement, 0))
            }
        } else {
        
            print("SELECT statement could not be prepared")
        }
    }
    
    
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        if error == nil {
                self.getLocation()
        
        }
        
        }
        
    func  getLocation(){
        
        let geocoder = CLGeocoder()
        var location = ""
        let sourcelocation = self.manager.location?.coordinate
        // Look up the location and pass it to the completion handler
        geocoder.reverseGeocodeLocation(CLLocation(latitude: sourcelocation!.latitude,longitude: sourcelocation!.longitude ),
                                        completionHandler: { (placemarks, error) in
                                            if error == nil {
                                                guard let placeMark = placemarks?.first else { return }
                                                
                                                
                                                print(self.videourl)
                                                location = "\(                                                placeMark.locality!),\(placeMark.administrativeArea!)"
                                                
                                                self.insertVideoInfoIndatabase(location)
                                            }
                                            else {
                                                self.insertVideoInfoIndatabase("Error")
                                            }
        })
        
        
        
    }

    
    func insertVideoInfoIndatabase(_ location:String) {
         var db1 : OpaquePointer?
        
        let fileurl = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent("geoVideoDatabase121.sqlite")
        if sqlite3_open(fileurl.path,&db1) != SQLITE_OK{
            print("error")
            return
        }
        
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentdirec = paths[0]
        let videopath = documentdirec + "/" + videourl
        
        var fileSize : Double
        var filesizeinmb = ""
        do {
            //return [FileAttributeKey : Any]
            let attr = try FileManager.default.attributesOfItem(atPath: videopath)
            fileSize = attr[FileAttributeKey.size] as! Double
            fileSize = fileSize / 1000000.0
            filesizeinmb = String(format: "%.2f MB", fileSize)
        } catch {
            print("Error: \(error)")
        }
        
        
        let df = DateFormatter()
        df.dateFormat = "MM-dd-yy"
        let nowdate = df.string(from: Date())
        df.dateFormat = "hh:mm:ss"
        let nowtime = df.string(from: Date())
      
        var durtion  = self.timingLabel.text
        let updateStatementString = "UPDATE VideoInfo SET videodatetime ='\(nowdate)', location ='\(location)',videourl = '\(videourl)',videosize = '\(filesizeinmb)',videotime = '\(nowtime)',videodurtion = '\(durtion!)' WHERE videoid = \(videoid);"
        //,video_datetime=\(now),location=\(now),video_url=\(videourl)
        var updateStatement: OpaquePointer?
            if sqlite3_prepare_v2(db1, updateStatementString, -1, &updateStatement, nil) == SQLITE_OK {
                if sqlite3_step(updateStatement) == SQLITE_DONE {
                    print("Successfully updated row.")
                   
                    
                    self.performSegue(withIdentifier: "showpreview", sender: nil)
                } else {
                    print("Could not update row.")
                   //  self.performSegue(withIdentifier: "backtomainview", sender: nil)
                }
            } else {
                print("UPDATE statement could not be prepared")
                 //self.performSegue(withIdentifier: "backtomainview", sender: nil)
            }
}
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if(segue.identifier == "showpreview")
        {
            let info = segue.destination as! videoPreviewViewController
            info.videourl = videourl
            info.videoId = videoid
            info.csvdata = contents
            
        }
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if self.isMovingFromParent {
            if(isstartrecoding)
            {
                let DeleteRow = "DELETE FROM VideoInfo  WHERE videoid = \(videoid);"
                //,video_datetime=\(now),location=\(now),video_url=\(videourl)
                var deleteStatement: OpaquePointer?
                
                if sqlite3_prepare_v2(db, DeleteRow, -1, &deleteStatement, nil) == SQLITE_OK {
                    if sqlite3_step(deleteStatement) == SQLITE_DONE {
                        print("Successfully deleted row.")
                        
                        
                        //self.performSegue(withIdentifier: "backtomainviewfrompreview", sender: nil)
                    } else {
                        print("Could not deleted row.")
                        // self.performSegue(withIdentifier: "backtomainviewfrompreview", sender: nil)
                    }
                } else {
                    print("deleted statement could not be prepared")
                    //self.performSegue(withIdentifier: "backtomainviewfrompreview", sender: nil)
                }
                
                let DeleteRowsfromlocation = "DELETE FROM UserLocation  WHERE videoid = \(videoid);"
                //,video_datetime=\(now),location=\(now),video_url=\(videourl)
                var deleteStatement2: OpaquePointer?
                
                if sqlite3_prepare_v2(db, DeleteRowsfromlocation, -1, &deleteStatement2, nil) == SQLITE_OK {
                    if sqlite3_step(deleteStatement2) == SQLITE_DONE {
                        print("Successfully deleted row.")
                        
                        
                        
                    } else {
                        print("Could not deleted row.")
                        // self.performSegue(withIdentifier: "backtomainviewfrompreview", sender: nil)
                    }
                } else {
                    print("deleted statement could not be prepared")
                    //self.performSegue(withIdentifier: "backtomainviewfrompreview", sender: nil)
                }
             movieOutput.stopRecording()
            manager.stopUpdatingLocation()
            timer?.invalidate()
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        if(isstartrecoding)
        {
        let alert = UIAlertController(title: "low Memory Space", message: "your phone memory is almost full,please make some space for video recoding", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        
        self.present(alert, animated: true)
        
            rollingButton.backgroundColor = UIColor.gray
            movieOutput.stopRecording()
            manager.stopUpdatingLocation()
            timer?.invalidate()
            isstartrecoding = false
            
        }
    }

        
    
    
    @objc func appMovedToinactive()
    {
     if(isstartrecoding)
     {
        rollingButton.backgroundColor = UIColor.gray
        movieOutput.stopRecording()
         rollingButton.setTitle("Start", for: .normal)
        manager.stopUpdatingLocation()
        timer?.invalidate()
        isstartrecoding = false

        }
    }
}

