//
//  DZSpineLoader.m
//  PZTool
//
//  Created by Simon Kim on 13. 10. 9..
//  Copyright (c) 2013 DZPub.com. All rights reserved.
//

#import "DZSpineLoader.h"
#include "spine_adapt.h"
#import "SpineTimeline.h"
#import "SpineSequence.h"

@interface DZSpineLoader()
@end

@implementation DZSpineLoader

+ (void) loadTimelinesFromSkeletonName:(NSString *) skelName skeleton:(SpineSkeleton *) skeleton scale:(CGFloat) scale
{
    
    NSURL *URL = [[NSBundle mainBundle] URLForResource:skelName withExtension:nil];
    NSData *data = [NSData dataWithContentsOfURL:URL];
    NSDictionary *skeletonRaw = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    
    // animations.<animation_name>.<animation_type>.<timeline_type>
    NSDictionary *animations = skeletonRaw[@"animations"];
    
    // Animations
    for( NSString *animationName in [animations allKeys]) {
        SpineAnimation *spineAnimation = [skeleton animationWithName:animationName];
        if ( spineAnimation == nil ) {
            spineAnimation = [SpineAnimation animationWithName:animationName duration:0];
            [skeleton addAnimation:spineAnimation];
        }
        NSDictionary *animation = animations[animationName];

        NSArray *sections = [animation allKeys];    // bones, slots, ...
        NSLog(@"Sections:%@", sections);
        
        for( NSString *section in sections ) {
            NSDictionary *timelines = animation[section];
            
            if ( [timelines isKindOfClass:[NSArray class]]) {
                // events, draworder
                NSLog(@"%@.%@ - Not supported yet", animationName, section);
            } else {
                NSLog(@"%@.%@:%@", animationName, section, [timelines allKeys]);
                // Parts: bone names, or slot names
                for( NSString *part in [timelines allKeys]) {
                    SpineTimeline *spineTimeline = [SpineTimeline timeline];
                    NSDictionary *sequences = timelines[part];
                    
                    // subsequence: translate, rotate, scale
                    for( NSString *type in [sequences allKeys]) {
                        
                        NSMutableArray *subSequences = [NSMutableArray arrayWithArray:sequences[type]];
                        for( int i = 0; i < subSequences.count; i++ ) {
                            subSequences[i] = [SpineSequence sequenceWithType:type dictionary:subSequences[i] scale:scale];
                        }
                        
                        [spineTimeline setSequences:subSequences forType:type];
                    }
                    
                    NSLog(@"Timeline for: %@.%@", section, part);
                    NSLog(@" - %@", spineTimeline);
                    [spineAnimation setTimeline:spineTimeline forType:section forPart:part];
                }
            }
        }
    }

}
// create and add a SpineBone object to SpineSkeleton and it's parent recursively
+ (SpineBone *) addBone:(spBone *) bone toSpineSkeleton:(SpineSkeleton *) skeleton
{
    SpineBone *spineBone = [skeleton boneWithName:@(bone->data->name)];
    if ( spineBone == nil ) {
        NSLog(@"Adding bone:%s", bone->data->name);
        spineBone = [SpineBone boneWithCBone:bone];
        [skeleton addBone:spineBone];
        
        if ( bone->parent ) {
            SpineBone *parent = [self addBone:bone->parent toSpineSkeleton:skeleton];
            spineBone.parent = parent;
            [parent addChild:spineBone];
            NSLog(@" - parent:%s", bone->parent->data->name);
        }
    }
    return spineBone;
}

+ (SpineSkeleton *) skeletonWithName:(NSString *) name atlasName:(NSString *) atlasName scale:(CGFloat) scale animationName:(NSString *) animationName
{
    SpineSkeleton *result = nil;
    int ret = -1;
    struct spinecontext ctx;
    
    // Runtime load
    ret = spine_load(&ctx, [name UTF8String], [atlasName UTF8String], scale, [animationName UTF8String]);
    
    if ( ret == 0 ) {
        if ( animationName == 0 && ctx.skeletonData->animationCount > 0) {
            animationName = @(ctx.skeletonData->animations[0]->name);
            printf("spine: Selecting the first animation as a default:%s\n", ctx.skeletonData->animations[0]->name);
        }
        
        spSkeleton_update(ctx.skeleton, 0.f);
        spAnimationState_setAnimationByName(ctx.state, 0, [animationName UTF8String], 0);
        spAnimationState *state = ctx.state;
        spSkeleton *skeleton = ctx.skeleton;
        
        spAnimationState_update(state, 0.f);
        spAnimationState_apply(state, skeleton);
        spSkeleton_updateWorldTransform(skeleton);
        
        result = [[SpineSkeleton alloc] init];
        [result setSpineContext:&ctx owns:YES];
        
        // Animations
        for (int i = 0, n = ctx.skeletonData->animationCount; i < n; i++) {
            [result addAnimation:[SpineAnimation animationWithCAnimation:ctx.skeletonData->animations[i]]];
        }
        
        // Bones
        for (int i = 0, n = skeleton->boneCount; i < n; i++) {
            [self addBone:skeleton->bones[i] toSpineSkeleton:result];
        }
        
        // Slots
        for (int i = 0, n = skeleton->slotCount; i < n; i++) {
            spSlot* slot = skeleton->drawOrder[i];
            SpineSlot *spineSlot = [SpineSlot slotWithCSlot:slot];
            
            spineSlot.bone = [result boneWithName:@(slot->bone->data->name)];
            [result addSlot:spineSlot];
            
            spineSlot.bone.drawOrderIndex = i;
        }
        
        [self loadTimelinesFromSkeletonName:name skeleton:result scale:scale];
        
        /* pointers in ctx will be disposed when SpineSkeleton deallocated */
    }
    return result;
}

@end

