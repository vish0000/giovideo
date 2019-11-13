//
//  webviewViewController.swift
//  geovideo
//
//  Created by Vish Patel on 9/9/19.
//  Copyright © 2019 kent state university. All rights reserved.
//

import UIKit
import WebKit

class webviewViewController: UIViewController,WKNavigationDelegate {
    
    @IBOutlet weak var webviewui: UIWebView!
    var idofvide = 0
    var videourl = ""
    
    @IBOutlet weak var uiview: UIView!
    var webview : WKWebView!
    override func loadView() {
        webview = WKWebView()
        webview.navigationDelegate = self 
       view = webview
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let url = URL(string: "http://geovisuals.cs.kent.edu")!
        webview.load(URLRequest(url: url))
        webview.allowsBackForwardNavigationGestures = true
             }
    

    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

    if self.isMovingFromParent
    {

        let info =   showtripController()
            info.idofvide = idofvide
            info.videourl = videourl
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
