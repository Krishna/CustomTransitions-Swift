//
//  AAPLMenuViewController.swift
//  CustomTransitions
//
//  Created by 開発 on 2016/2/28.
//
//
/*
 Copyright (C) 2016 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information

 Abstract:
 Displays the list of examples.
 */

import UIKit

@objc(AAPLMenuViewController)
class AAPLMenuViewController: UITableViewController {
    
    //| ----------------------------------------------------------------------------
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        // Certain examples are only supported on iOS 8 and later.
        if #available(iOS 8.0, *) {
            return true
        } else {
            let iOS7Examples = ["CrossDissolve", "Dynamics", "Swipe", "Checkerboard", "Slide"]
            
            if !iOS7Examples.contains(identifier) {
                self.tableView.deselectRow(at: self.tableView.indexPathForSelectedRow!, animated: true)
                
                let alert = UIAlertView(title: "Can not load example.", message: "This example requires iOS 8 or later.", delegate: nil, cancelButtonTitle: "OK")
                alert.show()
                
                return false
            }
        }
        
        return true
    }
    
    
    //| ----------------------------------------------------------------------------
    @IBAction func unwindToMenuViewController(_: UIStoryboardSegue) {
    }
    
}
