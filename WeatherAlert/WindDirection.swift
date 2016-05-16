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
            NSFontAttributeName: UIFont(name: "HelveticaNeue-Thin", size: 10)!,
            NSParagraphStyleAttributeName: paragraphStyle,
            NSForegroundColorAttributeName : color]
        
        // north
        CGContextMoveToPoint(ctx, CGRectGetMidX(rect), CGRectGetMinY(rect))
        CGContextAddLineToPoint(ctx, CGRectGetMidX(rect), CGRectGetMinY(rect) + 10)
        var string = "N"
        string.drawWithRect(CGRect(x: 0, y: 12, width: size.width, height: size.height), options: .UsesLineFragmentOrigin, attributes: attrs, context: nil)
        
        // south
        CGContextMoveToPoint(ctx, CGRectGetMidX(rect), CGRectGetMaxY(rect))
        CGContextAddLineToPoint(ctx, CGRectGetMidX(rect), CGRectGetMaxY(rect) - 10)
        string = "S"
        string.drawWithRect(CGRect(x: 0, y: CGRectGetMaxY(rect) - 24, width: 100, height: 100), options: .UsesLineFragmentOrigin, attributes: attrs, context: nil)
        
        // west
        CGContextMoveToPoint(ctx, CGRectGetMinX(rect), CGRectGetMidY(rect))
        CGContextAddLineToPoint(ctx, CGRectGetMinX(rect) + 10, CGRectGetMidY(rect))
        string = "W"
        string.drawWithRect(CGRect(x: -CGRectGetMidX(rect) + 20, y: CGRectGetMidY(rect) - 6, width: 100, height: 100), options: .UsesLineFragmentOrigin, attributes: attrs, context: nil)
        
        // east
        CGContextMoveToPoint(ctx, CGRectGetMaxX(rect), CGRectGetMidY(rect))
        CGContextAddLineToPoint(ctx, CGRectGetMaxX(rect) - 10, CGRectGetMidY(rect))
        string = "E"
        string.drawWithRect(CGRect(x: CGRectGetMidX(rect) - 18, y: CGRectGetMidY(rect) - 6, width: 100, height: 100), options: .UsesLineFragmentOrigin, attributes: attrs, context: nil)
        
        
        
        
        CGContextSetStrokeColorWithColor(ctx, color.CGColor)
        CGContextStrokePath(ctx)
        
        
        // Draw direction
        let rad = CGFloat((direction - 90.0) *  M_PI / 180)
        CGContextTranslateCTM(ctx, CGRectGetMidX(rect), CGRectGetMidY(rect))
        CGContextRotateCTM(ctx, rad)
        
        CGContextSetStrokeColorWithColor(ctx, UIColor.redColor().CGColor)
        CGContextMoveToPoint(ctx, rad, 0.0)
        CGContextAddLineToPoint(ctx, CGRectGetMidX(rect), CGRectGetMinY(rect))
        CGContextSetLineWidth(ctx, 2)
        CGContextStrokePath(ctx)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        return image
    }
}