//
//  AAPLExternalStoryboardSegue.swift
//  CustomTransitions
//
//  Created by 開発 on 2016/2/28.
//
//
/*
 Copyright (C) 2016 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information

 Abstract:
 A custom storyboard segue that loads its destination view controller from an
  external storyboard (named by the segue's identifier), then presents it
  modally.
 */

import UIKit

@objc(AAPLExternalStoryboardSegue)
class AAPLExternalStoryboardSegue: UIStoryboardSegue {

//  NOTE: iOS 9 introduces storyboard references which allow a segue to
//        target the initial scene in an external storyboard.  If your
//        application targets iOS 9 and above, you should use storyboard
//        references rather than the technique shown here.

//| ----------------------------------------------------------------------------
    override init(identifier: String?, source: UIViewController, destination: UIViewController) {
    // Load the storyboard named by this segue's identifier.
        let externalStoryboard = UIStoryboard(name: identifier!, bundle: Bundle(for: AAPLExternalStoryboardSegue.self))

    // Instantiate the storyboard's initial view controller.
        let initialViewController = externalStoryboard.instantiateInitialViewController()!

        super.init(identifier: identifier, source: source, destination: initialViewController)
    }


//| ----------------------------------------------------------------------------
    override func perform() {
        self.source.present(self.destination, animated: true, completion: nil)
    }

}
