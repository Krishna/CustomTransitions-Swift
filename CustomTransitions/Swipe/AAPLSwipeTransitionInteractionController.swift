//
//  AAPLSwipeTransitionInteractionController.swift
//  CustomTransitions
//
//  Created by 開発 on 2016/2/14.
//
//
/*
 Copyright (C) 2016 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information

 Abstract:
 The interaction controller for the Swipe demo.  Tracks a UIScreenEdgePanGestureRecognizer
  from a specified screen edge and derives the completion percentage for the
  transition.
 */

import UIKit

@objc(AAPLSwipeTransitionInteractionController)
class AAPLSwipeTransitionInteractionController: UIPercentDrivenInteractiveTransition {
    
    weak var transitionContext: UIViewControllerContextTransitioning?
    let gestureRecognizer: UIScreenEdgePanGestureRecognizer
    let edge: UIRectEdge
    
    
    //| ----------------------------------------------------------------------------
    init(gestureRecognizer: UIScreenEdgePanGestureRecognizer, edgeForDragging edge: UIRectEdge) {
        assert(edge == .top || edge == .bottom ||
            edge == .left || edge == .right,
            "edgeForDragging must be one of UIRectEdgeTop, UIRectEdgeBottom, UIRectEdgeLeft, or UIRectEdgeRight.")
        
        self.gestureRecognizer = gestureRecognizer
        self.edge = edge
        super.init()
        
        // Add self as an observer of the gesture recognizer so that this
        // object receives updates as the user moves their finger.
        gestureRecognizer.addTarget(self, action: #selector(AAPLSwipeTransitionInteractionController.gestureRecognizeDidUpdate(_:)))
    }
    
    
    //| ----------------------------------------------------------------------------
    //- (instancetype)init
    //{
    //    @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"Use -initWithGestureRecognizer:edgeForDragging:" userInfo:nil];
    //}
    
    
    //| ----------------------------------------------------------------------------
    deinit {
        self.gestureRecognizer.removeTarget(self, action: #selector(AAPLSwipeTransitionInteractionController.gestureRecognizeDidUpdate(_:)))
    }
    
    
    //| ----------------------------------------------------------------------------
    override func startInteractiveTransition(_ transitionContext: UIViewControllerContextTransitioning) {
        // Save the transitionContext for later.
        self.transitionContext = transitionContext
        
        super.startInteractiveTransition(transitionContext)
    }
    
    
    //| ----------------------------------------------------------------------------
    //! Returns the offset of the pan gesture recognizer from the edge of the
    //! screen as a percentage of the transition container view's width or height.
    //! This is the percent completed for the interactive transition.
    //
    fileprivate func percentForGesture(_ gesture: UIScreenEdgePanGestureRecognizer) -> CGFloat {
        // Because view controllers will be sliding on and off screen as part
        // of the animation, we want to base our calculations in the coordinate
        // space of the view that will not be moving: the containerView of the
        // transition context.
        let transitionContainerView = self.transitionContext?.containerView
        
        let locationInSourceView = gesture.location(in: transitionContainerView)
        
        // Figure out what percentage we've gone.
        
        let width = (transitionContainerView?.bounds ?? CGRect()).width
        let height = (transitionContainerView?.bounds ?? CGRect()).height
        
        // Return an appropriate percentage based on which edge we're dragging
        // from.
        if self.edge == .right {
            return (width - locationInSourceView.x) / width
        } else if self.edge == .left {
            return locationInSourceView.x / width
        } else if self.edge == .bottom {
            return (height - locationInSourceView.y) / height
        } else if self.edge == .top {
            return locationInSourceView.y / height
        } else {
            return 0.0
        }
    }
    
    
    //| ----------------------------------------------------------------------------
    //! Action method for the gestureRecognizer.
    //
    @IBAction func gestureRecognizeDidUpdate(_ gestureRecognizer: UIScreenEdgePanGestureRecognizer) {
        switch gestureRecognizer.state {
        case .began:
            // The Began state is handled by the view controllers.  In response
            // to the gesture recognizer transitioning to this state, they
            // will trigger the presentation or dismissal.
            break
        case .changed:
            // We have been dragging! Update the transition context accordingly.
            self.update(self.percentForGesture(gestureRecognizer))
            break
        case .ended:
            // Dragging has finished.
            // Complete or cancel, depending on how far we've dragged.
            if self.percentForGesture(gestureRecognizer) >= 0.5 {
                self.finish()
            } else {
                self.cancel()
            }
        default:
            // Something happened. cancel the transition.
            self.cancel()
        }
    }
    
}
