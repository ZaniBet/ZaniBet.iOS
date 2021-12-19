//
//  HelpWebController.swift
//  Zanibet
//
//  Created by Gromat Luidgi on 24/02/2018.
//  Copyright © 2018 Gromat Luidgi. All rights reserved.
//

import UIKit
import WebKit
import NVActivityIndicatorView
import UIEmptyState

class HelpWebController: UIViewController, WKUIDelegate, WKNavigationDelegate, UIEmptyStateDelegate, UIEmptyStateDataSource {

    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var webContainerView: UIView!
    var webView: WKWebView!
    var indicatorView:NVActivityIndicatorView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.emptyStateDataSource = self
        self.emptyStateDelegate = self
        
        let webConfiguration = WKWebViewConfiguration()
        let customFrame = CGRect.init(origin: CGPoint.zero, size: CGSize.init(width: 0.0, height: self.webContainerView.frame.size.height))
        self.webView = WKWebView (frame: customFrame, configuration: webConfiguration)
        self.webView.translatesAutoresizingMaskIntoConstraints = false
        
        self.webContainerView.addSubview(webView)
        
        self.webView.topAnchor.constraint(equalTo: webContainerView.topAnchor).isActive = true
        self.webView.rightAnchor.constraint(equalTo: webContainerView.rightAnchor).isActive = true
        self.webView.leftAnchor.constraint(equalTo: webContainerView.leftAnchor).isActive = true
        self.webView.bottomAnchor.constraint(equalTo: webContainerView.bottomAnchor).isActive = true
        self.webView.heightAnchor.constraint(equalTo: webContainerView.heightAnchor).isActive = true
        self.webView.uiDelegate = self
        self.webView.navigationDelegate = self
        
        self.indicatorView = NVActivityIndicatorView(frame: CGRect(x: (self.view.bounds.width/2)-25, y: (self.view.bounds.height/2)-89, width: 50, height: 50) )
        self.indicatorView!.type = .ballClipRotateMultiple
        self.indicatorView!.color = .flatGreen
        self.webContainerView.addSubview(self.indicatorView!)
        self.indicatorView.startAnimating()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        var myURL = URL(string: "https://api.zanibet.com/help/fr")
        if let langStr = Locale.current.languageCode {
            if (!langStr.contains("fr")){
                 myURL = URL(string: "https://api.zanibet.com/help/en")
            }
        }
        
        let myRequest = URLRequest(url: myURL!)
        self.webView.load(myRequest)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func backPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func webViewWebContentProcessDidTerminate(_ webView: WKWebView) {
        //if (!webView.isLoading){
        //}
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        self.indicatorView.stopAnimating()
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        self.indicatorView.stopAnimating()
        self.emptyStateView.isHidden = false
    }
    
    var emptyStateImage: UIImage? {
            return #imageLiteral(resourceName: "global_error")
    }
    
    var emptyStateTitle: NSAttributedString {
        let attrs = [NSAttributedStringKey.foregroundColor: UIColor.flatGray, NSAttributedStringKey.font: UIFont(name: "HelveticaNeue-Light", size: 13)!]
        return NSAttributedString(string: NSLocalizedString("err_network", comment: ""), attributes: attrs)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
