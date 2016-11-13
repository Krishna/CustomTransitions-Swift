//
//  AAPLAdaptivePresentationController.swift
//  CustomTransitions
//
//  Created by 開発 on 2016/2/7.
//
//
/*
 Copyright (C) 2016 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information

 */

import UIKit

@available(iOS 8.0, *)
@objc(AAPLAdaptivePresentationController)
class AAPLAdaptivePresentationController: UIPresentationController, UIViewControllerTransitioningDelegate, UIViewControllerAnimatedTransitioning {
    
    fileprivate var presentationWrappingView: UIView?
    fileprivate var dismissButton: UIButton?
    
    
    //| ----------------------------------------------------------------------------
    override init(presentedViewController: UIViewController, presenting presentingViewController: UIViewController?) {
        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
        
        // The presented view controller must have a modalPresentationStyle
        // of UIModalPresentationCustom for a custom presentation controller
        // to be used.
        presentedViewController.modalPresentationStyle = .custom
        
    }
    
    
    //| ----------------------------------------------------------------------------
    override var presentedView : UIView? {
        // Return the wrapping view created in -presentationTransitionWillBegin.
        return self.presentationWrappingView
    }
    
    
    //| ----------------------------------------------------------------------------
    //  This is one of the first methods invoked on the presentation controller
    //  at the start of a presentation.  By the time this method is called,
    //  the containerView has been created and the view hierarchy set up for the
    //  presentation.  However, the -presentedView has not yet been retrieved.
    //
    override func presentationTransitionWillBegin() {
        // The default implementation of -presentedView returns
        // self.presentedViewController.view.
        let presentedViewControllerView = super.presentedView!
        
        // Wrap the presented view controller's view in an intermediate hierarchy
        // that applies a shadow and adds a dismiss button to the top left corner.
        //
        // presentationWrapperView              <- shadow
        //     |- presentedViewControllerView (presentedViewController.view)
        //     |- close button
        do {
            let presentationWrapperView = UIView(frame: CGRect.zero)
            presentationWrapperView.layer.shadowOpacity = 0.63
            presentationWrapperView.layer.shadowRadius = 17.0
            self.presentationWrappingView = presentationWrapperView
            
            // Add presentedViewControllerView -> presentationWrapperView.
            presentedViewControllerView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            //presentedViewControllerView.layer.borderColor = UIColor.grayColor().CGColor
            //presentedViewControllerView.layer.borderWidth = 2.0
            presentationWrapperView.addSubview(presentedViewControllerView)
            
            // Create the dismiss button.
            let dismissButton = UIButton(type: .custom)
            dismissButton.frame = CGRect(x: 0, y: 0, width: 26.0, height: 26.0)
            dismissButton.setImage(UIImage(named: "CloseButton"), for: UIControlState())
            dismissButton.addTarget(self, action: #selector(AAPLAdaptivePresentationController.dismissButtonTapped(_:)), for: .touchUpInside)
            self.dismissButton = dismissButton
            
            // Add dismissButton -> presentationWrapperView.
            presentationWrapperView.addSubview(dismissButton)
        }
    }
    
    //MARK: -
    //MARK: Dismiss Button
    
    //| ----------------------------------------------------------------------------
    //  IBAction for the dismiss button.  Dismisses the presented view controller.
    //
    @IBAction func dismissButtonTapped(_ sender: UIButton) {
        self.presentingViewController.dismiss(animated: true, completion: nil)
    }
    
    //MARK: -
    //MARK: Layout
    
    //| ----------------------------------------------------------------------------
    //  This method is invoked when the interface rotates.  For performance,
    //  the shadow on presentationWrapperView is disabled for the duration
    //  of the rotation animation.
    //
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        self.presentationWrappingView?.clipsToBounds = true
        self.presentationWrappingView?.layer.shadowOpacity = 0.0
        self.presentationWrappingView?.layer.shadowRadius = 0.0
        
        coordinator.animate( alongsideTransition: {context in
            // Intentionally left blank.
            }, completion: {context in
                self.presentationWrappingView?.clipsToBounds = false
                self.presentationWrappingView?.layer.shadowOpacity = 0.63
                self.presentationWrappingView?.layer.shadowRadius = 17.0
        })
    }
    
    
    //| ----------------------------------------------------------------------------
    //  When the presentation controller receives a
    //  -viewWillTransitionToSize:withTransitionCoordinator: message it calls this
    //  method to retrieve the new size for the presentedViewController's view.
    //  The presentation controller then sends a
    //  -viewWillTransitionToSize:withTransitionCoordinator: message to the
    //  presentedViewController with this size as the first argument.
    //
    //  Note that it is up to the presentation controller to adjust the frame
    //  of the presented view controller's view to match this promised size.
    //  We do this in -containerViewWillLayoutSubviews.
    //
    override func size(forChildContentContainer container: UIContentContainer, withParentContainerSize parentSize: CGSize) -> CGSize {
        if container === self.presentedViewController {
            return CGSize(width: parentSize.width/2, height: parentSize.height/2)
        } else {
            return super.size(forChildContentContainer: container, withParentContainerSize: parentSize)
        }
    }
    
    
    //| ----------------------------------------------------------------------------
    override var frameOfPresentedViewInContainerView : CGRect {
        let containerViewBounds = self.containerView?.bounds ?? CGRect()
        let presentedViewContentSize = self.size(forChildContentContainer: self.presentedViewController, withParentContainerSize: containerViewBounds.size)
        
        // Center the presentationWrappingView view within the container.
        let frame = CGRect(x: containerViewBounds.midX - presentedViewContentSize.width/2,
            y: containerViewBounds.midY - presentedViewContentSize.height/2,
            width: presentedViewContentSize.width, height: presentedViewContentSize.height)
        
        // Outset the centered frame of presentationWrappingView so that the
        // dismiss button is within the bounds of presentationWrappingView.
        return frame.insetBy(dx: -20, dy: -20)
    }
    
    
    //| ----------------------------------------------------------------------------
    //  This method is similar to the -viewWillLayoutSubviews method in
    //  UIViewController.  It allows the presentation controller to alter the
    //  layout of any custom views it manages.
    //
    override func containerViewWillLayoutSubviews() {
        super.containerViewWillLayoutSubviews()
        
        self.presentationWrappingView?.frame = self.frameOfPresentedViewInContainerView
        
        // Undo the outset that was applied in -frameOfPresentedViewInContainerView.
        self.presentedViewController.view.frame = (self.presentationWrappingView?.bounds ?? CGRect()).insetBy(dx: 20, dy: 20)
        
        // Position the dismissButton above the top-left corner of the presented
        // view controller's view.
        self.dismissButton?.center = CGPoint(x: self.presentedViewController.view.frame.minX,
            y: self.presentedViewController.view.frame.minY)
    }
    
