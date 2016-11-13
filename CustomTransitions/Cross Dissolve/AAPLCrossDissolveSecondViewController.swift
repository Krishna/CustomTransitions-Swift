//
//  AAPLCrossDissolveSecondViewController.swift
//  CustomTransitions
//
//  Created by 開発 on 2016/2/28.
//
//
/*
 Copyright (C) 2016 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information

 Abstract:
 The presented view controller for the Cross Dissolve demo.
 */

import UIKit

@objc(AAPLCrossDissolveSecondViewController)
class AAPLCrossDissolveSecondViewController: UIViewController {
    
    //| ----------------------------------------------------------------------------
    @IBAction func dismissAction(_: AnyObject) {
        // For the sake of example, this demo implements the presentation and
        // dismissal logic completely in code.  Take a look at the later demos
        // to learn how to integrate custom transitions with segues.
        self.dismiss(animated: true, completion: nil)
    }
    
}
