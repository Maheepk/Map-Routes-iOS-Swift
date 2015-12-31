//
//  DismissSegue.swift
//  TaskProject
//
//  Created by Maheep Kaushal on 31/12/15.
//  Copyright © 2015 Maheep Kaushal. All rights reserved.
//

import UIKit

class DismissSegue: UIStoryboardSegue {
    
    override func perform() {
        let sourceViewController = self.sourceViewController
        sourceViewController.dismissViewControllerAnimated(true, completion: nil)
    }
    
}