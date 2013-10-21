//
//  SpineAttachment.m
//  PZTool
//
//  Created by Simon Kim on 13. 10. 9..
//  Copyright (c) 2013 DZPub.com. All rights reserved.
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
    
    BOOL rotated = NO;
    CGRect region = spine_uvs2rect(rattach->uvs, &rotated);
    [result setRectInAtlas:region];
    [result setRegionRotated:rotated];
    
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
