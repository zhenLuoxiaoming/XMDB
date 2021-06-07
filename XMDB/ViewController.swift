//
//  ViewController.swift
//  XMDB
//
//  Created by Rowling on 2021/5/28.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        XMCityUtil.getAddressInfo(adcode: "110000") { r in
            if let r = r {
                print(r)
            }
        }
        // Do any additional setup after loading the view.
    }


    
}

