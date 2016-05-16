//
//  WindDirection.swift
//  WeatherAlert
//
//  Created by Aleksandr Kelbas on 16/05/2016.
//  Copyright © 2016 Motionly Ltd. All rights reserved.
//

import Foundation
import UIKit
import CoreGraphics

class WindDirection {
    class func imageOfSize(size: CGSize, direction: Double, color: UIColor = UIColor.whiteColor()) -> UIImage {
        let rect = CGRect(origin: .zero, size: size)
        UIGraphicsBeginImageContextWithOptions(size, false, 2.0)
        let ctx = UIGraphicsGetCurrentContext()
        
        CGContextAddEllipseInRect(ctx, rect)
        
        // text params
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .Center
        let attrs = [
            NSFontAttributeName: UIFont(name: "HelveticaNeue", size: 6)!,
            NSParagraphStyleAttributeName: paragraphStyle,
            NSForegroundColorAttributeName : color]
        
        let dashSize: CGFloat = 4.0
        
        // north
        CGContextMoveToPoint(ctx, CGRectGetMidX(rect), CGRectGetMinY(rect))
        CGContextAddLineToPoint(ctx, CGRectGetMidX(rect), CGRectGetMinY(rect) + dashSize)
        var string = "N"
        string.drawWithRect(CGRect(x: 0, y: dashSize + 2, width: size.width, height: size.height), options: .UsesLineFragmentOrigin, attributes: attrs, context: nil)
        
        // south
        CGContextMoveToPoint(ctx, CGRectGetMidX(rect), CGRectGetMaxY(rect))
        CGContextAddLineToPoint(ctx, CGRectGetMidX(rect), CGRectGetMaxY(rect) - dashSize)
        string = "S"
        string.drawWithRect(CGRect(x: 0, y: CGRectGetMaxY(rect) - dashSize - 14, width: 100, height: 100), options: .UsesLineFragmentOrigin, attributes: attrs, context: nil)
        
        // west
        CGContextMoveToPoint(ctx, CGRectGetMinX(rect), CGRectGetMidY(rect))
        CGContextAddLineToPoint(ctx, CGRectGetMinX(rect) + dashSize, CGRectGetMidY(rect))
        string = "W"
        string.drawWithRect(CGRect(x: -CGRectGetMidX(rect) + dashSize + 10, y: CGRectGetMidY(rect) - 6, width: 100, height: 100), options: .UsesLineFragmentOrigin, attributes: attrs, context: nil)
        
        // east
        CGContextMoveToPoint(ctx, CGRectGetMaxX(rect), CGRectGetMidY(rect))
        CGContextAddLineToPoint(ctx, CGRectGetMaxX(rect) - dashSize, CGRectGetMidY(rect))
        string = "E"
        string.drawWithRect(CGRect(x: CGRectGetMidX(rect) - dashSize - 8, y: CGRectGetMidY(rect) - 6, width: 100, height: 100), options: .UsesLineFragmentOrigin, attributes: attrs, context: nil)
        
        
        
        
        CGContextSetStrokeColorWithColor(ctx, color.CGColor)
        CGContextStrokePath(ctx)
        
        
        // Draw direction
        let rad = CGFloat((direction - 90.0) *  M_PI / 180)
        CGContextTranslateCTM(ctx, CGRectGetMidX(rect), CGRectGetMidY(rect))
        CGContextRotateCTM(ctx, rad)
        
        CGContextSetStrokeColorWithColor(ctx, UIColor.redColor().CGColor)
        CGContextMoveToPoint(ctx, rad, 0.0)
        CGContextAddLineToPoint(ctx, CGRectGetMidX(rect), CGRectGetMinY(rect))
        CGContextStrokePath(ctx)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        return image
    }
}