//
//  SplitViewAnimation.swift
//  SmartNote
//
//  Created by Martin on 11.11.15.
//  Copyright © 2015 Martin. All rights reserved.
//

import Foundation


//Custom splitview animation
class SplitViewAnimation: NSAnimation, NSAnimationDelegate {
    let splitView:NSSplitView
    let dividerIndex:Int
    let startPosition:CGFloat
    let endPosition:CGFloat
    let completionBlock: (() -> Void)?
    
    init(splitView:NSSplitView,dividerIndex:Int,
        startPosition:CGFloat,
        endPosition:CGFloat,
        completionBlock:(() -> Void)? ) {
            self.splitView = splitView
            self.dividerIndex = dividerIndex
            self.startPosition = startPosition
            self.endPosition = endPosition
            self.completionBlock = completionBlock
            super.init(duration: 0.4, animationCurve: NSAnimationCurve.EaseIn)
            self.duration = 0.4
            self.animationBlockingMode = .Nonblocking
            self.animationCurve = .EaseIn
            self.frameRate = 30.0
            self.delegate = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override internal var currentProgress: NSAnimationProgress {
        set (progress) {
            super.currentProgress = progress
            
            let newPosition:CGFloat = self.startPosition + ((self.endPosition - self.startPosition) * CGFloat(progress))
            
            self.splitView.setPosition(newPosition, ofDividerAtIndex: self.dividerIndex)
            if progress==1.0{
                if (self.completionBlock != nil) {
                    self.completionBlock!()
                }
            }
        }
        get {
            return super.currentProgress
        }
    }
    
}