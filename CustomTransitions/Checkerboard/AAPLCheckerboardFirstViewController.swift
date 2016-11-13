//
//  AAPLCheckerboardFirstViewController.swift
//  CustomTransitions
//
//  Created by 開発 on 2016/2/7.
//
//
/*
 Copyright (C) 2016 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information

 Abstract:
 The initial view controller for the Checkerboard demo.
 */

import UIKit

@objc(AAPLCheckerboardFirstViewController)
class AAPLCheckerboardFirstViewController: UIViewController, UINavigationControllerDelegate {
    
    
    //| ----------------------------------------------------------------------------
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.delegate = self
    }
    
    //MARK: -
    //MARK: UINavigationControllerDelegate
    
    //| ----------------------------------------------------------------------------
    //  The navigation controller tries to invoke this method on its delegate to
    //  retrieve an animator object to be used for animating the transition to the
    //  incoming view controller.  Your implementation is expected to return an
    //  object that conforms to the UIViewControllerAnimatedTransitioning protocol,
    //  or nil if the transition should use the navigation controller's default
    //  push/pop animation.
    //
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationControllerOperation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return AAPLCheckerboardTransitionAnimator()
    }
    
}
