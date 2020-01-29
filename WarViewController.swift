//
//  WarViewController.swift
//  CardGames
//
//  Created by Branden Yang on 7/10/17.
//  Copyright © 2017 Branden Yang. All rights reserved.
//

import UIKit
import AVFoundation
import GoogleMobileAds

class WarViewController: UIViewController, GADInterstitialDelegate {
    
    /*
     --------------------------
     --------------------------
     M O D I F I C A T I O N S:
     --------------------------
     --------------------------
     
        > After a player wins a war, the "back cards" turn over and reveal what the player won/lost
        > Fix sizing of buttons in settings area
        > Smooth the war function (has a comment where to fix)
        > Fix sizing of cards and card stacks etc.
     
     */
    
    @IBOutlet weak var bottomCardLabel: UILabel!
    @IBOutlet weak var topCardLabel: UILabel!
    @IBOutlet weak var bottomCardStack: UIImageView!
    @IBOutlet weak var topCardStack: UIImageView!
    @IBOutlet weak var topSettingsView: UIView!
    @IBOutlet weak var dimView: UIView!
    @IBOutlet weak var clearViewForSettings: UIView!
    @IBOutlet weak var playerOneTurnLabel: UILabel!
    @IBOutlet weak var playerTwoTurnLabel: UILabel!
    @IBOutlet weak var bottomAddedCardAmount: UILabel!
    @IBOutlet weak var topAddedCardAmount: UILabel!
    @IBOutlet weak var bottomClearView: UIView!
    @IBOutlet weak var topClearView: UIView!
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var instructionsView: UIView!
    @IBOutlet weak var bgmButton: UIButton!
    @IBOutlet weak var endView: UIView!
    @IBOutlet weak var bottomWinLoseLabel: UILabel!
    @IBOutlet weak var topWinLoseLabel: UILabel!
    @IBOutlet weak var topPlayAgainButton: UIButton!
    @IBOutlet weak var invisibleSizingCard: UIImageView!
    
    var playerOneNumber = Int()
    var playerTwoNumber = Int()
    var playerOneCard = UIImageView()
    var playerTwoCard = UIImageView()
    
    var bottomCardsAddedNumber = Int()
    var topCardsAddedNumber = Int()
    
    var playerTurnsPassed = 0
    var playerWhoseTurnIsOver = Int()
    
    var cardSFAudioPlayer: AVAudioPlayer?
    
