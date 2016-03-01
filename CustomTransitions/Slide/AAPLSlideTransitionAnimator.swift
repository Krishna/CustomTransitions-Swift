//
//  AAPLSlideTransitionAnimator.swift
//  CustomTransitions
//
//  Created by 開発 on 2016/2/2.
//
//
/*
 Copyright (C) 2016 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information

 Abstract:
 A transition animator that transitions between two view controllers in
  a tab bar controller by sliding both view controllers in a given
  direction.
 */

import UIKit

@objc(AAPLSlideTransitionAnimator)
class AAPLSlideTransitionAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    //! The value for this property determines which direction the view controllers
    //! slide during the transition.  This must be one of UIRectEdgeLeft or
    //! UIRectEdgeRight.
    var targetEdge: UIRectEdge
    
    //| ----------------------------------------------------------------------------
    init(targetEdge: UIRectEdge) {
        self.targetEdge = targetEdge
        super.init()
    }
    
    
    //| ----------------------------------------------------------------------------
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return 0.35
    }
    
    //| ----------------------------------------------------------------------------
    //  Custom transitions within a UITabBarController follow the same
    //  conventions as those used for modal presentations.  Your animator will
    //  be given the incoming and outgoing view controllers along with a container
    //  view where both view controller's views will reside.  Your animator is
    //  tasked with animating the incoming view controller's view into the
    //  container view.  The frame of the incoming view controller's view is
    //  is expected to match the value returned from calling
    //  [transitionContext finalFrameForViewController:toViewController] when
    //  the transition is complete.
    //
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        let fromViewController = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)!
        let toViewController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)!
        
        let containerView = transitionContext.containerView()
        let fromView: UIView
        let toView: UIView
        
        // In iOS 8, the viewForKey: method was introduced to get views that the
        // animator manipulates.  This method should be preferred over accessing
        // the view of the fromViewController/toViewController directly.
        if #available(iOS 8.0, *) {
            fromView = transitionContext.viewForKey(UITransitionContextFromViewKey)!
            toView = transitionContext.viewForKey(UITransitionContextToViewKey)!
        } else {
            fromView = fromViewController.view
            toView = toViewController.view
        }
        
        let fromFrame = transitionContext.initialFrameForViewController(fromViewController)
        let toFrame = transitionContext.finalFrameForViewController(toViewController)
        
        // Based on the configured targetEdge, derive a normalized vector that will
        // be used to offset the frame of the view controllers.
        var offset: CGVector
        if self.targetEdge == UIRectEdge.Left {
            offset = CGVectorMake(-1.0, 0.0)
        } else if self.targetEdge == .Right {
            offset = CGVectorMake(1.0, 0.0)
        } else {
            fatalError("targetEdge must be one of UIRectEdgeLeft, or UIRectEdgeRight.")
        }
        
        // The toView starts off-screen and slides in as the fromView slides out.
        fromView.frame = fromFrame
        toView.frame = CGRectOffset(toFrame, toFrame.size.width * offset.dx * -1,
            toFrame.size.height * offset.dy * -1)
        
        // We are responsible for adding the incoming view to the containerView.
        containerView?.addSubview(toView)
        
        let transitionDuration = self.transitionDuration(transitionContext)
        
        UIView.animateWithDuration(transitionDuration, animations: {
            fromView.frame = CGRectOffset(fromFrame, fromFrame.size.width * offset.dx,
                fromFrame.size.height * offset.dy)
            toView.frame = toFrame
            
            }, completion: {finshed in
                let wasCancelled = transitionContext.transitionWasCancelled()
                // When we complete, tell the transition context
                // passing along the BOOL that indicates whether the transition
                // finished or not.
                transitionContext.completeTransition(!wasCancelled)
        })
    }
    
}