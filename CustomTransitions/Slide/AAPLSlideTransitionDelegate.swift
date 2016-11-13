//
//  AAPLSlideTransitionDelegate.swift
//  CustomTransitions
//
//  Created by 開発 on 2016/2/2.
//
//
/*
 Copyright (C) 2016 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information

 Abstract:
 The delegate of the tab bar controller for the Slide demo.  Manages the
  gesture recognizer used for the interactive transition.  Vends
  instances of AAPLSlideTransitionAnimator and
  AAPLSlideTransitionInteractionController.
 */

import UIKit
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


@objc(AAPLSlideTransitionDelegate)
class AAPLSlideTransitionDelegate: NSObject, UITabBarControllerDelegate {
    
    //! The UITabBarController instance for which this object is the delegate of.
    fileprivate weak var _tabBarController: UITabBarController!
    
    //! The gesture recognizer used for driving the interactive transition
    //! between view controllers.  AAPLSlideTransitionDelegate installs this
    //! gesture recognizer on the tab bar controller's view.
    
    //! They key used to associate an instance of AAPLSlideTransitionDelegate with
    //! the tab bar controller for which it is the delegate.
    fileprivate let AAPLSlideTabBarControllerDelegateAssociationKey = "AAPLSlideTabBarControllerDelegateAssociation"
    
    
    @IBOutlet var tabBarController: UITabBarController! {
        get {return _tabBarController}
        //| ----------------------------------------------------------------------------
        //  Custom implementation of the setter for the tabBarController property.
        //
        //  An instance of the AAPLSlideTransitionDelegate class is defined in the
        //  Tab Bar Controller's scene in the storyboard, and its tabBarControllerOutlet
        //  connected to the tab bar controller.  At unarchive time this method will
        //  be called, providing an opportunity to perform the necessary setup.
        //
        set {
            if newValue !== _tabBarController {
                // Remove all associations of this object from the old tab bar
                // controller.
                objc_setAssociatedObject(_tabBarController, AAPLSlideTabBarControllerDelegateAssociationKey, nil, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                _tabBarController?.view.removeGestureRecognizer(self.panGestureRecognizer)
                if _tabBarController?.delegate === self {_tabBarController.delegate = nil}
                
                _tabBarController = newValue
                
                _tabBarController.delegate = self
                _tabBarController.view.addGestureRecognizer(self.panGestureRecognizer)
                // Associate this object with the new tab bar controller.  This ensures
                // that this object wil not be deallocated prior to the tab bar
                // controller being deallocated.
                objc_setAssociatedObject(_tabBarController, AAPLSlideTabBarControllerDelegateAssociationKey, self, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
        }
    }
    
    //MARK: -
    //MARK: Gesture Recognizer
    
    //| ----------------------------------------------------------------------------
    //  Custom implementation of the getter for the panGestureRecognizer property.
    //  Lazily creates the pan gesture recognizer for the tab bar controller.
    //
    fileprivate var _panGestureRecognizer: UIPanGestureRecognizer?
    var panGestureRecognizer: UIPanGestureRecognizer {
        get {
            if _panGestureRecognizer == nil {
                _panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(AAPLSlideTransitionDelegate.panGestureRecognizerDidPan(_:)))
            }
            
            return _panGestureRecognizer!
        }
        set {_panGestureRecognizer = newValue}
    }
    
    
    //| ----------------------------------------------------------------------------
    //! Action method for the panGestureRecognizer.
    //
    @IBAction func panGestureRecognizerDidPan(_ sender: UIPanGestureRecognizer) {
        // Do not attempt to begin an interactive transition if one is already
        // ongoing
        if self.tabBarController.transitionCoordinator != nil {
            return
        }
        
        if sender.state == .began || sender.state == .changed {
            self.beginInteractiveTransitionIfPossible(sender)
        }
        
        // Remaining cases are handled by the vended
        // AAPLSlideTransitionInteractionController.
    }
    
    
    //| ----------------------------------------------------------------------------
    //! Begins an interactive transition with the provided gesture recognizer, if
    //! there is a view controller to transition to.
    //
    fileprivate func beginInteractiveTransitionIfPossible(_ sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: self.tabBarController.view)
        
        if translation.x > 0.0 && self.tabBarController.selectedIndex > 0 {
            //        // Panning right, transition to the left view controller.
            self.tabBarController.selectedIndex -= 1
        } else if translation.x < 0.0 && self.tabBarController.selectedIndex + 1 < self.tabBarController.viewControllers?.count ?? 0 {
            // Panning left, transition to the right view controller.
            self.tabBarController.selectedIndex += 1
        } else {
            // Don't reset the gesture recognizer if we skipped starting the
            // transition because we don't have a translation yet (and thus, could
            // not determine the transition direction).
            if !translation.equalTo(CGPoint.zero) {
                // There is not a view controller to transition to, force the
                // gesture recognizer to fail.
                sender.isEnabled = false
                sender.isEnabled = true
            }
        }
        
        // We must handle the case in which the user begins panning but then
        // reverses direction without lifting their finger.  The transition
        // should seamlessly switch to revealing the correct view controller
        // for the new direction.
        //
        // The approach presented in this demonstration relies on coordination
        // between this object and the AAPLSlideTransitionInteractionController
        // it vends.  If the AAPLSlideTransitionInteractionController detects
        // that the current position of the user's touch along the horizontal
        // axis has crossed over the initial position, it cancels the
        // transition.  A completion block is attached to the tab bar
        // controller's transition coordinator.  This block will be called when
        // the transition completes or is cancelled.  If the transition was
        // cancelled but the gesture recgonzier has not transitioned to the
        // ended or failed state, a new transition to the proper view controller
        // is started, and new animation + interaction controllers are created.
        //
        self.tabBarController.transitionCoordinator?.animate(alongsideTransition: nil) {context in
            if context.isCancelled && sender.state == .changed {
                self.beginInteractiveTransitionIfPossible(sender)
            }
        }
    }
    
    //MARK: -
    //MARK: UITabBarControllerDelegate
    
    //| ----------------------------------------------------------------------------
    //  The tab bar controller tries to invoke this method on its delegate to
    //  retrieve an animator object to be used for animating the transition to the
    //  incoming view controller.  Your implementation is expected to return an
    //  object that conforms to the UIViewControllerAnimatedTransitioning protocol,
    //  or nil if the transition should not be animated.
    //
    func tabBarController(_ tabBarController: UITabBarController, animationControllerForTransitionFrom fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning?
    {
        assert(tabBarController == self.tabBarController, "\(tabBarController) is not the tab bar controller currently associated with \(self)")
        let viewControllers = tabBarController.viewControllers ?? []
        
        if viewControllers.index(of: toVC) > viewControllers.index(of: fromVC) {
            // The incoming view controller succeeds the outgoing view controller,
            // slide towards the left.
            return AAPLSlideTransitionAnimator(targetEdge: .left)
        } else {
            // The incoming view controller precedes the outgoing view controller,
            // slide towards the right.
            return AAPLSlideTransitionAnimator(targetEdge: .right)
        }
    }
    
    
    //| ----------------------------------------------------------------------------
    //  If an id<UIViewControllerAnimatedTransitioning> was returned from
    //  -tabBarController:animationControllerForTransitionFromViewController:toViewController:,
    //  the tab bar controller tries to invoke this method on its delegate to
    //  retrieve an interaction controller for the transition.  Your implementation
    //  is expected to return an object that conforms to the
    //  UIViewControllerInteractiveTransitioning protocol, or nil if the transition
    //  should not be a interactive.
    //
    func tabBarController(_ tabBarController: UITabBarController, interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning?
    {
        assert(tabBarController == self.tabBarController, "\(tabBarController) is not the tab bar controller currently associated with \(self)")
        
        if self.panGestureRecognizer.state == .began || self.panGestureRecognizer.state == .changed {
            return AAPLSlideTransitionInteractionController(gestureRecognizer: self.panGestureRecognizer)
        } else {
            // You must not return an interaction controller from this method unless
            // the transition will be interactive.
            return nil
        }
    }
    
}
