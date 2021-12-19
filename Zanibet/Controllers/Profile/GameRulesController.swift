//
//  GameRulesController.swift
//  Zanibet
//
//  Created by Gromat Luidgi on 27/11/2017.
//  Copyright © 2017 Gromat Luidgi. All rights reserved.
//

import UIKit

class GameRulesController: UIViewController {
    @IBOutlet weak var rulesTextView: UITextView!
    
    
    @IBOutlet weak var titleLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.titleLabel.text = NSLocalizedString("title_rules", comment: "")
        self.rulesTextView.text = NSLocalizedString("rules", comment: "")
        // Do any additional setup after loading the view.
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.rulesTextView.setContentOffset(CGPoint.zero, animated: false)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.statusBarStyle = .default
    }
  
    @IBAction func bakcPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
