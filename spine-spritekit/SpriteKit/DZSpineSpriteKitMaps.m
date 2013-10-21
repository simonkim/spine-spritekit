//
//  DZSpineSpriteKitMaps.m
//  PZTool
//
//  Created by Simon Kim on 13. 10. 19..
//  Copyright (c) 2013년 DZPub.com. All rights reserved.
//

#import "DZSpineSpriteKitMaps.h"

@implementation DZSpineSpriteKitMaps
@synthesize mapBoneToNode = _mapBoneToNode;
@synthesize mapSlotToNode = _mapSlotToNode;
@synthesize mapOverrideAttachmentToTexture = _mapOverrideAttachmentToTexture;

#pragma mark - Properties
- (NSMutableDictionary *) mapBoneToNode
{
    if ( _mapBoneToNode == nil ) {
        _mapBoneToNode = [NSMutableDictionary dictionary];
    }
    return _mapBoneToNode;
}

- (NSMutableDictionary *) mapSlotToNode
{
    if ( _mapSlotToNode == nil ) {
        _mapSlotToNode = [NSMutableDictionary dictionary];
    }
    return _mapSlotToNode;
}

- (NSMutableDictionary *) mapOverrideAttachmentToTexture
{
    if ( _mapOverrideAttachmentToTexture == nil ) {
        _mapOverrideAttachmentToTexture = [NSMutableDictionary dictionary];
    }
    return _mapOverrideAttachmentToTexture;
}

+ (id) maps
{
    return [[[self class] alloc] init];
}

@end
