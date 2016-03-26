//
//  AAPLSlideTransitionInteractionController.swift
//  CustomTransitions
//
//  Created by 開発 on 2016/2/2.
//
//
/*
 Copyright (C) 2016 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information

 Abstract:
 The interaction controller for the Slide demo.
 */

import UIKit

@objc(AAPLSlideTransitionInteractionController)
class AAPLSlideTransitionInteractionController: UIPercentDrivenInteractiveTransition {
    
    private weak var transitionContext: UIViewControllerContextTransitioning?
    private var gestureRecognizer: UIPanGestureRecognizer
    private var initialLocationInContainerView: CGPoint = CGPoint()
    private var initialTranslationInContainerView: CGPoint = CGPoint()
    
    
    //| ----------------------------------------------------------------------------
    init(gestureRecognizer: UIPanGestureRecognizer) {
        self.gestureRecognizer = gestureRecognizer
        super.init()
        
        // Add self as an observer of the gesture recognizer so that this
        // object receives updates as the user moves their finger.
        gestureRecognizer.addTarget(self, action: #selector(AAPLSlideTransitionInteractionController.gestureRecognizeDidUpdate(_:)))
    }
    
    
    //| ----------------------------------------------------------------------------
    //- (instancetype)init
    //{
    //    @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"Use -initWithGestureRecognizer:" userInfo:nil];
    //}
    
    
    //| ----------------------------------------------------------------------------
    deinit {
        self.gestureRecognizer.removeTarget(self, action: #selector(AAPLSlideTransitionInteractionController.gestureRecognizeDidUpdate(_:)))
    }
    
    
    //| ----------------------------------------------------------------------------
    override func startInteractiveTransition(transitionContext: UIViewControllerContextTransitioning) {
        // Save the transitionContext, initial location, and the translation within
        // the containing view.
        self.transitionContext = transitionContext
        self.initialLocationInContainerView = self.gestureRecognizer.locationInView(transitionContext.containerView())
        self.initialTranslationInContainerView = self.gestureRecognizer.translationInView(transitionContext.containerView())
        
        super.startInteractiveTransition(transitionContext)
    }
    
    
    //| ----------------------------------------------------------------------------
    //! Returns the offset of the pan gesture recognizer from its initial location
    //! as a percentage of the transition container view's width.  This is
    //! the percent completed for the interactive transition.
    //
    private func percentForGesture(gesture: UIPanGestureRecognizer) -> CGFloat {
        let transitionContainerView = self.transitionContext?.containerView()
        
        let translationInContainerView = gesture.translationInView(transitionContainerView)
        
        // If the direction of the current touch along the horizontal axis does not
        // match the initial direction, then the current touch position along
        // the horizontal axis has crossed over the initial position.  See the
        // comment in the -beginInteractiveTransitionIfPossible: method of
        // AAPLSlideTransitionDelegate.
        if translationInContainerView.x > 0.0 && self.initialTranslationInContainerView.x < 0.0 ||
            translationInContainerView.x < 0.0 && self.initialTranslationInContainerView.x > 0.0 {
                return -1.0
        }
        
        // Figure out what percentage we've traveled.
        return abs(translationInContainerView.x) / CGRectGetWidth(transitionContainerView?.bounds ?? CGRect())
    }
    
    
    //| ----------------------------------------------------------------------------
    //! Action method for the gestureRecognizer.
    //
    @IBAction func gestureRecognizeDidUpdate(gestureRecognizer: UIScreenEdgePanGestureRecognizer) {
        switch gestureRecognizer.state {
        case .Began:
            // The Began state is handled by AAPLSlideTransitionDelegate.  In
            // response to the gesture recognizer transitioning to this state,
            // it will trigger the transition.
            break
        case .Changed:
            // -percentForGesture returns -1.f if the current position of the
            // touch along the horizontal axis has crossed over the initial
            // position.  See the comment in the
            // -beginInteractiveTransitionIfPossible: method of
            // AAPLSlideTransitionDelegate for details.
            if self.percentForGesture(gestureRecognizer) < 0.0 {
                self.cancelInteractiveTransition()
                // Need to remove our action from the gesture recognizer to
                // ensure it will not be called again before deallocation.
                self.gestureRecognizer.removeTarget(self, action: #selector(AAPLSlideTransitionInteractionController.gestureRecognizeDidUpdate(_:)))
            } else {
                // We have been dragging! Update the transition context
                // accordingly.
                self.updateInteractiveTransition(self.percentForGesture(gestureRecognizer))
            }
        case .Ended:
            // Dragging has finished.
            // Complete or cancel, depending on how far we've dragged.
            if self.percentForGesture(gestureRecognizer) >= 0.4 {
                self.finishInteractiveTransition()
            } else {
                self.cancelInteractiveTransition()
            }
        default:
            // Something happened. cancel the transition.
            self.cancelInteractiveTransition()
        }
    }
    
}