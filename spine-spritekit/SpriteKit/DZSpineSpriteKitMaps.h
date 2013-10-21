//
//  DZSpineSpriteKitMaps.h
//  PZTool
//
//  Created by Simon Kim on 13. 10. 19..
//  Copyright (c) 2013년 DZPub.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DZSpineSpriteKitMaps : NSObject
@property (nonatomic, readonly) NSMutableDictionary *mapBoneToNode;
@property (nonatomic, readonly) NSMutableDictionary *mapSlotToNode;
@property (nonatomic, readonly) NSMutableDictionary *mapOverrideAttachmentToTexture;

+ (id) maps;
@end
