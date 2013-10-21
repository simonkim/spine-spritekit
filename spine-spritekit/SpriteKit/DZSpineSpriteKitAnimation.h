//
//  DZSpineSpriteKitAnimation.h
//  PZTool
//
//  Created by Simon Kim on 13. 10. 19..
//  Copyright (c) 2013년 DZPub.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SpriteKit/SpriteKit.h>
#import "SpineSkeleton.h"
#import "DZSpineSpriteKitMaps.h"

@interface DZSpineSpriteKitAnimation : NSObject
@property (nonatomic, strong) SpineSkeleton *skeleton;
@property (nonatomic, strong) DZSpineSpriteKitMaps *maps;

- (void) applySlotAnimations:(NSArray *) animations loop:(BOOL) loop;
- (void) applyBoneAnimations:(NSArray *) animations loop:(BOOL) loop;
- (id) initWithSkeleton:(SpineSkeleton *) skeleton maps:(DZSpineSpriteKitMaps *) maps;
- (void) setTraceOn:(BOOL) on type:(NSString *) type part:(NSString *) part;
- (BOOL) isTraceOnForType:(NSString *) type part:(NSString *) part;
@end
