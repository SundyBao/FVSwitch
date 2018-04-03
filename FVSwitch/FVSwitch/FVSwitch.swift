//
//  FVButton.swift
//  FVSwitch
//
//  Created by james on 2017/10/16.
//  Copyright © 2017年 ACC Inc. All rights reserved.
//
import Cocoa

class FVSwitch: NSButton {

    let kDefaultTintColor = NSColor.blue
    let kBorderWidth : CGFloat = 1.0
    let kGoldenRatio : CGFloat = 1.61803398875
    let kDecreasedGoldenRatio : CGFloat = 1.38
    let knobBackgroundColor = NSColor(calibratedWhite: 1, alpha: 1)
    let kDisabledBorderColor = NSColor(calibratedWhite: 0, alpha: 0.2)
    let kDisabledBackgroundColor = NSColor.clear
    let kAnimationDuration : CFTimeInterval = 0.8
    let kEnabledOpacity: CFloat = 0.8
    let kDisabledOpacity: CFloat = 0.5
    var isOn : Bool
    var tintColor : NSColor
    
    var isActive: Bool = false
    var hasDragged: Bool = false
    var isDragginToOn: Bool = false
    var rootLayer: CALayer = CALayer()
    var backgroundLayer: CALayer = CALayer()
    var knobLayer: CALayer = CALayer()
    var knobInsideLayer: CALayer = CALayer()
    
    
    override public var frame: NSRect {
        get {
            return super.frame
        }
        set {
            super.frame = newValue
            self.refreshLayerSize()
        }
    }
   
    override var acceptsFirstResponder: Bool
        {
        return NSApp.isFullKeyboardAccessEnabled
    }
    
    
    override public var isEnabled: Bool {
        get { return super.isEnabled }
        set{
            super.isEnabled = newValue
            self.refreshLayer()
        }
    }
    
    required init?(coder: NSCoder) {
        self.isOn = false
        self.tintColor = kDefaultTintColor
        super.init(coder: coder)
        self.setUp()
    }
    
    
    // MARK: -  Setup
    func setUp() {
        self.isEnabled = true
        self.setupLayers()
    }
    
    func setupLayers() {
        layer = rootLayer
        wantsLayer = true
        
        backgroundLayer.bounds = rootLayer.bounds
        backgroundLayer.autoresizingMask = [.layerWidthSizable, .layerHeightSizable]
        backgroundLayer.anchorPoint = CGPoint(x: 0, y: 0)
        backgroundLayer.borderWidth = kBorderWidth
        
        rootLayer.addSublayer(backgroundLayer)
        
        knobLayer.frame = rectForKnob()
        knobLayer.autoresizingMask = [.layerWidthSizable, .layerHeightSizable]
        knobLayer.backgroundColor = knobBackgroundColor.cgColor
        knobLayer.shadowColor = NSColor.black.cgColor
        knobLayer.shadowOffset = CGSize(width: 0, height: -2)
        knobLayer.shadowRadius = 1
        knobLayer.shadowOpacity = 0.3
        
        rootLayer.addSublayer(knobLayer)
        
        knobInsideLayer.frame = knobLayer.bounds
        knobInsideLayer.backgroundColor = NSColor.red.cgColor
        knobInsideLayer.shadowColor = NSColor.black.cgColor
        knobInsideLayer.shadowOffset = CGSize(width: 0, height: 0)
        knobInsideLayer.shadowRadius = 1
        knobInsideLayer.shadowOpacity = 0.35
        
        knobLayer.addSublayer(knobInsideLayer)
        
        refreshLayerSize()
        refreshLayer()
    }
    
    func rectForKnob() -> CGRect {
        let height = knobHeightForSize(size: backgroundLayer.bounds.size)

//        let width = (!self.isActive) ? (NSWidth(backgroundLayer.bounds) - 2 * kBorderWidth) * 1 / kGoldenRatio : (NSWidth(backgroundLayer.bounds) - 2 * kBorderWidth) * 1 / kDecreasedGoldenRatio
        
        let x = ((!hasDragged && !isOn) || (hasDragged && !isDragginToOn)) ? kBorderWidth : NSWidth(backgroundLayer.bounds) - height - kBorderWidth
        
        return CGRect(x: x, y: kBorderWidth, width: height, height: height)
    }
    
    func knobHeightForSize(size: NSSize) -> CGFloat {
        return size.height - kBorderWidth * 2
    }
    
    func refreshLayerSize() {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        
        knobLayer.frame = rectForKnob()
        knobInsideLayer.frame = knobLayer.bounds
        
        backgroundLayer.cornerRadius = backgroundLayer.bounds.size.height / 2
        knobLayer.cornerRadius = knobLayer.bounds.size.height / 2
        knobInsideLayer.cornerRadius = knobLayer.bounds.size.height / 2
        
        CATransaction.commit()
    }
    
    func refreshLayer () {
        CATransaction.begin()
        CATransaction.setAnimationDuration(kAnimationDuration)
        
        if (hasDragged && isDragginToOn) || (!hasDragged && isOn) {
            backgroundLayer.borderColor = tintColor.cgColor
            backgroundLayer.backgroundColor = tintColor.cgColor
        } else {
            backgroundLayer.borderColor = kDisabledBorderColor.cgColor
            backgroundLayer.backgroundColor = kDisabledBackgroundColor.cgColor
        }
        
        if !isActive {
            rootLayer.opacity = kEnabledOpacity as Float
        } else {
            rootLayer.opacity = kDisabledOpacity as Float
        }
       
        rootLayer.opacity = self.isEnabled ? kEnabledOpacity : kDisabledOpacity
        if !hasDragged {

            CATransaction.setAnimationTimingFunction(CAMediaTimingFunction(controlPoints: 0.25, 1.0, 0.5, 1.0))
        }
        
        knobLayer.frame = rectForKnob()
        knobInsideLayer.frame = knobLayer.bounds
        CATransaction.commit()
        
    }
    
    // MARK: - NSView
    override func acceptsFirstMouse(for event: NSEvent?) -> Bool {
        return true
    }
    
    // MARK: - NSResponder
    override func mouseDown(with event: NSEvent) {
        if !super.isEnabled {
            isActive = true
            refreshLayer()
        }
    }
    
    override func mouseDragged(with event: NSEvent) {
        if super.isEnabled {
            hasDragged = true
            let dragginPoint: NSPoint = convert(event.locationInWindow, from: nil)
            isDragginToOn = dragginPoint.x >= NSWidth(bounds) / 2.0
            
            refreshLayer()
        }
    }
    
    override func mouseUp(with event: NSEvent) {
        if super.isEnabled {
            isActive = false
            
            let isOn: Bool = (!hasDragged) ? !self.isOn : isDragginToOn
            let invokeTargetAction: Bool = isOn != self.isOn
            
            self.isOn = isOn
            
            hasDragged = false
            isDragginToOn = false
            
            refreshLayer()
            if invokeTargetAction {
                cell?.performClick(self)
            }
        }
    }
    
}