    var cardsArray = [#imageLiteral(resourceName: "club_2"), #imageLiteral(resourceName: "club_3"), #imageLiteral(resourceName: "club_4"), #imageLiteral(resourceName: "club_5"), #imageLiteral(resourceName: "club_6"), #imageLiteral(resourceName: "club_7"), #imageLiteral(resourceName: "club_8"), #imageLiteral(resourceName: "club_9"), #imageLiteral(resourceName: "club_10"), #imageLiteral(resourceName: "club_jack"), #imageLiteral(resourceName: "club_queen"), #imageLiteral(resourceName: "club_king"), #imageLiteral(resourceName: "club_ace"),
                      
                      #imageLiteral(resourceName: "spade_2"), #imageLiteral(resourceName: "spade_3"), #imageLiteral(resourceName: "spade_4"), #imageLiteral(resourceName: "spade_5"), #imageLiteral(resourceName: "spade_6"), #imageLiteral(resourceName: "spade_7"), #imageLiteral(resourceName: "spade_8"), #imageLiteral(resourceName: "spade_9"), #imageLiteral(resourceName: "spade_10"), #imageLiteral(resourceName: "spade_jack"), #imageLiteral(resourceName: "spade_queen"), #imageLiteral(resourceName: "spade_king"), #imageLiteral(resourceName: "spade_ace"),
                      
                      #imageLiteral(resourceName: "diamond_2"), #imageLiteral(resourceName: "diamond_3"), #imageLiteral(resourceName: "diamond_4"), #imageLiteral(resourceName: "diamond_5"), #imageLiteral(resourceName: "diamond_6"), #imageLiteral(resourceName: "diamond_7"), #imageLiteral(resourceName: "diamond_8"), #imageLiteral(resourceName: "diamond_9"), #imageLiteral(resourceName: "diamond_10"), #imageLiteral(resourceName: "diamond_jack"), #imageLiteral(resourceName: "diamond_queen"), #imageLiteral(resourceName: "diamond_king"), #imageLiteral(resourceName: "diamond_ace"),
                      
                      #imageLiteral(resourceName: "heart_2"), #imageLiteral(resourceName: "heart_3"), #imageLiteral(resourceName: "heart_4"), #imageLiteral(resourceName: "heart_5"), #imageLiteral(resourceName: "heart_6"), #imageLiteral(resourceName: "heart_7"), #imageLiteral(resourceName: "heart_8"), #imageLiteral(resourceName: "heart_9"), #imageLiteral(resourceName: "heart_10"), #imageLiteral(resourceName: "heart_jack"), #imageLiteral(resourceName: "heart_queen"), #imageLiteral(resourceName: "heart_king"), #imageLiteral(resourceName: "heart_ace")]
    
    var playerOneCardsArray: [UIImage] = []
    var playerTwoCardsArray: [UIImage] = []
    
    var randomPlayerOneIndex = Int()
    var randomPlayerTwoIndex = Int()
    var playerOneLastCardImageAtCorrespondingIndex = UIImage()
    var playerTwoLastCardImageAtCorrespondingIndex = UIImage()
    
    var settingsInterstitial: GADInterstitial!
    var afterGameInterstitial: GADInterstitial!
    
//    var backgroundMusicAudioPlayer: AVAudioPlayer?
//    var bgmIsPlaying: Bool!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        settingsInterstitial = createAndLoadSettingsInterstitial()
        afterGameInterstitial = createAndLoadAfterGameInterstitial()
        
        topCardLabel.transform = CGAffineTransform(rotationAngle: CGFloat.pi)
        topCardStack.transform = CGAffineTransform(rotationAngle: CGFloat.pi)
        topSettingsView.transform = CGAffineTransform(rotationAngle: CGFloat.pi)
        playerTwoTurnLabel.transform = CGAffineTransform(rotationAngle: CGFloat.pi)
        topAddedCardAmount.transform = CGAffineTransform(rotationAngle: CGFloat.pi)
        topPlayAgainButton.transform = CGAffineTransform(rotationAngle: CGFloat.pi)
        topWinLoseLabel.transform = CGAffineTransform(rotationAngle: CGFloat.pi)
        dimView.alpha = 0
        clearViewForSettings.alpha = 0
        endView.alpha = 0
        
        let bottomSwipe = UISwipeGestureRecognizer(target: self, action: #selector(WarViewController.bottomSwipeFunction))
        let topSwipe = UISwipeGestureRecognizer(target: self, action: #selector(WarViewController.topSwipeFunction))
        let instructionsTap = UITapGestureRecognizer(target: self, action: #selector(WarViewController.dismissInstructionsPanel))
        
        bottomSwipe.direction = .up
        bottomClearView.addGestureRecognizer(bottomSwipe)
        bottomClearView.isUserInteractionEnabled = true
        topSwipe.direction = .down
        topClearView.addGestureRecognizer(topSwipe)
        topClearView.isUserInteractionEnabled = true
        instructionsView.addGestureRecognizer(instructionsTap)
        instructionsView.isUserInteractionEnabled = true
        
        distributeCards()
        updateCardLabels()
        
        bottomAddedCardAmount.alpha = 0
        topAddedCardAmount.alpha = 0
        
        randomlyDetermineFirstTurn()
        
        UIView.animate(withDuration: 0.2, animations: {
            self.dimView.alpha = 0.9
            self.instructionsView.alpha = 1
        })
        
//        do {
//            backgroundMusicAudioPlayer = try AVAudioPlayer(contentsOf: UserDefaults.standard.url(forKey: "bgmAudioURL")!)
//            backgroundMusicAudioPlayer?.numberOfLoops = -1
//            backgroundMusicAudioPlayer?.prepareToPlay()
//        }
//        catch {
//            print(error)
//        }
//
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
    
    func createAndLoadSettingsInterstitial() -> GADInterstitial {
        let interstitial = GADInterstitial(adUnitID: "ca-app-pub-1777080001009552/3736095187")
        interstitial.delegate = self
        interstitial.load(GADRequest())
        return interstitial
    }
    
    func createAndLoadAfterGameInterstitial() -> GADInterstitial {
        let interstitial = GADInterstitial(adUnitID: "ca-app-pub-1777080001009552/2566074626")
        interstitial.delegate = self
        interstitial.load(GADRequest())
        return interstitial
    }
    
    func settingsInterstitialDidDismissScreen(_ ad: GADInterstitial) {
        settingsInterstitial = createAndLoadSettingsInterstitial()
    }
    
    func afterGameInterstitialDidDismissScreen(_ ad: GADInterstitial) {
        afterGameInterstitial = createAndLoadAfterGameInterstitial()
    }
    
    @objc func dismissInstructionsPanel() {
        UIView.animate(withDuration: 1, delay: 0, options: .curveEaseIn, animations: {
            self.dimView.alpha = 0
            self.instructionsView.alpha = 0
        }, completion: nil)
    }
    
    func playCardSoundEffect() {
        let randomCardSFNumber = arc4random_uniform(16) + 1
        guard let url = Bundle.main.url(forResource: "cardSF\(randomCardSFNumber)", withExtension: "wav") else { return }
        
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            try AVAudioSession.sharedInstance().setActive(true)
            
            cardSFAudioPlayer = try AVAudioPlayer(contentsOf: url)
            guard let cardSFAudioPlayer = cardSFAudioPlayer else { return }
            
            cardSFAudioPlayer.play()
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    @IBAction func bottomSettingsButton(_ sender: Any) {
        settingsMenu(isShown: true)
        if settingsInterstitial.isReady {
            settingsInterstitial.present(fromRootViewController: self)
        } else {
            print("Ad wasn't ready")
        }
    }
    
    @IBAction func topSettingsButton(_ sender: Any) {
        settingsMenu(isShown: true)
        if settingsInterstitial.isReady {
            settingsInterstitial.present(fromRootViewController: self)
        } else {
            print("Ad wasn't ready")
        }
    }
    
    @IBAction func bottomContinueAction(_ sender: Any) {
        settingsMenu(isShown: false)
    }
    
    @IBAction func topContinueAction(_ sender: Any) {
        settingsMenu(isShown: false)
    }
    
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
    
    func settingsMenu(isShown: Bool) {
        if isShown == true {
            self.dimView.alpha = 0.7
            self.clearViewForSettings.alpha = 1
            self.bgmButton.alpha = 0
            clearViewForSettings.isHidden = false
        } else if isShown == false {
            self.dimView.alpha = 0
            self.clearViewForSettings.alpha = 0
            self.bgmButton.alpha = 0
        }
    }
    
    func randomlyDetermineFirstTurn() {
        let oneOrTwo = arc4random_uniform(2) + 1
        
        if oneOrTwo == 1 {
            playerWhoseTurnIsOver = 2
            playerTurnFunction()
            playerTurnsPassed += 1
        } else if oneOrTwo == 2 {
            playerWhoseTurnIsOver = 1
            playerTurnFunction()
            playerTurnsPassed += 1
        }
    }
    
    func playerTurnFunction() {
        if playerWhoseTurnIsOver == 1 {
            playerOneTurnLabel.isHidden = true
            playerTwoTurnLabel.isHidden = false
            bottomClearView.isUserInteractionEnabled = false
            topClearView.isUserInteractionEnabled = true
        } else if playerWhoseTurnIsOver == 2 {
            playerTwoTurnLabel.isHidden = true
            playerOneTurnLabel.isHidden = false
            topClearView.isUserInteractionEnabled = false
            bottomClearView.isUserInteractionEnabled = true
        }
    }
    
    func turnOffSwipeGestures(delayTime: Double) {
        
        bottomClearView.isUserInteractionEnabled = false
        topClearView.isUserInteractionEnabled = false
        
        if playerWhoseTurnIsOver == 1 {
            DispatchQueue.main.asyncAfter(deadline: .now() + delayTime, execute: {
                self.bottomClearView.isUserInteractionEnabled = false
                self.topClearView.isUserInteractionEnabled = true
            })
        } else if playerWhoseTurnIsOver == 2 {
            DispatchQueue.main.asyncAfter(deadline: .now() + delayTime, execute: {
                self.bottomClearView.isUserInteractionEnabled = true
                self.topClearView.isUserInteractionEnabled = false
            })
        }
        
    }
    
    func cardsMoveToPosAndDisappear(xPos: CGFloat, yPos: CGFloat) {
        
        UIView.animate(withDuration: 1, delay: 1, options: .curveEaseOut, animations: {
            self.backgroundImageView.subviews.forEach { $0.frame = CGRect(x: xPos, y: yPos, width: self.invisibleSizingCard.frame.width, height: self.invisibleSizingCard.frame.height) }
        }, completion: nil)
        
        UIView.animate(withDuration: 0.5, delay: 1.5, options: .curveEaseOut, animations: {
            self.backgroundImageView.subviews.forEach { $0.alpha = 0 }
        }, completion: nil)
        
        addedCardsToLabelsAnimation()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
            self.bottomCardLabel.text = "Cards: \(self.playerOneCardsArray.count)"
            self.topCardLabel.text = "Cards: \(self.playerTwoCardsArray.count)"
        })
    }
    
    func addedCardsToLabelsAnimation() {
        bottomAddedCardAmount.frame = CGRect(x: bottomCardLabel.center.x - (bottomCardLabel.frame.width / 2), y: bottomCardLabel.center.y - (bottomCardLabel.frame.height * 2), width: bottomCardLabel.frame.width, height: bottomCardLabel.frame.height)
        topAddedCardAmount.frame = CGRect(x: topCardLabel.center.x - (topCardLabel.frame.width / 2), y: topCardLabel.center.y + (topCardLabel.frame.height * 2), width: topCardLabel.frame.width, height: topCardLabel.frame.height)
        bottomAddedCardAmount.alpha = 1
        topAddedCardAmount.alpha = 1
        
        if bottomCardsAddedNumber > 0 {
            
            bottomAddedCardAmount.text = "Cards: +\(bottomCardsAddedNumber)"
            UIView.animate(withDuration: 1, delay: 1, options: .curveEaseOut, animations: {
                self.bottomAddedCardAmount.frame = CGRect(x: self.bottomCardLabel.center.x - (self.bottomCardLabel.frame.width / 2), y: self.bottomCardLabel.center.y - (self.bottomCardLabel.frame.height / 2), width: self.bottomCardLabel.frame.width, height: self.bottomCardLabel.frame.height)
                self.bottomAddedCardAmount.alpha = 0
            }, completion: nil)
            
        } else if bottomCardsAddedNumber == 0 {
            
            bottomAddedCardAmount.text = "Cards: +0"
            UIView.animate(withDuration: 1, delay: 1, options: .curveEaseOut, animations: {
                self.bottomAddedCardAmount.frame = CGRect(x: self.bottomCardLabel.center.x - (self.bottomCardLabel.frame.width / 2), y: self.bottomCardLabel.center.y - (self.bottomCardLabel.frame.height / 2), width: self.bottomCardLabel.frame.width, height: self.bottomCardLabel.frame.height)
                self.bottomAddedCardAmount.alpha = 0
            }, completion: nil)
            
        }
        
        if topCardsAddedNumber > 0 {
            
            topAddedCardAmount.text = "Cards: +\(topCardsAddedNumber)"
            UIView.animate(withDuration: 1, delay: 1, options: .curveEaseOut, animations: {
                self.topAddedCardAmount.frame = CGRect(x: self.topCardLabel.center.x - (self.topCardLabel.frame.width / 2), y: self.topCardLabel.center.y - (self.topCardLabel.frame.height / 2), width: self.topCardLabel.frame.width, height: self.topCardLabel.frame.height)
                self.topAddedCardAmount.alpha = 0
            }, completion: nil)
            
        } else if topCardsAddedNumber == 0 {
            
            topAddedCardAmount.text = "Cards: +0"
            UIView.animate(withDuration: 1, delay: 1, options: .curveEaseOut, animations: {
                self.topAddedCardAmount.frame = CGRect(x: self.topCardLabel.center.x - (self.topCardLabel.frame.width / 2), y: self.topCardLabel.center.y - (self.topCardLabel.frame.height / 2), width: self.topCardLabel.frame.width, height: self.topCardLabel.frame.height)
                self.topAddedCardAmount.alpha = 0
            }, completion: nil)
            
        }
        
    }
    
    func updateCardLabels() {
        bottomCardLabel.text = "Cards: \(playerOneCardsArray.count)"
        topCardLabel.text = "Cards: \(playerTwoCardsArray.count)"
    }
    
    func playerOneWinsRound() {
        playerOneTurnLabel.alpha = 0
        playerTwoTurnLabel.alpha = 0
        
        UIView.animate(withDuration: 0.1, delay: 2.9, options: .curveEaseOut, animations: {
            self.playerOneTurnLabel.alpha = 1
            self.playerTwoTurnLabel.alpha = 1
        }, completion: nil)
        
        bottomCardsAddedNumber = cardsArray.count
        topCardsAddedNumber = 0
        playerOneCardsArray.append(contentsOf: cardsArray)
        cardsArray.removeAll()
        
        cardsMoveToPosAndDisappear(xPos: bottomCardStack.center.x - bottomCardStack.frame.width / 2, yPos: bottomCardStack.center.y - bottomCardStack.frame.height / 2)
        
        endFunction()
        
        playerTurnFunction()
        playerTurnsPassed = 0
    }
    
    func playerTwoWinsRound() {
        playerOneTurnLabel.alpha = 0
        playerTwoTurnLabel.alpha = 0
        
        UIView.animate(withDuration: 0.1, delay: 2.9, options: .curveEaseOut, animations: {
            self.playerOneTurnLabel.alpha = 1
            self.playerTwoTurnLabel.alpha = 1
        }, completion: nil)
        
        topCardsAddedNumber = cardsArray.count
        bottomCardsAddedNumber = 0
        playerTwoCardsArray.append(contentsOf: cardsArray)
        cardsArray.removeAll()
        
        cardsMoveToPosAndDisappear(xPos: topCardStack.center.x - topCardStack.frame.width / 2, yPos: topCardStack.center.y - topCardStack.frame.height / 2)
        
        endFunction()
        
        playerTurnFunction()
        playerTurnsPassed = 0
    }
    
    func endFunction() {
        if playerOneCardsArray.count == 52 || bottomCardLabel.text == "Cards: 52" {
            if playerOneNumber > playerTwoNumber {
                UIView.animate(withDuration: 0.5, animations: {
                    self.endView.alpha = 1
                    self.dimView.alpha = 0.7
                    self.bottomWinLoseLabel.text = "You Won!"
                    self.topWinLoseLabel.text = "You Lost :("
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                        if self.afterGameInterstitial.isReady {
                            self.afterGameInterstitial.present(fromRootViewController: self)
                        } else {
                            print("Ad wasn't ready")
                        }
                    })
                    
                })
            }
        } else if playerTwoCardsArray.count == 52 || topCardLabel.text == "Cards: 52" {
            if playerTwoNumber > playerOneNumber {
                UIView.animate(withDuration: 0.5, animations: {
                    self.endView.alpha = 1
                    self.dimView.alpha = 0.7
                    self.bottomWinLoseLabel.text = "You Lost :("
                    self.topWinLoseLabel.text = "You Won!"
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                        if self.afterGameInterstitial.isReady {
                            self.afterGameInterstitial.present(fromRootViewController: self)
                        } else {
                            print("Ad wasn't ready")
                        }
                    })
                })
            }
        }
    }

    // IN A FUTURE UPDATE - we will make the cards turn over and make the delay longer so that we can look and see what cards the player has won/lost (really just for visibility to make it look nicer)
    func warFunction() {
        let bottomWarCauseCard = UIImageView()
        bottomWarCauseCard.image = playerOneCard.image
        bottomWarCauseCard.alpha = 0
        bottomWarCauseCard.frame = CGRect(x: view.center.x - (invisibleSizingCard.frame.width / 2), y: view.center.y, width: invisibleSizingCard.frame.width, height: invisibleSizingCard.frame.height)
        let topWarCauseCard = UIImageView()
        topWarCauseCard.image = playerTwoCard.image
        topWarCauseCard.alpha = 0
        topWarCauseCard.frame = CGRect(x: view.center.x - (invisibleSizingCard.frame.width / 2), y: view.center.y - invisibleSizingCard.frame.height, width: invisibleSizingCard.frame.width, height: invisibleSizingCard.frame.height)
        
        backgroundImageView.addSubview(bottomWarCauseCard)
        backgroundImageView.addSubview(topWarCauseCard)
        
        // you can add delay or change duration etc. to make smoother
        UIView.animate(withDuration: 1, animations: {
            bottomWarCauseCard.alpha = 1
            topWarCauseCard.alpha = 1
        })
        
        if playerOneCardsArray.count > 1 && playerTwoCardsArray.count > 1 {
            var bottomTemporaryWarCard = UIImageView()
            bottomTemporaryWarCard = UIImageView(image: #imageLiteral(resourceName: "Card Back"))
            bottomTemporaryWarCard.alpha = 0
            bottomTemporaryWarCard.frame = CGRect(x: view.center.x - (invisibleSizingCard.frame.width / 2), y: view.frame.height - invisibleSizingCard.frame.height, width: invisibleSizingCard.frame.width, height: invisibleSizingCard.frame.height)
            var topTemporaryWarCard = UIImageView()
            topTemporaryWarCard = UIImageView(image: #imageLiteral(resourceName: "Card Back"))
            topTemporaryWarCard.alpha = 0
            topTemporaryWarCard.frame = CGRect(x: view.center.x - 50, y: view.frame.height - view.frame.height, width: 100, height: 140)
            
            UIView.animate(withDuration: 1.0, delay: 0.5, options: .curveEaseOut, animations: {
                self.backgroundImageView.addSubview(bottomTemporaryWarCard)
                bottomTemporaryWarCard.alpha = 1
                bottomTemporaryWarCard.frame = CGRect(x: self.view.center.x - (self.invisibleSizingCard.frame.width / 2), y: self.view.center.y + ((self.invisibleSizingCard.frame.height / 7) * 2), width: self.invisibleSizingCard.frame.width, height: self.invisibleSizingCard.frame.height)
                self.backgroundImageView.addSubview(topTemporaryWarCard)
                topTemporaryWarCard.alpha = 1
                topTemporaryWarCard.frame = CGRect(x: self.view.center.x - (self.invisibleSizingCard.frame.width / 2), y: self.view.center.y - ((self.invisibleSizingCard.frame.height / 7) * 9), width: self.invisibleSizingCard.frame.width, height: self.invisibleSizingCard.frame.height)
            }, completion: nil)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                self.randomPlayerOneIndex = Int(arc4random_uniform(UInt32(self.playerOneCardsArray.count)))
                self.randomPlayerTwoIndex = Int(arc4random_uniform(UInt32(self.playerTwoCardsArray.count)))
                self.playerOneLastCardImageAtCorrespondingIndex = self.playerOneCardsArray[self.randomPlayerOneIndex]
                self.playerTwoLastCardImageAtCorrespondingIndex = self.playerTwoCardsArray[self.randomPlayerTwoIndex]
                
                self.playerOneCardsArray.remove(at: self.randomPlayerOneIndex)
                self.playerTwoCardsArray.remove(at: self.randomPlayerTwoIndex)
                self.cardsArray.append(self.playerOneLastCardImageAtCorrespondingIndex)
                self.cardsArray.append(self.playerTwoLastCardImageAtCorrespondingIndex)
                
                self.updateCardLabels()
            })
        }
        
        if playerOneCardsArray.count > 1 && playerTwoCardsArray.count > 1 {
            var bottomTemporaryWarCardTwo = UIImageView()
            bottomTemporaryWarCardTwo = UIImageView(image: #imageLiteral(resourceName: "Card Back"))
            bottomTemporaryWarCardTwo.alpha = 0
            bottomTemporaryWarCardTwo.frame = CGRect(x: view.center.x - (invisibleSizingCard.frame.width / 2), y: view.frame.height - invisibleSizingCard.frame.height, width: invisibleSizingCard.frame.width, height: invisibleSizingCard.frame.height)
            var topTemporaryWarCardTwo = UIImageView()
            topTemporaryWarCardTwo = UIImageView(image: #imageLiteral(resourceName: "Card Back"))
            topTemporaryWarCardTwo.alpha = 0
            topTemporaryWarCardTwo.frame = CGRect(x: view.center.x - (invisibleSizingCard.frame.width / 2), y: view.frame.height - view.frame.height, width: invisibleSizingCard.frame.width, height: invisibleSizingCard.frame.height)
            
            UIView.animate(withDuration: 1.0, delay: 0.8, options: .curveEaseOut, animations: {
                self.backgroundImageView.addSubview(bottomTemporaryWarCardTwo)
                bottomTemporaryWarCardTwo.alpha = 1
                bottomTemporaryWarCardTwo.frame = CGRect(x: self.view.center.x - (self.invisibleSizingCard.frame.width / 2), y: self.view.center.y + ((self.invisibleSizingCard.frame.height / 14) * 5), width: self.invisibleSizingCard.frame.width, height: self.invisibleSizingCard.frame.height)
                self.backgroundImageView.addSubview(topTemporaryWarCardTwo)
                topTemporaryWarCardTwo.alpha = 1
                topTemporaryWarCardTwo.frame = CGRect(x: self.view.center.x - (self.invisibleSizingCard.frame.width / 2), y: self.view.center.y - ((self.invisibleSizingCard.frame.height / 14) * 19), width: self.invisibleSizingCard.frame.width, height: self.invisibleSizingCard.frame.height)
            }, completion: nil)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8, execute: {
                self.randomPlayerOneIndex = Int(arc4random_uniform(UInt32(self.playerOneCardsArray.count)))
                self.randomPlayerTwoIndex = Int(arc4random_uniform(UInt32(self.playerTwoCardsArray.count)))
                self.playerOneLastCardImageAtCorrespondingIndex = self.playerOneCardsArray[self.randomPlayerOneIndex]
                self.playerTwoLastCardImageAtCorrespondingIndex = self.playerTwoCardsArray[self.randomPlayerTwoIndex]
                
                self.playerOneCardsArray.remove(at: self.randomPlayerOneIndex)
                self.playerTwoCardsArray.remove(at: self.randomPlayerTwoIndex)
                self.cardsArray.append(self.playerOneLastCardImageAtCorrespondingIndex)
                self.cardsArray.append(self.playerTwoLastCardImageAtCorrespondingIndex)
                
                self.updateCardLabels()
            })
        }
        
        if playerOneCardsArray.count > 1 && playerTwoCardsArray.count > 1 {
            var bottomTemporaryWarCardThree = UIImageView()
            bottomTemporaryWarCardThree = UIImageView(image: #imageLiteral(resourceName: "Card Back"))
            bottomTemporaryWarCardThree.alpha = 0
            bottomTemporaryWarCardThree.frame = CGRect(x: view.center.x - (invisibleSizingCard.frame.width / 2), y: view.frame.height - invisibleSizingCard.frame.height, width: invisibleSizingCard.frame.width, height: invisibleSizingCard.frame.height)
            var topTemporaryWarCardThree = UIImageView()
            topTemporaryWarCardThree = UIImageView(image: #imageLiteral(resourceName: "Card Back"))
            topTemporaryWarCardThree.alpha = 0
            topTemporaryWarCardThree.frame = CGRect(x: view.center.x - (invisibleSizingCard.frame.width / 2), y: view.frame.height - view.frame.height, width: invisibleSizingCard.frame.width, height: invisibleSizingCard.frame.height)
            
            UIView.animate(withDuration: 1.0, delay: 1.2, options: .curveEaseOut, animations: {
                self.backgroundImageView.addSubview(bottomTemporaryWarCardThree)
                bottomTemporaryWarCardThree.alpha = 1
                bottomTemporaryWarCardThree.frame = CGRect(x: self.view.center.x - (self.invisibleSizingCard.frame.width / 2), y: self.view.center.y + ((self.invisibleSizingCard.frame.height / 7) * 3), width: self.invisibleSizingCard.frame.width, height: self.invisibleSizingCard.frame.height)
                self.backgroundImageView.addSubview(topTemporaryWarCardThree)
                topTemporaryWarCardThree.alpha = 1
                topTemporaryWarCardThree.frame = CGRect(x: self.view.center.x - (self.invisibleSizingCard.frame.width / 2), y: self.view.center.y - ((self.invisibleSizingCard.frame.height / 7) * 10), width: self.invisibleSizingCard.frame.width, height: self.invisibleSizingCard.frame.height)
            }, completion: nil)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2, execute: {
                self.randomPlayerOneIndex = Int(arc4random_uniform(UInt32(self.playerOneCardsArray.count)))
                self.randomPlayerTwoIndex = Int(arc4random_uniform(UInt32(self.playerTwoCardsArray.count)))
                self.playerOneLastCardImageAtCorrespondingIndex = self.playerOneCardsArray[self.randomPlayerOneIndex]
                self.playerTwoLastCardImageAtCorrespondingIndex = self.playerTwoCardsArray[self.randomPlayerTwoIndex]
                
                self.playerOneCardsArray.remove(at: self.randomPlayerOneIndex)
                self.playerTwoCardsArray.remove(at: self.randomPlayerTwoIndex)
                self.cardsArray.append(self.playerOneLastCardImageAtCorrespondingIndex)
                self.cardsArray.append(self.playerTwoLastCardImageAtCorrespondingIndex)
                
                self.updateCardLabels()
            })
        }
        
        playerTurnsPassed = 0
    }
    
    @objc func bottomSwipeFunction(sender: UISwipeGestureRecognizer) {
        determinePlayerOneCardAndNumber()
        playerOneCard.alpha = 1
        
        playerOneCardsArray.remove(at: randomPlayerOneIndex)
        cardsArray.append(playerOneLastCardImageAtCorrespondingIndex)
        updateCardLabels()
        
        playCardSoundEffect()
        backgroundImageView.addSubview(playerOneCard)
        
        playerOneCard.frame = CGRect(x: view.center.x - (invisibleSizingCard.frame.width / 2), y: view.frame.height - invisibleSizingCard.frame.height, width: invisibleSizingCard.frame.width, height: invisibleSizingCard.frame.height)
        
        UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations:{
            self.playerOneCard.frame = CGRect(x: self.view.center.x - (self.invisibleSizingCard.frame.width / 2), y: self.view.center.y, width: self.invisibleSizingCard.frame.width, height: self.invisibleSizingCard.frame.height)
        }, completion: nil)
        
        playerWhoseTurnIsOver = 1
        playerTurnFunction()
        
        if playerTurnsPassed == 2 {
            if playerOneNumber > playerTwoNumber {
                playerOneWinsRound()
                turnOffSwipeGestures(delayTime: 1.5)
            } else if playerOneNumber < playerTwoNumber {
                playerTwoWinsRound()
                turnOffSwipeGestures(delayTime: 1.5)
            } else if playerOneNumber == playerTwoNumber {
                warFunction()
            }
        }
        
        playerTurnsPassed += 1
    }
    
    @objc func topSwipeFunction(sender: UISwipeGestureRecognizer) {
        determinePlayerTwoCardAndNumber()
        playerTwoCard.alpha = 1
        
        playerTwoCardsArray.remove(at: randomPlayerTwoIndex)
        cardsArray.append(playerTwoLastCardImageAtCorrespondingIndex)
        updateCardLabels()
        
        playCardSoundEffect()
        backgroundImageView.addSubview(playerTwoCard)
        
        playerTwoCard.frame = CGRect(x: view.center.x - (invisibleSizingCard.frame.width / 2), y: view.frame.height - view.frame.height, width: invisibleSizingCard.frame.width, height: invisibleSizingCard.frame.height)
        playerTwoCard.transform = CGAffineTransform(rotationAngle: CGFloat.pi)
        
        UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations:{
                self.playerTwoCard.frame = CGRect(x: self.view.center.x - (self.invisibleSizingCard.frame.width / 2), y: self.view.center.y - self.invisibleSizingCard.frame.height, width: self.invisibleSizingCard.frame.width, height: self.invisibleSizingCard.frame.height)
            }, completion: nil)
        
        playerWhoseTurnIsOver = 2
        playerTurnFunction()
        
        if playerTurnsPassed == 2 {
            if playerTwoNumber > playerOneNumber {
                playerTwoWinsRound()
                turnOffSwipeGestures(delayTime: 1.5)
            } else if playerTwoNumber < playerOneNumber {
                playerOneWinsRound()
                turnOffSwipeGestures(delayTime: 1.5)
            } else if playerTwoNumber == playerOneNumber {
                warFunction()
            }
        }
        
        playerTurnsPassed += 1
    }
    
    func distributeCards() {
        while playerOneCardsArray.count < 26 {
            randomPlayerOneIndex = Int(arc4random_uniform(UInt32(cardsArray.count)))
            playerOneCardsArray.append(cardsArray[randomPlayerOneIndex])
            cardsArray.remove(at: randomPlayerOneIndex)
            cardsArray.shuffle()
        }
        
        while playerTwoCardsArray.count < 26 {
            randomPlayerTwoIndex = Int(arc4random_uniform(UInt32(cardsArray.count)))
            playerTwoCardsArray.append(cardsArray[randomPlayerTwoIndex])
            cardsArray.remove(at: randomPlayerTwoIndex)
            cardsArray.shuffle()
        }
    }
    
    func determinePlayerOneCardAndNumber() {
        randomPlayerOneIndex = Int(arc4random_uniform(UInt32(playerOneCardsArray.count)))
        playerOneLastCardImageAtCorrespondingIndex = playerOneCardsArray[randomPlayerOneIndex]
        playerOneCard.image = playerOneLastCardImageAtCorrespondingIndex
        
        if playerOneCard.image == #imageLiteral(resourceName: "club_2") || playerOneCard.image == #imageLiteral(resourceName: "spade_2") || playerOneCard.image == #imageLiteral(resourceName: "diamond_2") || playerOneCard.image == #imageLiteral(resourceName: "heart_2") {
            playerOneNumber = 1
        } else if playerOneCard.image == #imageLiteral(resourceName: "club_3") || playerOneCard.image == #imageLiteral(resourceName: "spade_3") || playerOneCard.image == #imageLiteral(resourceName: "diamond_3") || playerOneCard.image == #imageLiteral(resourceName: "heart_3") {
            playerOneNumber = 2
        } else if playerOneCard.image == #imageLiteral(resourceName: "club_4") || playerOneCard.image == #imageLiteral(resourceName: "spade_4") || playerOneCard.image == #imageLiteral(resourceName: "diamond_4") || playerOneCard.image == #imageLiteral(resourceName: "heart_4") {
            playerOneNumber = 3
        } else if playerOneCard.image == #imageLiteral(resourceName: "club_5") || playerOneCard.image == #imageLiteral(resourceName: "spade_5") || playerOneCard.image == #imageLiteral(resourceName: "diamond_5") || playerOneCard.image == #imageLiteral(resourceName: "heart_5") {
            playerOneNumber = 4
        } else if playerOneCard.image == #imageLiteral(resourceName: "club_6") || playerOneCard.image == #imageLiteral(resourceName: "spade_6") || playerOneCard.image == #imageLiteral(resourceName: "diamond_6") || playerOneCard.image == #imageLiteral(resourceName: "heart_6") {
            playerOneNumber = 5
        } else if playerOneCard.image == #imageLiteral(resourceName: "club_7") || playerOneCard.image == #imageLiteral(resourceName: "spade_7") || playerOneCard.image == #imageLiteral(resourceName: "diamond_7") || playerOneCard.image == #imageLiteral(resourceName: "heart_7") {
            playerOneNumber = 6
        } else if playerOneCard.image == #imageLiteral(resourceName: "club_8") || playerOneCard.image == #imageLiteral(resourceName: "spade_8") || playerOneCard.image == #imageLiteral(resourceName: "diamond_8") || playerOneCard.image == #imageLiteral(resourceName: "heart_8") {
            playerOneNumber = 7
        } else if playerOneCard.image == #imageLiteral(resourceName: "club_9") || playerOneCard.image == #imageLiteral(resourceName: "spade_9") || playerOneCard.image == #imageLiteral(resourceName: "diamond_9") || playerOneCard.image == #imageLiteral(resourceName: "heart_9") {
            playerOneNumber = 8
        } else if playerOneCard.image == #imageLiteral(resourceName: "club_10") || playerOneCard.image == #imageLiteral(resourceName: "spade_10") || playerOneCard.image == #imageLiteral(resourceName: "diamond_10") || playerOneCard.image == #imageLiteral(resourceName: "heart_10") {
            playerOneNumber = 9
        } else if playerOneCard.image == #imageLiteral(resourceName: "club_jack") || playerOneCard.image == #imageLiteral(resourceName: "spade_jack") || playerOneCard.image == #imageLiteral(resourceName: "diamond_jack") || playerOneCard.image == #imageLiteral(resourceName: "heart_jack") {
            playerOneNumber = 10
        } else if playerOneCard.image == #imageLiteral(resourceName: "club_queen") || playerOneCard.image == #imageLiteral(resourceName: "spade_queen") || playerOneCard.image == #imageLiteral(resourceName: "diamond_queen") || playerOneCard.image == #imageLiteral(resourceName: "heart_queen") {
            playerOneNumber = 11
        } else if playerOneCard.image == #imageLiteral(resourceName: "club_king") || playerOneCard.image == #imageLiteral(resourceName: "spade_king") || playerOneCard.image == #imageLiteral(resourceName: "diamond_king") || playerOneCard.image == #imageLiteral(resourceName: "heart_king") {
            playerOneNumber = 12
        } else if playerOneCard.image == #imageLiteral(resourceName: "club_ace") || playerOneCard.image == #imageLiteral(resourceName: "spade_ace") || playerOneCard.image == #imageLiteral(resourceName: "diamond_ace") || playerOneCard.image == #imageLiteral(resourceName: "heart_ace") {
            playerOneNumber = 13
        }
    }
    
    func determinePlayerTwoCardAndNumber() {
        randomPlayerTwoIndex = Int(arc4random_uniform(UInt32(playerTwoCardsArray.count)))
        playerTwoLastCardImageAtCorrespondingIndex = playerTwoCardsArray[randomPlayerTwoIndex]
        playerTwoCard.image = playerTwoLastCardImageAtCorrespondingIndex
        
        if playerTwoCard.image == #imageLiteral(resourceName: "club_2") || playerTwoCard.image == #imageLiteral(resourceName: "spade_2") || playerTwoCard.image == #imageLiteral(resourceName: "diamond_2") || playerTwoCard.image == #imageLiteral(resourceName: "heart_2") {
            playerTwoNumber = 1
        } else if playerTwoCard.image == #imageLiteral(resourceName: "club_3") || playerTwoCard.image == #imageLiteral(resourceName: "spade_3") || playerTwoCard.image == #imageLiteral(resourceName: "diamond_3") || playerTwoCard.image == #imageLiteral(resourceName: "heart_3") {
            playerTwoNumber = 2
        } else if playerTwoCard.image == #imageLiteral(resourceName: "club_4") || playerTwoCard.image == #imageLiteral(resourceName: "spade_4") || playerTwoCard.image == #imageLiteral(resourceName: "diamond_4") || playerTwoCard.image == #imageLiteral(resourceName: "heart_4") {
            playerTwoNumber = 3
        } else if playerTwoCard.image == #imageLiteral(resourceName: "club_5") || playerTwoCard.image == #imageLiteral(resourceName: "spade_5") || playerTwoCard.image == #imageLiteral(resourceName: "diamond_5") || playerTwoCard.image == #imageLiteral(resourceName: "heart_5") {
            playerTwoNumber = 4
        } else if playerTwoCard.image == #imageLiteral(resourceName: "club_6") || playerTwoCard.image == #imageLiteral(resourceName: "spade_6") || playerTwoCard.image == #imageLiteral(resourceName: "diamond_6") || playerTwoCard.image == #imageLiteral(resourceName: "heart_6") {
            playerTwoNumber = 5
        } else if playerTwoCard.image == #imageLiteral(resourceName: "club_7") || playerTwoCard.image == #imageLiteral(resourceName: "spade_7") || playerTwoCard.image == #imageLiteral(resourceName: "diamond_7") || playerTwoCard.image == #imageLiteral(resourceName: "heart_7") {
            playerTwoNumber = 6
        } else if playerTwoCard.image == #imageLiteral(resourceName: "club_8") || playerTwoCard.image == #imageLiteral(resourceName: "spade_8") || playerTwoCard.image == #imageLiteral(resourceName: "diamond_8") || playerTwoCard.image == #imageLiteral(resourceName: "heart_8") {
            playerTwoNumber = 7
        } else if playerTwoCard.image == #imageLiteral(resourceName: "club_9") || playerTwoCard.image == #imageLiteral(resourceName: "spade_9") || playerTwoCard.image == #imageLiteral(resourceName: "diamond_9") || playerTwoCard.image == #imageLiteral(resourceName: "heart_9") {
            playerTwoNumber = 8
        } else if playerTwoCard.image == #imageLiteral(resourceName: "club_10") || playerTwoCard.image == #imageLiteral(resourceName: "spade_10") || playerTwoCard.image == #imageLiteral(resourceName: "diamond_10") || playerTwoCard.image == #imageLiteral(resourceName: "heart_10") {
            playerTwoNumber = 9
        } else if playerTwoCard.image == #imageLiteral(resourceName: "club_jack") || playerTwoCard.image == #imageLiteral(resourceName: "spade_jack") || playerTwoCard.image == #imageLiteral(resourceName: "diamond_jack") || playerTwoCard.image == #imageLiteral(resourceName: "heart_jack") {
            playerTwoNumber = 10
        } else if playerTwoCard.image == #imageLiteral(resourceName: "club_queen") || playerTwoCard.image == #imageLiteral(resourceName: "spade_queen") || playerTwoCard.image == #imageLiteral(resourceName: "diamond_queen") || playerTwoCard.image == #imageLiteral(resourceName: "heart_queen") {
            playerTwoNumber = 11
        } else if playerTwoCard.image == #imageLiteral(resourceName: "club_king") || playerTwoCard.image == #imageLiteral(resourceName: "spade_king") || playerTwoCard.image == #imageLiteral(resourceName: "diamond_king") || playerTwoCard.image == #imageLiteral(resourceName: "heart_king") {
            playerTwoNumber = 12
        } else if playerTwoCard.image == #imageLiteral(resourceName: "club_ace") || playerTwoCard.image == #imageLiteral(resourceName: "spade_ace") || playerTwoCard.image == #imageLiteral(resourceName: "diamond_ace") || playerTwoCard.image == #imageLiteral(resourceName: "heart_ace") {
            playerTwoNumber = 13
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension MutableCollection {
    /// Shuffles the contents of this collection.
    mutating func shuffle() {
        let c = count
        guard c > 1 else { return }
        
        for (firstUnshuffled, unshuffledCount) in zip(indices, stride(from: c, to: 1, by: -1)) {
            let d: Int = numericCast(arc4random_uniform(numericCast(unshuffledCount)))
            let i = index(firstUnshuffled, offsetBy: d)
            swapAt(firstUnshuffled, i)
        }
    }
}
