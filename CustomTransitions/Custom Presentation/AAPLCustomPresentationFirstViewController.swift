//
//  AAPLCustomPresentationFirstViewController.swift
//  CustomTransitions
//
//  Created by 開発 on 2016/2/13.
//
//
/*
 Copyright (C) 2016 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information

 Abstract:
 The initial view controller for the Custom Presentation demo.
 */

import UIKit

@available(iOS 8.0, *)
@objc(AAPLCustomPresentationFirstViewController)
class AAPLCustomPresentationFirstViewController: UIViewController {
    
    //MARK: -
    //MARK: Presentation
    
    //| ----------------------------------------------------------------------------
    @IBAction func buttonAction(_ sender: UIButton) {
        let secondViewController = self.storyboard?.instantiateViewController(withIdentifier: "SecondViewController")
        
        // For presentations which will use a custom presentation controller,
        // it is possible for that presentation controller to also be the
        // transitioningDelegate.  This avoids introducing another object
        // or implementing <UIViewControllerTransitioningDelegate> in the
        // source view controller.
        //
        // transitioningDelegate does not hold a strong reference to its
        // destination object.  To prevent presentationController from being
        // released prior to calling -presentViewController:animated:completion:
        // the NS_VALID_UNTIL_END_OF_SCOPE attribute is appended to the declaration.
        
        let presentationController = AAPLCustomPresentationController(presentedViewController: secondViewController!, presenting: self)
        
        secondViewController!.transitioningDelegate = presentationController
        
        self.present(secondViewController!, animated: true, completion: {
            let _ = presentationController
        })
    }
    
}
