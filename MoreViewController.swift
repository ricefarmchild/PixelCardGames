//
//  MoreViewController.swift
//  CardGames
//
//  Created by Branden Yang on 7/21/17.
//  Copyright © 2017 Branden Yang. All rights reserved.
//

import UIKit

class MoreViewController: UIViewController {

    @IBOutlet weak var kenneyButton: UIButton!
    @IBOutlet weak var bgmButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        kenneyButton.titleEdgeInsets = UIEdgeInsetsMake(0, kenneyButton.frame.width / 12, 0, kenneyButton.frame.width / 12)
        kenneyButton.titleLabel?.adjustsFontSizeToFitWidth = true
        kenneyButton.titleLabel?.numberOfLines = 1
        kenneyButton.titleLabel?.lineBreakMode = NSLineBreakMode.byClipping
        bgmButton.titleEdgeInsets = UIEdgeInsetsMake(0, bgmButton.frame.width / 12, 0, bgmButton.frame.width / 12)
        bgmButton.titleLabel?.adjustsFontSizeToFitWidth = true
        bgmButton.titleLabel?.numberOfLines = 1
        bgmButton.titleLabel?.lineBreakMode = NSLineBreakMode.byClipping
    }
    
    @IBAction func kenneyWebsite(_ sender: Any) {
        let kenneyURL = URL(string: "https://kenney.nl/")
        UIApplication.shared.canOpenURL(kenneyURL!)
        UIApplication.shared.open(kenneyURL!, options: [:], completionHandler: nil)
    }
    
    @IBAction func backgroundMusicWebsite(_ sender: Any) {
        let bgmURL = URL(string: "http://www.orangefreesounds.com/elevator-music/")
        UIApplication.shared.canOpenURL(bgmURL!)
        UIApplication.shared.open(bgmURL!, options: [:], completionHandler: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
