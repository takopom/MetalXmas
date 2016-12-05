//
//  ViewController.swift
//  MetalXmas
//
//  Created by takopom on 2016/12/02.
//  Copyright © 2016年 takopom. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    // MARK: Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let metalView = MetalView.init(frame: view.frame)
        view.addSubview(metalView)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

