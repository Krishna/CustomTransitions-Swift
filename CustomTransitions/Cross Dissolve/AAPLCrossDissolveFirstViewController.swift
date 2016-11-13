//
//  AAPLCrossDissolveFirstViewController.swift
//  CustomTransitions
//
//  Created by 開発 on 2016/2/28.
//
//
/*
 Copyright (C) 2016 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information

 Abstract:
 The initial view controller for the Cross Dissolve demo.
 */

import UIKit

@objc(AAPLCrossDissolveFirstViewController)
class AAPLCrossDissolveFirstViewController: UIViewController, UIViewControllerTransitioningDelegate {
    
    
    //| ----------------------------------------------------------------------------
    @IBAction func presentWithCustomTransitionAction(_: AnyObject) {
        // For the sake of example, this demo implements the presentation and
        // dismissal logic completely in code.  Take a look at the later demos
        // to learn how to integrate custom transitions with segues.
        let secondViewController = self.storyboard!.instantiateViewController(withIdentifier: "SecondViewController")
        
        // Setting the modalPresentationStyle to FullScreen enables the
        // <ContextTransitioning> to provide more accurate initial and final frames
        // of the participating view controllers
        secondViewController.modalPresentationStyle = .fullScreen
        
        // The transitioning delegate can supply a custom animation controller
        // that will be used to animate the incoming view controller.
        secondViewController.transitioningDelegate = self
        
        self.present(secondViewController, animated: true, completion: nil)
    }
    
    //MARK: -
    //MARK: UIViewControllerTransitioningDelegate
    
    //| ----------------------------------------------------------------------------
    //  The system calls this method on the presented view controller's
    //  transitioningDelegate to retrieve the animator object used for animating
    //  the presentation of the incoming view controller.  Your implementation is
    //  expected to return an object that conforms to the
    //  UIViewControllerAnimatedTransitioning protocol, or nil if the default
    //  presentation animation should be used.
    //
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return AAPLCrossDissolveTransitionAnimator()
    }
    
    
    //| ----------------------------------------------------------------------------
    //  The system calls this method on the presented view controller's
    //  transitioningDelegate to retrieve the animator object used for animating
    //  the dismissal of the presented view controller.  Your implementation is
    //  expected to return an object that conforms to the
    //  UIViewControllerAnimatedTransitioning protocol, or nil if the default
    //  dismissal animation should be used.
    //
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return AAPLCrossDissolveTransitionAnimator()
    }
    
}
