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
    NSString *timelineType = @"bones";
    
    // Animations
    for( NSString *animationName in [animations allKeys]) {
        SpineAnimation *spineAnimation = [skeleton animationWithName:animationName];
        if ( spineAnimation == nil ) {
            spineAnimation = [SpineAnimation animationWithName:animationName duration:0];
            [skeleton addAnimation:spineAnimation];
        }
        NSDictionary *animation = animations[animationName];

        // "bones" timeline only for now
        NSDictionary *timelines = animation[timelineType];
        NSLog(@"%@.%@:%@", animationName, timelineType, [timelines allKeys]);
        
        
        // Timelines
        for( NSString *boneName in [timelines allKeys]) {
            SpineTimeline *spineTimeline = [SpineTimeline timeline];
            NSDictionary *sequences = timelines[boneName];
            
            // subsequence: translate, rotate, scale
            for( NSString *type in [sequences allKeys]) {
                
                NSMutableArray *subSequences = [NSMutableArray arrayWithArray:sequences[type]];
                for( int i = 0; i < subSequences.count; i++ ) {
                    subSequences[i] = [SpineSequence sequenceWithType:type dictionary:subSequences[i] scale:scale];
                }
                
                [spineTimeline setSequences:subSequences forType:type];
            }
            
            NSLog(@"Timeline: %@", boneName);
            [spineAnimation setTimeline:spineTimeline forType:timelineType forPart:boneName];
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
    
    struct spinecontext ctx;
    
    // Runtime load
    spine_load(&ctx, [name UTF8String], [atlasName UTF8String], scale, [animationName UTF8String]);
    
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
    // Atlas
    [result setAtlasName:@(ctx.atlas->pages->name)];
    [result setAtlasSize:CGSizeMake(ctx.atlas->pages->width, ctx.atlas->pages->height)];
    
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
        if ( slot->attachment && slot->attachment->type == ATTACHMENT_REGION && spineSlot.attachment ) {
            
            // Atlas Region for the Attachment
            spRegionAttachment *rattach = (spRegionAttachment *) slot->attachment;
            CGRect region = spineSlot.attachment.rectInAtlas;
            region.size.width = rattach->regionWidth;
            region.size.height = rattach->regionHeight;
            
            
            float *uvs = rattach->uvs;
            if ( (uvs[VERTEX_X3] - uvs[VERTEX_X2]) == 0 ) {
                region.origin = CGPointMake(uvs[VERTEX_X2], uvs[VERTEX_Y2]);    // bottom-left
                region.size = CGSizeMake((uvs[VERTEX_X4] - uvs[VERTEX_X3]),(uvs[VERTEX_Y1] - uvs[VERTEX_Y4]));
                spineSlot.attachment.regionRotated = YES;
            } else {
                region.origin = CGPointMake(uvs[VERTEX_X1], uvs[VERTEX_Y1]);    // bottom-left
                region.size = CGSizeMake((uvs[VERTEX_X3] - uvs[VERTEX_X2]),(uvs[VERTEX_Y1] - uvs[VERTEX_Y2]));
                spineSlot.attachment.regionRotated = NO;
            }
            spineSlot.attachment.rectInAtlas = region;
        }
        
        spineSlot.bone = [result boneWithName:@(slot->bone->data->name)];
        [result addSlot:spineSlot];
        
        spineSlot.bone.drawOrderIndex = i;
    }
    
    [self loadTimelinesFromSkeletonName:name skeleton:result scale:scale];
    
    spine_dispose(&ctx);
    
    return result;
}

@end

