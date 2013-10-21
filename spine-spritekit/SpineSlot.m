//
//  SpineSlot.m
//  PZTool
//
//  Created by Simon Kim on 13. 10. 9..
//  Copyright (c) 2013 DZPub.com. All rights reserved.
//

#import "SpineSlot.h"

@implementation SpineSlot

+ (id) slotWithCSlot:(spSlot *) slot
{
    id result = [[[self class] alloc] init];
    [result setName:@(slot->data->name)];
    [result setBone:[SpineBone boneWithCBone:slot->bone]];
    if ( slot->attachment && slot->attachment->type == ATTACHMENT_REGION) {
        [result setAttachment:[SpineAttachment attachmentWithCAttachment:slot->attachment]];
    } else if ( slot->attachment ) {
        NSLog(@"Unsupported attachment type:%d for slot:%@", slot->attachment->type, [result name]);
    }
    
    return result;
}

- (NSString *) description
{
    return [NSString stringWithFormat:@"%@ {\n -%@\n -%@\n -%@}",
            NSStringFromClass([self class]), self.name, self.bone, self.attachment];
}
@end
