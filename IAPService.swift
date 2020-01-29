//
//  IAPService.swift
//  CardGames
//
//  Created by Branden Yang on 11/10/17.
//  Copyright © 2017 Branden Yang. All rights reserved.
//

import UIKit
import StoreKit

enum IAPProducts: String {
    case RemovalOfAds = "com.BrandenYang.CardGames.RemovalOfAds"
}

class IAPService: NSObject {

    private override init() {}
    static let shared = IAPService()

    var products = [SKProduct]()
    let paymentQueue = SKPaymentQueue.default()

    func getProducts() {
        let products: Set = [IAPProducts.RemovalOfAds.rawValue
                            /* space for more products here */]
        let request = SKProductsRequest(productIdentifiers: products)
        request.delegate = self
        request.start()
        paymentQueue.add(self)
    }

    func purchase(product: IAPProducts) {
        guard let productToPurchase = products.filter({ $0.productIdentifier == product.rawValue }).first else { return }
        let payment = SKPayment(product: productToPurchase)
        paymentQueue.add(payment)
    }

    func restorePurchases() {
        print("restore purchases")
        paymentQueue.restoreCompletedTransactions()
    }

}

extension IAPService: SKProductsRequestDelegate {
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        products = response.products
        for product in response.products {
            print(product.localizedTitle)
        }
    }
}

extension IAPService: SKPaymentTransactionObserver {
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            print(transaction.transactionState.status(), transaction.payment.productIdentifier)

            switch transaction.transactionState {
            case .purchasing: break
            default: paymentQueue.finishTransaction(transaction)
            }
        }
    }
}

extension SKPaymentTransactionState {

    func status() -> String {
        switch self {
        case .deferred: return "deferred"
        case .failed: return "failed"
        case .purchased: return "purchased"
        case .purchasing: return "purchasing"
        case .restored: return "restored"
        }
    }
}

