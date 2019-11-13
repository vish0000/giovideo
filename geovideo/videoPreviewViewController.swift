//
//  videoPreviewViewController.swift
//  geovideo
//
//  Created by Vish Patel on 9/6/19.
//  Copyright © 2019 kent state university. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit
import SQLite3

class videoPreviewViewController: UIViewController {

    @IBOutlet weak var videoPreview: UIView!
    
    var videourl: String!
    var fileurl : URL!
    var videoId: Int!
    var db1 : OpaquePointer?
    var player : AVPlayer?
    var csvdata = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        showpreview()
    }
    
    
    func showpreview(){
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentdirec = paths[0]
        let videopath = documentdirec + "/" + videourl
        
        fileurl = URL(fileURLWithPath: videopath)
        // Create an AVPlayer, passing it the HTTP Live Streaming URL.
        player = AVPlayer(url: fileurl) // your video url
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = self.view.bounds
        
        playerLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        
        videoPreview.layer.addSublayer(playerLayer)
        player!.play()
        
        let fileurl = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent("geoVideoDatabase121.sqlite")
        if sqlite3_open(fileurl.path,&db1) != SQLITE_OK{
            print("error")
            return
            
        }
    }

    @IBAction func cancleButton(_ sender: Any) {
        
         player?.pause()
        let DeleteRow = "DELETE FROM VideoInfo  WHERE videoid = \(videoId!);"
        //,video_datetime=\(now),location=\(now),video_url=\(videourl)
        var deleteStatement: OpaquePointer?
        
        if sqlite3_prepare_v2(db1, DeleteRow, -1, &deleteStatement, nil) == SQLITE_OK {
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
        
        let DeleteRowsfromlocation = "DELETE FROM UserLocation  WHERE videoid = \(videoId!);"
        //,video_datetime=\(now),location=\(now),video_url=\(videourl)
        var deleteStatement2: OpaquePointer?
        
        if sqlite3_prepare_v2(db1, DeleteRowsfromlocation, -1, &deleteStatement2, nil) == SQLITE_OK {
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
        
    }
    
     @IBAction func saveButton(_ sender: Any) {
        player?.pause()
        let alertController = UIAlertController(title: "Please Enter video Name ", message: "", preferredStyle: .alert)
        
        //the confirm action taking the inputs
        let confirmAction = UIAlertAction(title: "Save", style: .default) { (_) in
            
            //getting the input values from user
            let name = alertController.textFields?[0].text?.trimmingCharacters(in: .whitespacesAndNewlines)
            self.updatenameindatabase(name!)
            let file = "output" + String(self.videoId) + ".csv"
            
             let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let fileurl = dir.appendingPathComponent(file)
            do {
                try self.csvdata.write(to: fileurl, atomically: false, encoding: .utf8)
            
             }
             catch
             {
            
             }
            //UISaveVideoAtPathToSavedPhotosAlbum(self.fileurl.path,nil,nil,nil)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in
       
        }
        
        //adding textfields to our dialog box
        alertController.addTextField { (textField) in
            textField.placeholder = "Enter video Name"
        }
        //adding the action to dialogbox
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        
        //finally presenting the dialog box
        self.present(alertController, animated: true, completion: nil)

     }
    func updatenameindatabase(_ name:String)
    {
        let updateStatementString = "UPDATE VideoInfo SET videoname = '\(name)' WHERE videoid = \(videoId!);"
        //,video_datetime=\(now),location=\(now),video_url=\(videourl)
        var updateStatement: OpaquePointer?
        if sqlite3_prepare_v2(db1, updateStatementString, -1, &updateStatement, nil) == SQLITE_OK {
            if sqlite3_step(updateStatement) == SQLITE_DONE {
                //print("Successfully updated row.")
                showToast(message: "Your video save Successfully",movetonextpage: true,Identifier:"gotomainpage")
                
              
            } else {
                showToast(message: "Error while saving the video",movetonextpage: false,Identifier: "")
               
            }
        } else {
            showToast(message: "Error while saving the video",movetonextpage: false,Identifier: "")
        }
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
        if self.isMovingFromParent {
            player!.pause()
            
        }
    }
    
    func showToast(message : String,movetonextpage : Bool ,Identifier : String ) {
        
        let alert = UIAlertController(title: "", message: message, preferredStyle: .alert)
        self.present(alert, animated: true, completion: nil)
        
        // change to desired number of seconds (in this case 5 seconds)
        let when = DispatchTime.now() + 1
        DispatchQueue.main.asyncAfter(deadline: when){
            // your code with delay
            alert.dismiss(animated: true, completion: nil)
        }
    }

}
