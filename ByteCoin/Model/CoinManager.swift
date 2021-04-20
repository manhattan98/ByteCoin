//
//  CoinManager.swift
//  ByteCoin
//
//  Created by Angela Yu on 11/09/2019.
//  Copyright © 2019 The App Brewery. All rights reserved.
//

import Foundation

struct CoinManager {
    struct CoinRate: Decodable {
        /**
         Time in ISO 8601 of the market data used to calculate exchange rate
         */
        let time: String
        
        /**
         Exchange rate base asset identifier
         */
        let asset_id_base: String
        
        /**
         Exchange rate quote asset identifier
         */
        let asset_id_quote: String
        
        /**
         Exchange rate between assets
         */
        let rate: Double
    }
    
    let baseURL = "https://rest.coinapi.io/v1/exchangerate/"
    let apiKey = "9778EF8D-AB3F-403D-82F3-A3B0980353BE"
    
    let currencyArray = ["AUD", "BRL","CAD","CNY","EUR","GBP","HKD","IDR","ILS","INR","JPY","MXN","NOK","NZD","PLN","RON","RUB","SEK","SGD","USD","ZAR"]

    var delegate: CoinManagerDelegate? = nil
    
    private func getExchangeRateRequest(asset_id_base: String, asset_id_quote: String) -> String {
        return
            baseURL + asset_id_base + "/" + asset_id_quote + "?apikey=" + apiKey
    }
    
    func getBitcoinPrice(to currency: String) {
        getCoinPrice(for: "BTC", to: currency)
    }
    
    func getCoinPrice(for coin: String, to currency: String) {
        performRequest { () -> URL? in
            return URL(string: getExchangeRateRequest(asset_id_base: coin, asset_id_quote: currency))
        }
    }
    
    private func performRequest(instantiateURL: () -> URL?) {
        if let safeUrl = instantiateURL() {
            print(safeUrl)
            URLSession(configuration: .default)
                .dataTask(with: URLRequest(url: safeUrl)) { (data, response, error) in
                    if let receivedData = data {
                        do {
                            let rate = try JSONDecoder().decode(CoinRate.self, from: receivedData)
                            
                            DispatchQueue.main.async {
                                delegate?.didReceiveCoinRate(self, coinRate: rate)
                            }
                        } catch let decodingError {
                            DispatchQueue.main.async {
                                delegate?.didErrorHappened(self, error: decodingError)
                            }
                        }
                    } else {
                        DispatchQueue.main.async {
                            delegate?.didErrorHappened(self, error: URLError(.badServerResponse))
                        }
                    }
            }
            .resume()
        } else {
            DispatchQueue.main.async {
                delegate?.didErrorHappened(self, error: URLError(.unsupportedURL))
            }
        }
        
    }
}

protocol CoinManagerDelegate {
    func didReceiveCoinRate(_ sender: CoinManager, coinRate: CoinManager.CoinRate)
    func didErrorHappened(_ sender: CoinManager, error: Error)
}
