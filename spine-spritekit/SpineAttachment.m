//
//  SpineAttachment.m
//  PZTool
//
//  Created by Simon Kim on 13. 10. 9..
//  Copyright (c) 2013년 DZPub.com. All rights reserved.
//

#import "SpineAttachment.h"

@implementation SpineAttachment

+ (id) attachmentWithCAttachment:(spAttachment *) attachment
{
    id result = [[[self class] alloc] init];
    spRegionAttachment *rattach = (spRegionAttachment *) attachment;
    [result setGeometry:SpineGeometryMake(rattach->x, rattach->y, rattach->scaleX, rattach->scaleY, rattach->rotation)];
    [result setName:@(attachment->name)];
    [result setSize:CGSizeMake(rattach->width, rattach->height)];
    [result setRendererObject:((spAtlasRegion*)rattach->rendererObject)->page->rendererObject];
    
    /*
    CGRect rect;
    float *uvs = rattach->uvs;
    if ( uvs[VERTEX_X3] - uvs[VERTEX_X2] == 0) {
        // rotated
        rect.origin = CGPointMake(uvs[VERTEX_X3] * atlas_width, uvs[VERTEX_Y3] * atlas_height);
        rect.size = CGSizeMake((uvs[VERTEX_X1] - uvs[VERTEX_X2]) * atlas_width, (uvs[VERTEX_Y2] - uvs[VERTEX_Y3]) * atlas_height);
    } else {
        rect.origin = CGPointMake(uvs[VERTEX_X2] * atlas_width, uvs[VERTEX_Y2] * atlas_height);
        rect.size = CGSizeMake((uvs[VERTEX_X3] - uvs[VERTEX_X2]) * atlas_width, (uvs[VERTEX_Y1] - uvs[VERTEX_Y2]) * atlas_height);
    }
    NSLog(@"%@", NSStringFromCGRect(rect));
     */
    return result;
}

- (NSString *) description
{
    return [NSString stringWithFormat:@"%@ {name:%@ %@ size:%@}",
            NSStringFromClass([self class]), self.name,
            NSStringFromSpineGeometry(self.geometry),
            NSStringFromCGSize(self.size)];
}

@end
