//
//  ViewController.swift
//  ByteCoin
//
//  Created by Angela Yu on 11/09/2019.
//  Copyright © 2019 The App Brewery. All rights reserved.
//

import UIKit

class ByteCoinViewController: UIViewController {
    @IBOutlet weak var bitcoinLabel: UILabel!
    @IBOutlet weak var currencyLabel: UILabel!
    @IBOutlet weak var currencyPicker: UIPickerView!
    
    var coinManager = CoinManager()
    
    var currencyFormatter = NumberFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        currencyFormatter.maximumFractionDigits = 2
        
        currencyPicker.dataSource = self
        currencyPicker.delegate = self
        
        coinManager.delegate = self
        
        initCurrencyPicker(with: 0)
        coinManager.getBitcoinPrice(to: coinManager.currencyArray[0])
    }
    
    func initCurrencyPicker(with row: Int) {
        currencyPicker.selectRow(row, inComponent: 0, animated: false)
        currencyLabel.text = coinManager.currencyArray[currencyPicker.selectedRow(inComponent: 0)]
    }
}


extension ByteCoinViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return coinManager.currencyArray.count
    }
    
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return coinManager.currencyArray[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        //currencyLabel.text = coinManager.currencyArray[row]
        
        coinManager.getBitcoinPrice(to: coinManager.currencyArray[row])

    }
}

extension ByteCoinViewController: CoinManagerDelegate {
    func didReceiveCoinRate(_ sender: CoinManager, coinRate: CoinManager.CoinRate) {
        bitcoinLabel.text = currencyFormatter.string(from: NSNumber(value: coinRate.rate))
        currencyLabel.text = coinRate.asset_id_quote
    }
    
    func didErrorHappened(_ sender: CoinManager, error: Error) {
        print(error)
    }
}
