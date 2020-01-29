//
//  ShopViewController.swift
//  CardGames
//
//  Created by Branden Yang on 10/29/17.
//  Copyright © 2017 Branden Yang. All rights reserved.
//

import UIKit
import StoreKit
import SwiftyStoreKit
import CoreData

/*
 --------------------------
 --------------------------
 M O D I F I C A T I O N S:
 --------------------------
 --------------------------

 > Try to first use the other code, then if that works then you can try to use this one. If this doesn't work then just use the other one (REMEMBER - This is only AFTER you resolve issues in "Agreements, Taxes and Banking")
 > Fix the bool statement with CoreData and stuff (find out how to use coredata to store it, if its easier look into using cloudkit or something)

 */

var sharedSecret = "53eacf4afaee4d9c8087c6af7ba5d759"

enum RegisteredPurchase : String {
    case removalOfAds = "RemovalOfAds"
    case autoRenewablePurchase
    case nonRenewablePurchase
}

class NetworkActivityIndicatorManager: NSObject {

    private static var loadingCount = 0

    class func networkOperationStarted() {

        #if os(iOS)
            if loadingCount == 0 {
                UIApplication.shared.isNetworkActivityIndicatorVisible = true
            }
            loadingCount += 1
        #endif
    }

    class func networkOperationFinished() {
        #if os(iOS)
            if loadingCount > 0 {
                loadingCount -= 1
            }
            if loadingCount == 0 {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
        #endif
    }
}

class ShopViewController: UIViewController {

    let bundleID = "com.BrandenYang.CardGames"

    let removalOfAds = RegisteredPurchase.removalOfAds

    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    var hasBeenPurchased = Bool()

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    @IBAction func removeAdsAction(_ sender: Any) {
        //purchase product
        //purchase(removalOfAds)
    }

    @IBAction func removeAdsInfo(_ sender: Any) {
        //get info for product
        //getInfo(removalOfAds)
    }

        func getInfo(_ purchase: RegisteredPurchase) {

            NetworkActivityIndicatorManager.networkOperationStarted()
            SwiftyStoreKit.retrieveProductsInfo([bundleID + "." + purchase.rawValue]) { result in
                NetworkActivityIndicatorManager.networkOperationFinished()

                self.showAlert(self.alertForProductRetrievalInfo(result))
            }
        }

        func purchase(_ purchase: RegisteredPurchase) {

            NetworkActivityIndicatorManager.networkOperationStarted()
            SwiftyStoreKit.purchaseProduct(bundleID + "." + purchase.rawValue, atomically: true) { result in
                NetworkActivityIndicatorManager.networkOperationFinished()

                if case .success(let purchase) = result {
                    // Deliver content from server, then:

                    if purchase.productId == self.bundleID + "." + self.removalOfAds.rawValue {
                        print("works here")
                    }

                    if purchase.needsFinishTransaction {
                        SwiftyStoreKit.finishTransaction(purchase.transaction)
                    }
                }
                if let alert = self.alertForPurchaseResult(result) {
                    self.showAlert(alert)
                }
            }
        }

        @IBAction func restorePurchases() {

            NetworkActivityIndicatorManager.networkOperationStarted()
            SwiftyStoreKit.restorePurchases(atomically: true) { results in
                NetworkActivityIndicatorManager.networkOperationFinished()

                for purchase in results.restoredPurchases where purchase.needsFinishTransaction {
                    // Deliver content from server, then:
                    SwiftyStoreKit.finishTransaction(purchase.transaction)
                }
                self.showAlert(self.alertForRestorePurchases(results))
            }
        }

        @IBAction func verifyReceipt() {

            NetworkActivityIndicatorManager.networkOperationStarted()
            verifyReceipt { result in
                NetworkActivityIndicatorManager.networkOperationFinished()
                self.showAlert(self.alertForVerifyReceipt(result))
            }
        }

        func verifyReceipt(completion: @escaping (VerifyReceiptResult) -> Void) {

            let appleValidator = AppleReceiptValidator(service: .production, sharedSecret: sharedSecret)
            SwiftyStoreKit.verifyReceipt(using: appleValidator, completion: completion)
        }

        func verifyPurchase(_ purchase: RegisteredPurchase) {

            NetworkActivityIndicatorManager.networkOperationStarted()
            verifyReceipt { result in
                NetworkActivityIndicatorManager.networkOperationFinished()

                switch result {
                case .success(let receipt):

                    let productId = self.bundleID + "." + purchase.rawValue

                    switch purchase {
                    case .autoRenewablePurchase:
                        let purchaseResult = SwiftyStoreKit.verifySubscription(
                            type: .autoRenewable,
                            productId: productId,
                            inReceipt: receipt,
                            validUntil: Date()
                        )
                        self.showAlert(self.alertForVerifySubscription(purchaseResult))
                    case .nonRenewablePurchase:
                        let purchaseResult = SwiftyStoreKit.verifySubscription(
                            type: .nonRenewing(validDuration: 60),
                            productId: productId,
                            inReceipt: receipt,
                            validUntil: Date()
                        )
                        self.showAlert(self.alertForVerifySubscription(purchaseResult))
                    default:
                        let purchaseResult = SwiftyStoreKit.verifyPurchase(
                            productId: productId,
                            inReceipt: receipt
                        )
                        self.showAlert(self.alertForVerifyPurchase(purchaseResult))
                    }

                case .error:
                    self.showAlert(self.alertForVerifyReceipt(result))
                }
            }
        }

