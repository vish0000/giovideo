//
//  allvideodataViewControllerTableViewController.swift
//  geovideo
//
//  Created by Vish Patel on 7/31/19.
//  Copyright © 2019 kent state university. All rights reserved.
//

import UIKit
import SQLite3
import AVFoundation
import AVKit
struct Headline {
    
    var id : Int
    var title : String
    var location : String
    var date:String
    var videourl : String
    var videosize : String
    var time:String
    var durtion : String
}

class HeadlineTableViewCell: UITableViewCell {
    @IBOutlet weak var videoname: UILabel!
    @IBOutlet weak var videoid: UILabel!
    @IBOutlet weak var videopreview: UIImageView!
    @IBOutlet weak var videoLocation: UILabel!
    @IBOutlet weak var videodate: UILabel!
    @IBOutlet weak var videoSize: UILabel!
    @IBOutlet weak var videoDurtion: UILabel!
    @IBOutlet weak var videotime: UILabel!
}
class allvideodataViewControllerTableViewController: UITableViewController{
    
    @IBOutlet weak var backButton: UIButton!
    var allvideolist : [Headline] = []
     var db1 : OpaquePointer?
    override func viewDidLoad() {
        super.viewDidLoad()
    
        query()
    }
    func query() {
        
        let fileurl = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent("geoVideoDatabase121.sqlite")
        if sqlite3_open(fileurl.path,&db1) != SQLITE_OK{
            print("error")
            return
        }
        
        let queryStatementString = "SELECT * FROM VideoInfo"
        var queryStatement: OpaquePointer? = nil
        // 1
        if sqlite3_prepare_v2(db1, queryStatementString, -1, &queryStatement, nil) == SQLITE_OK {
            // 2
            while sqlite3_step(queryStatement) == SQLITE_ROW {
                
                let queryResultCol1 = sqlite3_column_int(queryStatement, 0)
                let queryResultCol2 = sqlite3_column_text(queryStatement, 1)
                let queryResultCol4 = sqlite3_column_text(queryStatement, 2)
                let queryResultCol3 = sqlite3_column_text(queryStatement, 3)
                let queryResultCol5 = sqlite3_column_text(queryStatement, 4)
                
                 let queryResultCol6 = sqlite3_column_text(queryStatement, 5)
                 let queryResultCol7 = sqlite3_column_text(queryStatement, 6)
                 let queryResultCol8 = sqlite3_column_text(queryStatement, 7)
                
                
                var videodata : Headline = Headline(id: Int(queryResultCol1), title: String(cString :queryResultCol2!),location: String(cString :queryResultCol3!),date : String(cString :queryResultCol4!),videourl: String(cString :queryResultCol5!),videosize: String(cString :queryResultCol6!),time: String(cString :queryResultCol7!),durtion: String(cString :queryResultCol8!))
                allvideolist.append(videodata)

            }
        } else {
            print("SELECT statement could not be prepared")
        }
        
        // 6
        sqlite3_finalize(queryStatement)
    }
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return allvideolist.count
    }
    
    var idtobesend2: Headline? = nil;
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //performSegue(wthIdentifier: "showDetails", sender: Headline[indexPath.row])
        print("aa")
        idtobesend2 = allvideolist[indexPath.row]
    self.performSegue(withIdentifier: "gotodetailview", sender: nil)
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Labelcell", for: indexPath)
            as! HeadlineTableViewCell
        let headline = allvideolist[indexPath.row]
        cell.videoname?.text = String(headline.title)
        //cell.videoid?.text = String(headline.id)
        cell.videoLocation?.text = String(headline.location)
        cell.videodate?.text = String(headline.date)
        cell.videoDurtion?.text = String(headline.durtion)
        cell.videoSize?.text = String(headline.videosize)
        cell.videotime?.text = String(headline.time)
        
        do {
            let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
            let documentdirec = paths[0]
            let videopath = documentdirec + "/" + headline.videourl
              let fileurl = URL(fileURLWithPath: videopath)
         //   var err: NSError? = nil
            let asset = AVURLAsset(url:fileurl, options: nil)
            let imgGenerator = AVAssetImageGenerator(asset: asset)
            let cgImage = try? imgGenerator.copyCGImage(at: CMTimeMake(value: 0, timescale: 1), actualTime: nil)
            
           if(cgImage != nil)
           {
            // !! check the error before proceeding
           // UIImage(CGImage: otherImage.CGImage, scale: 1.0, orientation: .DownMirrored)
            cell.videopreview.image = UIImage(cgImage: cgImage!, scale: 1.0, orientation: .leftMirrored)
            cell.videopreview.contentMode = .scaleToFill
         //   let imageView = UIImageView(image: uiImage)
            }
        }catch{
            print("Error is : \(error)")
        }

        return cell
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "gotodetailview")
        {
        let info = segue.destination as! showtripController
        info.idofvide = idtobesend2!.id
        info.videourl = idtobesend2!.videourl
        }
        }
    
/*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        //  the selected object to the new view controller.
    }
    */

}
