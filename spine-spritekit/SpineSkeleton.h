//
//  SpineSkeleton.h
//  PZTool
//
//  Created by Simon Kim on 13. 10. 9..
//  Copyright (c) 2013 DZPub.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SpineBone.h"
#import "SpineSlot.h"
#import "SpineAnimation.h"

@interface SpineSkeleton : NSObject
@property (nonatomic, strong) NSString *name;
@property (nonatomic, copy, readonly) NSArray *bones;
@property (nonatomic, copy, readonly) NSArray *slots;
@property (nonatomic, copy, readonly) NSArray *animations;
@property (nonatomic, copy, readonly) NSArray *animationNames;
@property (nonatomic, readonly) CGFloat scale;
@property (nonatomic, readonly) struct spinecontext *spineContext;
@property (nonatomic, readonly) BOOL ownsSpineContext;

- (void) setSpineContext:(struct spinecontext *)spineContext owns:(BOOL) owns;
- (void) addSlot:(SpineSlot *) slot;
- (void) addBone:(SpineBone *) bone;
- (SpineBone *) boneWithName:(NSString *) name;
- (void) addAnimation:(SpineAnimation *) animation;
- (SpineAnimation *) animationWithName:(NSString *) name;

+ (id) skeletonWithName:(NSString *) name atlasName:(NSString *) atlasName scale:(CGFloat) scale;

@end
