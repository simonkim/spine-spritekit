//
//  SpineAttachment.h
//  PZTool
//
//  Created by Simon Kim on 13. 10. 9..
//  Copyright (c) 2013 DZPub.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "spine_adapt.h"
#import "SpineGeometry.h"
/*
 class Attachment <- Runtime: Skeleton->drawOrder[]->RegionAttachment
    skin?
    image
    size
    origin
    scale
    rotation
 */
@interface SpineAttachment : NSObject
@property (nonatomic, strong) NSString *name;
@property (nonatomic) CGSize size;
@property (nonatomic) SpineGeometry geometry;
@property (nonatomic) CGRect rectInAtlas;
@property (nonatomic) BOOL regionRotated;
@property (nonatomic) void *rendererObject;

+ (id) attachmentWithCAttachment:(spAttachment *) attachment;

@end
