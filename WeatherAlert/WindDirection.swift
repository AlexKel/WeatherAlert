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
    class func imageOfSize(bounds: CGSize, direction: Double, color: UIColor = UIColor.whiteColor()) -> UIImage {
        
        let size = CGSizeMake(bounds.width-2.0, bounds.height-2.0)
        
        let rect = CGRect(origin: .zero, size: size)
        UIGraphicsBeginImageContextWithOptions(bounds, false, 2.0)
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
        string.drawWithRect(CGRect(x: 0, y: CGRectGetMaxY(rect) - dashSize - 10, width: size.width, height:size.height), options: .UsesLineFragmentOrigin, attributes: attrs, context: nil)
        
        // west
        CGContextMoveToPoint(ctx, CGRectGetMinX(rect), CGRectGetMidY(rect))
        CGContextAddLineToPoint(ctx, CGRectGetMinX(rect) + dashSize, CGRectGetMidY(rect))
        string = "W"
        string.drawWithRect(CGRect(x: -CGRectGetMidX(rect) + dashSize + 6, y: CGRectGetMidY(rect) - 4, width: size.width, height: size.height), options: .UsesLineFragmentOrigin, attributes: attrs, context: nil)
        
        // east
        CGContextMoveToPoint(ctx, CGRectGetMaxX(rect), CGRectGetMidY(rect))
        CGContextAddLineToPoint(ctx, CGRectGetMaxX(rect) - dashSize, CGRectGetMidY(rect))
        string = "E"
        string.drawWithRect(CGRect(x: CGRectGetMidX(rect) - dashSize - 6, y: CGRectGetMidY(rect) - 4, width: size.width, height: size.height), options: .UsesLineFragmentOrigin, attributes: attrs, context: nil)
        
        CGContextSetStrokeColorWithColor(ctx, color.CGColor)
        CGContextStrokePath(ctx)
        
        
        // Draw direction
        let degrees = CGFloat((direction - 90.0) *  M_PI / 180)
        let radius: CGFloat = size.width/2.0
        CGContextTranslateCTM(ctx, CGRectGetMidX(rect), CGRectGetMidY(rect))
        CGContextRotateCTM(ctx, degrees)
        let path = CGPathCreateMutable()
        CGPathMoveToPoint(path, nil, size.width/2.0, 0)
        CGPathAddLineToPoint(path, nil, radius-5, -3)
        CGPathAddLineToPoint(path, nil, radius-5, 3)
        CGPathCloseSubpath(path)
        
        CGContextAddPath(ctx, path)
        CGContextSetStrokeColorWithColor(ctx, UIColor.redColor().CGColor)
        CGContextSetFillColorWithColor(ctx, UIColor.redColor().CGColor)
        CGContextFillPath(ctx)
        CGContextStrokePath(ctx)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        return image
    }
}