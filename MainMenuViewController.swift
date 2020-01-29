//
//  MainMenuViewController.swift
//  CardGames
//
//  Created by Branden Yang on 7/10/17.
//  Copyright © 2017 Branden Yang. All rights reserved.
//

import UIKit
import AVFoundation
import GoogleMobileAds

class MainMenuViewController: UIViewController {
    
    
    /*
     --------------------------
     --------------------------
     M O D I F I C A T I O N S:
     --------------------------
     --------------------------
     Note: These modifications are for the general app.
        > Use the prepareForSegue thingy - send the data of the BGM (whether it's on or off) when transitioning (all you have to do is put it in the function - look up how to use). There are 2 options when doing this - create the bgmButton also in the other view controllers, OR simply send the value of a bool in between the viewcontrollers
             > If possible, make some better transitions into the games (fade into dark transition&back???)
        > 0.99 to remove ALL ads (create a no ads button)
    
     --------------------------------
     --------------------------------
     P O S S I B L E   U P D A T E S:
     --------------------------------
     --------------------------------
     Note: These updates are for the general app.
        > Themes - There will be themes for the cards and for the backgrounds. (cost money)
        > Slapjack Hard Mode - Add the Sandwiches/Stacks rule (also add in more instructions for this), and also add joker
        > Joker Artwork (maybe)
        > Ability to flip "back cards" to see what the player won/lost from the war.
        > Blinking "It's Your Turn!" labels
     
     */
    
    @IBOutlet weak var slapjackButton: UIButton!
    @IBOutlet weak var warButton: UIButton!
    @IBOutlet weak var bgmButton: UIButton!
    @IBOutlet weak var mainMenuBanner: GADBannerView!
    
    var backgroundMusicAudioPlayer: AVAudioPlayer?
    var bgmIsPlaying: Bool!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mainMenuBanner.adSize = kGADAdSizeSmartBannerPortrait
        mainMenuBanner.adUnitID = "ca-app-pub-1777080001009552/7926142706"
        mainMenuBanner.rootViewController = self
        mainMenuBanner.load(GADRequest())
        
        slapjackButton.contentVerticalAlignment = .center
        slapjackButton.titleEdgeInsets = UIEdgeInsetsMake(slapjackButton.frame.height / 2.25, 5, slapjackButton.frame.height / 2.25, 5)
        slapjackButton.titleLabel?.minimumScaleFactor = 0.2
        slapjackButton.titleLabel?.adjustsFontSizeToFitWidth = true
        slapjackButton.titleLabel?.numberOfLines = 1
        warButton.contentVerticalAlignment = .center
        warButton.titleEdgeInsets = UIEdgeInsetsMake(warButton.frame.height / 2, 5, warButton.frame.height / 2.75, 5)
        warButton.titleLabel?.minimumScaleFactor = 0.2
        warButton.titleLabel?.adjustsFontSizeToFitWidth = true
        warButton.titleLabel?.numberOfLines = 1
        bgmButton.alpha = 0
        
//        let backgroundMusicAudioURL = URL(fileURLWithPath: Bundle.main.path(forResource: "Elevator-music", ofType: "mp3")!)
//        UserDefaults.standard.set(backgroundMusicAudioURL, forKey: "bgmAudioURL")

        if UserDefaults.standard.bool(forKey: "bgmIsPlaying") == false {
            do {
                backgroundMusicAudioPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: Bundle.main.path(forResource: "Elevator-music", ofType: "mp3")!))
                backgroundMusicAudioPlayer?.numberOfLoops = -1
                backgroundMusicAudioPlayer?.prepareToPlay()
                backgroundMusicAudioPlayer?.play()
                bgmIsPlaying = true
                UserDefaults.standard.setValue(bgmIsPlaying, forKey: "bgmIsPlaying")
            }
            catch {
                print(error)
            }
        }
        
        
//        bgmIsPlaying = UserDefaults.standard.bool(forKey: "bgmIsPlaying")
//
//        if bgmIsPlaying == true {
//            bgmButton.isSelected = true
//        } else if bgmIsPlaying == false {
//            bgmButton.isSelected = false
//        }
//
//        bgmButton.setImage(#imageLiteral(resourceName: "bgm1"), for: .normal)
//        bgmButton.setImage(#imageLiteral(resourceName: "bgm2"), for: .selected)
    }
    
    // This CAN work, but we need to transfer the data for the bgmButton(s) back and forth between the viewcontrollers (using prepareForSegue - at first just try to send the state of the bgm player then we can try sending the whole thing after if it doesn't work). (the state of the button - selected or normal). *Not sure if this actually does work. If it doesn't the other option was to use a navcontroller, and if that doesn't work then just remove the music.
    
    @IBAction func bgmAction(_ sender: Any) {
//        bgmButton.setImage(#imageLiteral(resourceName: "bgm1"), for: .normal)
//        bgmButton.setImage(#imageLiteral(resourceName: "bgm2"), for: .selected)
//
//        if bgmButton.isSelected == true {
//            backgroundMusicAudioPlayer?.stop()
//            bgmButton.isSelected = false
//            bgmIsPlaying = false
//            UserDefaults.standard.setValue(bgmIsPlaying, forKey: "bgmIsPlaying")
//        } else {
//            backgroundMusicAudioPlayer?.play()
//            bgmButton.isSelected = true
//            bgmIsPlaying = true
//            UserDefaults.standard.setValue(bgmIsPlaying, forKey: "bgmIsPlaying")
//        }
    }
    
    func didBuyNoAds(collectionIndex: Int) {
        if collectionIndex == 0 {
            mainMenuBanner.isHidden = true
            mainMenuBanner.frame = CGRect(x: mainMenuBanner.center.x - (mainMenuBanner.frame.width / 2), y: view.center.y - (view.frame.height / 2), width: mainMenuBanner.frame.width, height: mainMenuBanner.frame.height)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Note - This is for information coming in (when it segues to this vc, these are the actions we are taking)
        
        
        
        // add stuff for iap below
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