        #if os(iOS)
        override var preferredStatusBarStyle: UIStatusBarStyle {
            return .lightContent
        }
        #endif
}

extension ShopViewController {

    func alertWithTitle(_ title: String, message: String) -> UIAlertController {

        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        return alert
    }

    func showAlert(_ alert: UIAlertController) {
        guard self.presentedViewController != nil else {
            self.present(alert, animated: true, completion: nil)
            return
        }
    }

    func alertForProductRetrievalInfo(_ result: RetrieveResults) -> UIAlertController {

        if let product = result.retrievedProducts.first {
            let priceString = product.localizedPrice!
            return alertWithTitle(product.localizedTitle, message: "\(product.localizedDescription) - \(priceString)")
        } else if let invalidProductId = result.invalidProductIDs.first {
            return alertWithTitle("Could not retrieve product info", message: "Invalid product identifier: \(invalidProductId)")
        } else {
            let errorString = result.error?.localizedDescription ?? "Unknown error. Please contact support"
            return alertWithTitle("Could not retrieve product info", message: errorString)
        }
    }

    func alertForPurchaseResult(_ result: PurchaseResult) -> UIAlertController? {
        switch result {
        case .success(let purchase):
            print("Purchase Success: \(purchase.productId)")
            return alertWithTitle("Thank You", message: "Purchase completed")
        case .error(let error):
            print("Purchase Failed: \(error)")
            switch error.code {
            case .unknown: return alertWithTitle("Purchase failed", message: error.localizedDescription)
            case .clientInvalid: // client is not allowed to issue the request, etc.
                return alertWithTitle("Purchase failed", message: "Not allowed to make the payment")
            case .paymentCancelled: // user cancelled the request, etc.
                return nil
            case .paymentInvalid: // purchase identifier was invalid, etc.
                return alertWithTitle("Purchase failed", message: "The purchase identifier was invalid")
            case .paymentNotAllowed: // this device is not allowed to make the payment
                return alertWithTitle("Purchase failed", message: "The device is not allowed to make the payment")
            case .storeProductNotAvailable: // Product is not available in the current storefront
                return alertWithTitle("Purchase failed", message: "The product is not available in the current storefront")
            case .cloudServicePermissionDenied: // user has not allowed access to cloud service information
                return alertWithTitle("Purchase failed", message: "Access to cloud service information is not allowed")
            case .cloudServiceNetworkConnectionFailed: // the device could not connect to the nework
                return alertWithTitle("Purchase failed", message: "Could not connect to the network")
            case .cloudServiceRevoked: // user has revoked permission to use this cloud service
                return alertWithTitle("Purchase failed", message: "Cloud service was revoked")
            }
        }
    }

    func alertForRestorePurchases(_ results: RestoreResults) -> UIAlertController {

        if results.restoreFailedPurchases.count > 0 {
            print("Restore Failed: \(results.restoreFailedPurchases)")
            return alertWithTitle("Restore failed", message: "Unknown error. Please contact support")
        } else if results.restoredPurchases.count > 0 {
            print("Restore Success: \(results.restoredPurchases)")
            return alertWithTitle("Purchases Restored", message: "All purchases have been restored")
        } else {
            print("Nothing to Restore")
            return alertWithTitle("Nothing to restore", message: "No previous purchases were found")
        }
    }

    func alertForVerifyReceipt(_ result: VerifyReceiptResult) -> UIAlertController {

        switch result {
        case .success(let receipt):
            print("Verify receipt Success: \(receipt)")
            return alertWithTitle("Receipt verified", message: "Receipt verified remotely")
        case .error(let error):
            print("Verify receipt Failed: \(error)")
            switch error {
            case .noReceiptData:
                return alertWithTitle("Receipt verification", message: "No receipt data. Try again.")
            case .networkError(let error):
                return alertWithTitle("Receipt verification", message: "Network error while verifying receipt: \(error)")
            default:
                return alertWithTitle("Receipt verification", message: "Receipt verification failed: \(error)")
            }
        }
    }

    func alertForVerifySubscription(_ result: VerifySubscriptionResult) -> UIAlertController {

        switch result {
        case .purchased(let expiryDate):
            print("Product is valid until \(expiryDate)")
            return alertWithTitle("Product is purchased", message: "Product is valid until \(expiryDate)")
        case .expired(let expiryDate):
            print("Product is expired since \(expiryDate)")
            return alertWithTitle("Product expired", message: "Product is expired since \(expiryDate)")
        case .notPurchased:
            print("This product has never been purchased")
            return alertWithTitle("Not purchased", message: "This product has never been purchased")
        }
    }

    func alertForVerifyPurchase(_ result: VerifyPurchaseResult) -> UIAlertController {

        switch result {
        case .purchased:
            print("Product is purchased")
            return alertWithTitle("Product is purchased", message: "Product will not expire")
        case .notPurchased:
            print("This product has never been purchased")
            return alertWithTitle("Not purchased", message: "This product has never been purchased")
        }
    }
}


