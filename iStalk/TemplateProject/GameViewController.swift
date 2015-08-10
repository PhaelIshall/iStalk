//
//  gameViewController.swift
//  TemplateProject
//
//  Created by ALAA AL MUTAWA on 7/15/15.
//  Copyright (c) 2015 Make School. All rights reserved.
//

import UIKit

class GameViewController: UIViewController {
    
    
    @IBOutlet weak var mainImageView: UIImageView!
    

    var lastPoint = CGPoint.zeroPoint
    var brushWidth: CGFloat = 10.0
    var opacity: CGFloat = 1.0
    var swiped = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        swiped = false
        if let touch = touches.first as? UITouch {
            lastPoint = touch.locationInView(self.view)
        }
    }
    
    func drawLineFrom(fromPoint: CGPoint, toPoint: CGPoint) {
        
        // 1
        UIGraphicsBeginImageContext(view.frame.size)
        let context = UIGraphicsGetCurrentContext()
        mainImageView.image?.drawInRect(CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height))
        
        // 2
        CGContextMoveToPoint(context, fromPoint.x, fromPoint.y)
        CGContextAddLineToPoint(context, toPoint.x, toPoint.y)
        
        // 3
        CGContextSetLineCap(context, kCGLineCapRound)
        CGContextSetLineWidth(context, brushWidth)
     
        CGContextSetBlendMode(context, kCGBlendModeNormal)
        
        // 4
        CGContextStrokePath(context)
        
        // 5
        mainImageView.image = UIGraphicsGetImageFromCurrentImageContext()
        mainImageView.alpha = opacity
        UIGraphicsEndImageContext()
        
    }
    
    override func touchesMoved(touches: Set<NSObject>, withEvent event: UIEvent) {
        // 6
        swiped = true
        if let touch = touches.first as? UITouch {
            let currentPoint = touch.locationInView(view)
            drawLineFrom(lastPoint, toPoint: currentPoint)
            
            // 7
            lastPoint = currentPoint
        }
    }
    
    override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent) {
        
        if !swiped {
            // draw a single point
            drawLineFrom(lastPoint, toPoint: lastPoint)
        }
    }   
}
