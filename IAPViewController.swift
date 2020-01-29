//
//  IAPViewController.swift
//  CardGames
//
//  Created by Branden Yang on 11/10/17.
//  Copyright © 2017 Branden Yang. All rights reserved.
//

import UIKit
import StoreKit

class IAPViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        IAPService.shared.getProducts()
    }

    @IBAction func removeAdsIAP(_ sender: Any) {
        IAPService.shared.purchase(product: .RemovalOfAds)
    }

    @IBAction func removeAdsGetInfo(_ sender: Any) {

    }
    
}

