//
//  AAPLCheckerboardTransitionAnimator.swift
//  CustomTransitions
//
//  Created by 開発 on 2016/2/5.
//
//
/*
 Copyright (C) 2016 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information

 Abstract:
 A transition animator that transitions between two view controllers in
  a navigation stack, using a 3D checkerboard effect.
 */

import UIKit

@objc(AAPLCheckerboardTransitionAnimator)
class AAPLCheckerboardTransitionAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    //| ----------------------------------------------------------------------------
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return 3.0
    }
    
    
    //| ----------------------------------------------------------------------------
    //  Custom transitions within a UINavigationController follow the same
    //  conventions as those used for modal presentations.  Your animator will
    //  be given the incoming and outgoing view controllers along with a container
    //  view where both view controller's views will reside.  Your animator is
    //  tasked with animating the incoming view controller's view into the
    //  container view.  The frame of the incoming view controller's view is
    //  is expected to match the value returned from calling
    //  [transitionContext finalFrameForViewController:toViewController] when the
    //  transition is complete.
    //
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        let fromViewController = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)!
        let toViewController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)!
        
        let containerView = transitionContext.containerView()!
        
        // For a Push:
        //      fromView = The current top view controller.
        //      toView   = The incoming view controller.
        // For a Pop:
        //      fromView = The outgoing view controller.
        //      toView   = The new top view controller.
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
            toView = toViewController.view!
        }
        
        // If a push is being animated, the incoming view controller will have a
        // higher index on the navigation stack than the current top view
        // controller.
        let isPush = toViewController.navigationController?.viewControllers.indexOf(toViewController) ?? 0 > fromViewController.navigationController?.viewControllers.indexOf(fromViewController) ?? 0
        
        // Our animation will be operating on snapshots of the fromView and toView,
        // so the final frame of toView can be configured now.
        fromView.frame = transitionContext.initialFrameForViewController(fromViewController)
        toView.frame = transitionContext.finalFrameForViewController(toViewController)
        
        // We are responsible for adding the incoming view to the containerView
        // for the transition.
        containerView.addSubview(toView)
        
        var toViewSnapshot: UIImage? = nil
        
        // Snapshot the fromView.
        UIGraphicsBeginImageContextWithOptions(containerView.bounds.size, true, containerView.window!.screen.scale)
        fromView.drawViewHierarchyInRect(containerView.bounds, afterScreenUpdates: false)
        let fromViewSnapshot = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        // To avoid a blank snapshot, defer snapshotting the incoming view until it
        // has had a chance to perform layout and drawing (1 run-loop cycle).
        dispatch_async(dispatch_get_main_queue()) {
            UIGraphicsBeginImageContextWithOptions(containerView.bounds.size, true, containerView.window!.screen.scale)
            toView.drawViewHierarchyInRect(containerView.bounds, afterScreenUpdates: false)
            toViewSnapshot = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
        }
        
        let transitionContainer = UIView(frame: containerView.bounds)
        transitionContainer.opaque = true
        transitionContainer.backgroundColor = UIColor.blackColor()
        containerView.addSubview(transitionContainer)
        
        // Apply a perpective transform to the sublayers of transitionContainer.
        var t = CATransform3DIdentity
        t.m34 = 1.0 / -900.0
        transitionContainer.layer.sublayerTransform = t
        
        // The size and number of slices is a function of the width.
        let sliceSize = round(CGRectGetWidth(transitionContainer.frame) / 10.0)
        let horizontalSlices = Int(ceil(CGRectGetWidth(transitionContainer.frame) / sliceSize))
        let verticalSlices = Int(ceil(CGRectGetHeight(transitionContainer.frame) / sliceSize))
        
        // transitionSpacing controls the transition duration for each slice.
        // Higher values produce longer animations with multiple slices having
        // their animations 'in flight' simultaneously.
        let transitionSpacing: CGFloat = 160.0
        let transitionDuration = self.transitionDuration(transitionContext)
        
        let transitionVector: CGVector
        if isPush {
            transitionVector = CGVectorMake(CGRectGetMaxX(transitionContainer.bounds) - CGRectGetMinX(transitionContainer.bounds),
                CGRectGetMaxY(transitionContainer.bounds) - CGRectGetMinY(transitionContainer.bounds))
        } else {
            transitionVector = CGVectorMake(CGRectGetMinX(transitionContainer.bounds) - CGRectGetMaxX(transitionContainer.bounds),
                CGRectGetMinY(transitionContainer.bounds) - CGRectGetMaxY(transitionContainer.bounds))
        }
        
        let transitionVectorLength = sqrt(transitionVector.dx * transitionVector.dx + transitionVector.dy * transitionVector.dy)
        let transitionUnitVector = CGVectorMake(transitionVector.dx / transitionVectorLength, transitionVector.dy / transitionVectorLength)
        
        for y in 0..<verticalSlices {
            for x in 0..<horizontalSlices {
                let fromContentLayer = CALayer()
                fromContentLayer.frame = CGRectMake(CGFloat(x) * sliceSize * -1.0, CGFloat(y) * sliceSize * -1.0, containerView.bounds.size.width, containerView.bounds.size.height)
                fromContentLayer.rasterizationScale = fromViewSnapshot.scale
                fromContentLayer.contents = fromViewSnapshot.CGImage
                
                let toContentLayer = CALayer()
                toContentLayer.frame = CGRectMake(CGFloat(x) * sliceSize * -1.0, CGFloat(y) * sliceSize * -1.0, containerView.bounds.size.width, containerView.bounds.size.height)
                
                // Snapshotting the toView was deferred so we must also defer applying
                // the snapshot to the layer's contents.
                dispatch_async(dispatch_get_main_queue()) {
                    // Disable actions so the contents are applied without animation.
                    let wereActiondDisabled = CATransaction.disableActions()
                    CATransaction.setDisableActions(true)
                    
                    toContentLayer.rasterizationScale = toViewSnapshot?.scale ?? 0
                    toContentLayer.contents = toViewSnapshot?.CGImage
                    
                    CATransaction.setDisableActions(wereActiondDisabled)
                }
                
                let toCheckboardSquareView = UIView()
                toCheckboardSquareView.frame = CGRectMake(CGFloat(x) * sliceSize, CGFloat(y) * sliceSize, sliceSize, sliceSize)
                toCheckboardSquareView.opaque = false
                toCheckboardSquareView.layer.masksToBounds = true
                toCheckboardSquareView.layer.doubleSided = false
                toCheckboardSquareView.layer.transform = CATransform3DMakeRotation(CGFloat(M_PI), 0, 1, 0)
                toCheckboardSquareView.layer.addSublayer(toContentLayer)
                
                let fromCheckboardSquareView = UIView()
                fromCheckboardSquareView.frame = CGRectMake(CGFloat(x) * sliceSize, CGFloat(y) * sliceSize, sliceSize, sliceSize)
                fromCheckboardSquareView.opaque = false
                fromCheckboardSquareView.layer.masksToBounds = true
                fromCheckboardSquareView.layer.doubleSided = false
                fromCheckboardSquareView.layer.transform = CATransform3DIdentity
                fromCheckboardSquareView.layer.addSublayer(fromContentLayer)
                
                transitionContainer.addSubview(toCheckboardSquareView)
                transitionContainer.addSubview(fromCheckboardSquareView)
            }
        }
        
        
        // Used to track how many slices have animations which are still in flight.
        var sliceAnimationsPending = 0
        
        for y in 0..<verticalSlices {
            for x in 0..<horizontalSlices {
                let toCheckboardSquareView = transitionContainer.subviews[y * horizontalSlices * 2 + (x * 2)]
                let fromCheckboardSquareView = transitionContainer.subviews[y * horizontalSlices * 2 + (x * 2 + 1)]
                
                let sliceOriginVector: CGVector
                if isPush {
                    // Define a vector from the origin of transitionContainer to the
                    // top left corner of the slice.
                    sliceOriginVector = CGVectorMake(CGRectGetMinX(fromCheckboardSquareView.frame) - CGRectGetMinX(transitionContainer.bounds),
                        CGRectGetMinY(fromCheckboardSquareView.frame) - CGRectGetMinY(transitionContainer.bounds))
                } else {
                    // Define a vector from the bottom right corner of
                    // transitionContainer to the bottom right corner of the slice.
                    sliceOriginVector = CGVectorMake(CGRectGetMaxX(fromCheckboardSquareView.frame) - CGRectGetMaxX(transitionContainer.bounds),
                        CGRectGetMaxY(fromCheckboardSquareView.frame) - CGRectGetMaxY(transitionContainer.bounds))
                }
                
                // Project sliceOriginVector onto transitionVector.
                let dot = sliceOriginVector.dx * transitionVector.dx + sliceOriginVector.dy * transitionVector.dy
                let projection = CGVectorMake(transitionUnitVector.dx * dot/transitionVectorLength,
                    transitionUnitVector.dy * dot/transitionVectorLength)
                
                // Compute the length of the projection.
                let projectionLength = sqrt(projection.dx * projection.dx + projection.dy * projection.dy)
                
                let startTime = NSTimeInterval(projectionLength/(transitionVectorLength + transitionSpacing)) * transitionDuration
                let duration = NSTimeInterval((projectionLength + transitionSpacing)/(transitionVectorLength + transitionSpacing)) * transitionDuration - startTime
                
                sliceAnimationsPending += 1
                
                UIView.animateWithDuration(duration, delay: startTime, options: [], animations: {
                    toCheckboardSquareView.layer.transform = CATransform3DIdentity
                    fromCheckboardSquareView.layer.transform = CATransform3DMakeRotation(CGFloat(M_PI), 0, 1, 0)
                    }, completion: {finished in
                        // Finish the transition once the final animation completes.
                        sliceAnimationsPending -= 1
                        if sliceAnimationsPending == 0 {
                            let wasCancelled = transitionContext.transitionWasCancelled()
                            
                            transitionContainer.removeFromSuperview()
                            
                            // When we complete, tell the transition context
                            // passing along the BOOL that indicates whether the transition
                            // finished or not.
                            transitionContext.completeTransition(!wasCancelled)
                        }
                })
            }
        }
    }
    
}