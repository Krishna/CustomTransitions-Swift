//
//  AAPLAppDelegate.swift
//  CustomTransitions
//
//  Created by 開発 on 2016/2/28.
//
//
/*
 Copyright (C) 2016 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information

 Abstract:
 The application delegate.
*/

import UIKit

@UIApplicationMain
@objc(AAPLAppDelegate)
class AAPLAppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    
    //| ----------------------------------------------------------------------------
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject : AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        return true
    }
    
    
    //| ----------------------------------------------------------------------------
    func application(application: UIApplication, supportedInterfaceOrientationsForWindow window: UIWindow?) -> UIInterfaceOrientationMask {
        if #available(iOS 8.0, *) {
            return .All
        } else {
            return .Portrait
        }
    }
    
}