//
//  SpineSlot.h
//  PZTool
//
//  Created by Simon Kim on 13. 10. 9..
//  Copyright (c) 2013 DZPub.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SpineAttachment.h"
#import "SpineBone.h"
#import <spine/spine.h>

@interface SpineSlot : NSObject
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) SpineBone *bone;
@property (nonatomic, strong) SpineAttachment *attachment;

+ (id) slotWithCSlot:(spSlot *) slot;
@end
