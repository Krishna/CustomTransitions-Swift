//
//  AAPLAdaptivePresentationSegue.swift
//  CustomTransitions
//
//  Created by 開発 on 2016/2/13.
//
//
/*
 Copyright (C) 2016 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information

 */

import UIKit

@available(iOS 8.0, *)
@objc(AAPLAdaptivePresentationSegue)
class AAPLAdaptivePresentationSegue: UIStoryboardSegue {
    
    //| ----------------------------------------------------------------------------
    override func perform() {
        let sourceViewController = self.destination
        let destinationViewController = self.destination
        
        // For presentations which will use a custom presentation controller,
        // it is possible for that presentation controller to also be the
        // transitioningDelegate.
        //
        // transitioningDelegate does not hold a strong reference to its
        // destination object.  To prevent presentationController from being
        // released prior to calling -presentViewController:animated:completion:
        // the NS_VALID_UNTIL_END_OF_SCOPE attribute is appended to the declaration.
        
        let presentationController = AAPLAdaptivePresentationController(presentedViewController: destinationViewController, presenting: sourceViewController)
        
        destinationViewController.transitioningDelegate = presentationController
        
        self.source.present(destinationViewController, animated: true, completion: {
            let _ = presentationController
        })
    }
    
}
