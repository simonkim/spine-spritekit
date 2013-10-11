//
//  SpineGeometry.h
//  PZTool
//
//  Created by Simon Kim on 13. 10. 9..
//  Copyright (c) 2013 DZPub.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef struct  {
    CGPoint origin;
    CGPoint scale;
    CGFloat rotation;
} SpineGeometry;

SpineGeometry SpineGeometryMake( float x, float y, float scaleX, float scaleY, float rotation);
NSString *NSStringFromSpineGeometry(SpineGeometry geometry);