//
//  AAPLCrossDissolveTransitionAnimator.swift
//  CustomTransitions
//
//  Created by 開発 on 2016/2/28.
//
//
/*
 Copyright (C) 2016 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information

 Abstract:
 A transition animator that performs a cross dissolve transition between
  two view controllers.
 */

import UIKit

@objc(AAPLCrossDissolveTransitionAnimator)
class AAPLCrossDissolveTransitionAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    //| ----------------------------------------------------------------------------
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.35
    }
    
    
    //| ----------------------------------------------------------------------------
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let fromViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)!
        let toViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)!
        
        let containerView = transitionContext.containerView
        
        // For a Presentation:
        //      fromView = The presenting view.
        //      toView   = The presented view.
        // For a Dismissal:
        //      fromView = The presented view.
        //      toView   = The presenting view.
        let fromView: UIView?
        let toView: UIView?
        
        // In iOS 8, the viewForKey: method was introduced to get views that the
        // animator manipulates.  This method should be preferred over accessing
        // the view of the fromViewController/toViewController directly.
        // It may return nil whenever the animator should not touch the view
        // (based on the presentation style of the incoming view controller).
        // It may also return a different view for the animator to animate.
        //
        // Imagine that you are implementing a presentation similar to form sheet.
        // In this case you would want to add some shadow or decoration around the
        // presented view controller's view. The animator will animate the
        // decoration view instead and the presented view controller's view will
        // be a child of the decoration view.
        if #available(iOS 8.0, *) {
            fromView = transitionContext.view(forKey: UITransitionContextViewKey.from)
            toView = transitionContext.view(forKey: UITransitionContextViewKey.to)
        } else {
            fromView = fromViewController.view
            toView = toViewController.view
        }
        
        fromView?.frame = transitionContext.initialFrame(for: fromViewController)
        toView?.frame = transitionContext.finalFrame(for: toViewController)
        
        fromView?.alpha = 1.0
        toView?.alpha = 0.0
        
        // We are responsible for adding the incoming view to the containerView
        // for the presentation/dismissal.
        if( toView != nil ) {containerView.addSubview(toView!)}
        
        let transitionDuration = self.transitionDuration(using: transitionContext)
        
        UIView.animate(withDuration: transitionDuration, animations: {
            fromView?.alpha = 0.0
            toView?.alpha = 1.0
            }, completion: {finished in
                // When we complete, tell the transition context
                // passing along the BOOL that indicates whether the transition
                // finished or not.
                let wasCancelled = transitionContext.transitionWasCancelled
                transitionContext.completeTransition(!wasCancelled)
        })
    }
    
}
