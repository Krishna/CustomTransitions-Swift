//
//  AAPLAdaptivePresentationSecondViewController.swift
//  CustomTransitions
//
//  Created by 開発 on 2016/2/13.
//
//
/*
 Copyright (C) 2016 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information

 Abstract:
 The second view controller for the Adaptive Presentation demo.
 */

import UIKit

@objc(AAPLAdaptivePresentationSecondViewController)
class AAPLAdaptivePresentationSecondViewController: UIViewController, UIAdaptivePresentationControllerDelegate {


//| ----------------------------------------------------------------------------
    override func viewDidLoad() {
        super.viewDidLoad()

    // In the regular environment, AAPLAdaptivePresentationController displays
    // a close button for the presented view controller.  For the compact
    // environment, a 'dismiss' button is added to this view controller's
    // navigationItem.  This button will be picked up and displayed in the
    // navigation bar of the navigation controller returned by
    // -presentationController:viewControllerForAdaptivePresentationStyle:
        let dismissButton = UIBarButtonItem(title: "Dismiss", style: .plain, target: self, action: #selector(AAPLAdaptivePresentationSecondViewController.dismissButtonAction(_:)))
        self.navigationItem.leftBarButtonItem = dismissButton
    }


//| ----------------------------------------------------------------------------
    override var transitioningDelegate: UIViewControllerTransitioningDelegate? {
        get {return super.transitioningDelegate}
        set {
            super.transitioningDelegate = newValue

    // For an adaptive presentation, the presentation controller's delegate
    // must be configured prior to invoking
    // -presentViewController:animated:completion:.  This ensures the
    // presentation is able to properly adapt if the initial presentation
    // environment is compact.
            if #available(iOS 8.0, *) {
                self.presentationController?.delegate = self
            }
        }
    }


//| ----------------------------------------------------------------------------
    @IBAction func dismissButtonAction(_ sender: UIBarButtonItem) {
        self.performSegue(withIdentifier: "unwindToFirstViewController", sender: sender)
    }
//
//MARK: -
//MARK: UIAdaptivePresentationControllerDelegate

//| ----------------------------------------------------------------------------
    @available(iOS 8.0, *)
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
    // An adaptive presentation may only fallback to
    // UIModalPresentationFullScreen or UIModalPresentationOverFullScreen
    // in the horizontally compact environment.  Other presentation styles
    // are interpreted as UIModalPresentationNone - no adaptation occurs.
        return .fullScreen
    }


//| ----------------------------------------------------------------------------
    @available(iOS 8.0, *)
    func presentationController(_ controller: UIPresentationController, viewControllerForAdaptivePresentationStyle style: UIModalPresentationStyle) -> UIViewController? {
        return UINavigationController(rootViewController: controller.presentedViewController)
    }

}
