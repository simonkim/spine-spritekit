//
//  SpineGeometry.m
//  PZTool
//
//  Created by Simon Kim on 13. 10. 9..
//  Copyright (c) 2013 DZPub.com. All rights reserved.
//

#import "SpineGeometry.h"


SpineGeometry SpineGeometryMake( float x, float y, float scaleX, float scaleY, float rotation)
{
    SpineGeometry geometry;
    geometry.origin = CGPointMake(x, y);
    geometry.scale = CGPointMake(scaleX, scaleY);
    geometry.rotation = rotation;
    return geometry;
}

NSString *NSStringFromSpineGeometry(SpineGeometry geometry)
{
    return [NSString stringWithFormat:@"SpineGeometry {origin:%@, scale:%@, rotation:%2.2f}",
            NSStringFromCGPoint(geometry.origin),
            NSStringFromCGPoint(geometry.scale),
            geometry.rotation];
}