    //MARK: -
    //MARK: UIViewControllerAnimatedTransitioning
    
    //| ----------------------------------------------------------------------------
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return transitionContext?.isAnimated ?? false ? 0.35 : 0
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
        let toView = transitionContext.view(forKey: UITransitionContextViewKey.to)!
        let fromView = transitionContext.view(forKey: UITransitionContextViewKey.from)!
        
        let isPresenting = (fromViewController === self.presentingViewController)
        
        // We are responsible for adding the incoming view to the containerView
        // for the presentation (will have no effect on dismissal because the
        // presenting view controller's view was not removed).
        containerView.addSubview(toView)
        
        if isPresenting {
            
            // This animation only affects the alpha.  The views can be set to
            // their final frames now.
            fromView.frame = transitionContext.finalFrame(for: fromViewController)
            toView.frame = transitionContext.finalFrame(for: toViewController)
        } else {
            // Because our presentation wraps the presented view controller's view
            // in an intermediate view hierarchy, it is more accurate to rely
            // on the current frame of fromView than fromViewInitialFrame as the
            // initial frame.
            toView.frame = transitionContext.finalFrame(for: toViewController)
        }
        
        let transitionDuration = self.transitionDuration(using: transitionContext)
        
        UIView.animate(withDuration: transitionDuration, animations: {
            if isPresenting {
                toView.alpha = 1.0
            } else {
                fromView.alpha = 0.0
            }
            
            }, completion: { finished in
                // When we complete, tell the transition context
                // passing along the BOOL that indicates whether the transition
                // finished or not.
                let wasCancelled = transitionContext.transitionWasCancelled
                transitionContext.completeTransition(!wasCancelled)
                
                // Reset the alpha of the dismissed view, in case it will be used
                // elsewhere in the app.
                if !isPresenting {
                    fromView.alpha = 1.0
                }
        })
    }
    
    //MARK: -
    //MARK: UIViewControllerTransitioningDelegate
    
    //| ----------------------------------------------------------------------------
    //  If the modalPresentationStyle of the presented view controller is
    //  UIModalPresentationCustom, the system calls this method on the presented
    //  view controller's transitioningDelegate to retrieve the presentation
    //  controller that will manage the presentation.  If your implementation
    //  returns nil, an instance of UIPresentationController is used.
    //
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        assert(self.presentedViewController == presented, "You didn't initialize \(self) with the correct presentedViewController.  Expected \(presented), got \(self.presentedViewController).")
        
        return self
    }
    
    
    //| ----------------------------------------------------------------------------
    //  The system calls this method on the presented view controller's
    //  transitioningDelegate to retrieve the animator object used for animating
    //  the presentation of the incoming view controller.  Your implementation is
    //  expected to return an object that conforms to the
    //  UIViewControllerAnimatedTransitioning protocol, or nil if the default
    //  presentation animation should be used.
    //
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self
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
        return self
    }
    
}
