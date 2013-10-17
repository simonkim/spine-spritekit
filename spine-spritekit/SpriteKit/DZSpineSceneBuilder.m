//
//  DZSpineSceneBuilder.m
//  PZTool
//
//  Created by Simon Kim on 13. 10. 13..
//  Copyright (c) 2013년 DZPub.com. All rights reserved.
//

#import "DZSpineSceneBuilder.h"
#import <SpriteKit/SpriteKit.h>
#import "DZSpineTexturePool.h"

#import "SpineSkeleton.h"
#import "SpineGeometry.h"
#import "spine_adapt.h"
#import "SpineSequence.h"

static void * _spine_adapt_createTexture (const char* path, int *pwidth, int *pheight);
static void _spine_adapt_disposeTexture( void * rendobj );

@interface DZSpineSceneBuilder()
@property (nonatomic, readonly) NSMutableDictionary *mapBoneToNode;
@property (nonatomic, readonly) NSMutableDictionary *mapSlotToNode;
@property (nonatomic, readonly) NSMutableDictionary *mapOverrideSlotToAttachment;
@end

@implementation DZSpineSceneBuilder

@synthesize mapBoneToNode = _mapBoneToNode;
@synthesize mapSlotToNode = _mapSlotToNode;
@synthesize mapOverrideSlotToAttachment = _mapOverrideSlotToAttachment;


- (SKNode *) nodeWithSkeleton:(SpineSkeleton *) skeleton animationName:(NSString *) animationName loop:(BOOL)loop
{
    return [self nodeWithSkeleton:skeleton animationNames:animationName ? @[animationName] : nil loop:loop];
}

- (SKNode *) nodeWithSkeleton:(SpineSkeleton *) skeleton animationNames:(NSArray *) animationNames loop:(BOOL)loop
{
    return [[self class] nodeWithSkeleton:skeleton animationNames:animationNames
                                    debug:self.debug
                                      map:self.mapBoneToNode
                                      map:self.mapSlotToNode
                                      map:self.mapOverrideSlotToAttachment loop:loop];
}

- (SKNode *) nodeWithSkeleton:(SpineSkeleton *) skeleton animations:(NSArray *) animations loop:(BOOL)loop
{
    return [[self class] nodeWithSkeleton:skeleton animations:animations
                                    debug:self.debug
                                      map:self.mapBoneToNode
                                      map:self.mapSlotToNode
                                      map:self.mapOverrideSlotToAttachment loop:loop];
}


+ (id) builder
{
    return [[[self class] alloc] init];
}

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

- (NSMutableDictionary *) mapOverrideSlotToAttachment
{
    if ( _mapOverrideSlotToAttachment == nil ) {
        _mapOverrideSlotToAttachment = [NSMutableDictionary dictionary];
    }
    return _mapOverrideSlotToAttachment;
}

#pragma mark - Building Nodes
+ (void) applyGeometry:(SpineGeometry) geometry toNode:(SKNode *) node
{
    node.position = geometry.origin;
    node.xScale = geometry.scale.x;
    node.yScale = geometry.scale.y;
    CGFloat radians = (CGFloat)(geometry.rotation * M_PI / 180);
    node.zRotation = radians;
}

+ (SKNode *) buildNodeWithBone:(SpineBone *) bone debug:(BOOL) debug
{
    SKNode *node = [[SKNode alloc] init];
    [[self class] applyGeometry:bone.geometry toNode:node];
    node.name = bone.name;
    
    if ( debug ) {
        // Debugging bone node
        SKSpriteNode *boneNode = [[SKSpriteNode alloc] initWithColor:[SKColor grayColor] size:CGSizeMake(bone.length, 2)];
        boneNode.anchorPoint = CGPointMake(0, 0);
        boneNode.zPosition = 1000;
        [node addChild:boneNode];
        
        // Debuggong bone anchor node
        SKNode *boneAnchorNode = [[SKSpriteNode alloc] initWithColor:[SKColor redColor] size:CGSizeMake(8,8)];
        boneAnchorNode.zPosition = 1000;
        [node addChild:boneAnchorNode];
    }
    return node;
}

+ (void) buildChildNodesForBone:(SpineBone *) bone
                     parentNode:(SKNode *) parentNode
                      animation:(SpineAnimation *) animation
                          debug:(BOOL) debug
                            map:(NSMutableDictionary *) mapBoneToNode
{
    [bone.children enumerateObjectsUsingBlock:^(SpineBone *child, NSUInteger idx, BOOL *stop) {
        SKNode *node = [[self class] buildNodeWithBone:child debug:debug];
        [parentNode addChild:node];
        if ( child.drawOrderIndex != NSNotFound && bone.drawOrderIndex != NSNotFound) {
            node.zPosition = ((int) child.drawOrderIndex - (int)bone.drawOrderIndex);
            NSLog(@"%@: zPosition=%2.2f drawOrderIndex:%d", child.name, node.zPosition, child.drawOrderIndex);
        }
        if ( animation ) [[self class] applyAnimation:animation toNode:node forBone:child delay:0];
        
        mapBoneToNode[child.name] = node;
        [self buildChildNodesForBone:child parentNode:node animation:animation debug:debug map:mapBoneToNode];
    }];
}

#pragma mark - Animations
+ (void) removeActionsFromNodeTree:(SKNode *) parentNode
{
    [parentNode removeAllActions];
    [[parentNode children] enumerateObjectsUsingBlock:^(SKNode *node, NSUInteger idx, BOOL *stop) {
        [self removeActionsFromNodeTree:node];
    }];
}

+ (SKAction *) skactionWithSpineSequence:(SpineSequence *) sequence forNode:(SKNode *) node forBone:(SpineBone *) bone
{
    SKAction *action = nil;
    if ( sequence.dummy ) {
        action = [SKAction waitForDuration:sequence.duration];
    } else if ( [sequence.type isEqualToString:kSpineSequenceTypeBonesTranslate]) {
        CGPoint point = bone.geometry.origin; //node.position;
        point.x += ((SpineSequenceBone *)sequence).translate.x;
        point.y += ((SpineSequenceBone *)sequence).translate.y;
        
        action = [SKAction moveTo:point duration:sequence.duration];

    } else if ( [sequence.type isEqualToString:kSpineSequenceTypeBonesRotate]) {
        CGFloat radians = bone.geometry.rotation * M_PI / 180;
        radians += ((SpineSequenceBone *)sequence).angle * M_PI / 180;
        action = [SKAction rotateToAngle:radians duration:sequence.duration shortestUnitArc:YES];
    } else if ( [sequence.type isEqualToString:kSpineSequenceTypeBonesScale]) {
        CGPoint scale = bone.geometry.scale;
        scale.x *= ((SpineSequenceBone *)sequence).scale.x;
        scale.y *= ((SpineSequenceBone *)sequence).scale.y;
        action = [SKAction scaleXTo:scale.x y:scale.y duration:sequence.duration];
    } else {
        NSLog(@"Unsupported sequence type:%@", sequence.type);
        action = [SKAction waitForDuration:sequence.duration];
    }

    return action;
}

+ (SKAction *) skactionsWithSpineSequences:(NSArray *) sequences sequenceType:(NSString *) sequenceType forNode:(SKNode *) node forBone:(SpineBone *) bone
{
    NSMutableArray *actions = [NSMutableArray array];
    
    SpineSequence *lastSequence = sequences[0];
    lastSequence.duration = lastSequence.time;
    [actions addObject:[self skactionWithSpineSequence:lastSequence forNode:node forBone:bone]];
    
    SpineSequence *sequence = nil;
    for( int i = 1; i < sequences.count; i++ ) {
        sequence = sequences[i];
        sequence.duration = sequence.time - lastSequence.time;
        SKAction *action = [self skactionWithSpineSequence:sequence forNode:node forBone:bone];
        [actions addObject:action];
        
        // Apply curve data in the last sequence
        if (lastSequence.curve == SpineSequenceCurveBezier ) {
            action.timingMode = SKActionTimingEaseInEaseOut;
        } else {
            action.timingMode = SKActionTimingLinear;
        }
        
        lastSequence = sequence;
    }
    
    return [SKAction sequence:actions];
}

+ (void) applyAnimation:(SpineAnimation *) animation toNode:(SKNode *) node forBone:(SpineBone *) bone delay:(CGFloat) delay
{
    SpineTimeline *boneTimeline = [animation timelineForType:@"bones" forPart:bone.name];
    NSMutableArray *actions = [NSMutableArray array];
    NSArray *sequenceTypes = [boneTimeline types];

    // Pose actions
    CGFloat poseDelay = 0.f;
    [actions addObject:[SKAction moveTo:bone.geometry.origin duration:poseDelay]];
    [actions addObject:[SKAction scaleXTo:bone.geometry.scale.x y:bone.geometry.scale.y duration:poseDelay]];
    CGFloat radians = (CGFloat)(bone.geometry.rotation * M_PI / 180);
    [actions addObject:[SKAction rotateToAngle:radians duration:poseDelay shortestUnitArc:YES]];
    
    //NSLog(@"Animation for bone:%@", bone.name);
    for( NSString *sequenceType in sequenceTypes) {
        //NSLog(@"- sequences type:%@", sequenceType);
        
        NSArray *sequences = [boneTimeline sequencesForType:sequenceType];
        //NSLog(@"- sequences:%@", sequences);
        // type, params, duration
        SKAction *action = [[self class] skactionsWithSpineSequences:sequences sequenceType:sequenceType forNode:node forBone:bone];
        [actions addObject:action];
    }
    
    
    // Synchronize the whole duration of the part animation
    [actions addObject:[SKAction waitForDuration:animation.duration]];
    SKAction *group = [SKAction group:actions];
    
    SKAction *sequence = group;
    if ( delay > 0) {
        sequence = [SKAction sequence:@[ [SKAction waitForDuration:delay], group]];
    }
    // TODO: run forever for loop instead of chaining another sequence of actions
    [node runAction: sequence];
}

+ (void) applyAnimation:(SpineAnimation *) animation toNodeTree:(SKNode *) node forBone:(SpineBone *) bone map:(NSDictionary *) mapBoneToNode delay:(CGFloat) delay
{
    [self applyAnimation:animation toNode:node forBone:bone delay:delay];
    [bone.children enumerateObjectsUsingBlock:^(SpineBone *child, NSUInteger idx, BOOL *stop) {
        SKNode *node = mapBoneToNode[child.name];
        [self applyAnimation:animation toNodeTree:node forBone:child map:mapBoneToNode delay:delay];
    }];
}

+ (void) animatePoseToNodeTree:(SKNode *) node forBone:(SpineBone *) bone map:(NSDictionary *) mapBoneToNode delay:(CGFloat) delay
{
    [node runAction:[SKAction moveTo:bone.geometry.origin duration:delay]];
    [node runAction:[SKAction scaleXTo:bone.geometry.scale.x y:bone.geometry.scale.y duration:delay]];
    CGFloat radians = (CGFloat)(bone.geometry.rotation * M_PI / 180);
    [node runAction:[SKAction rotateToAngle:radians duration:delay shortestUnitArc:YES]];
    [bone.children enumerateObjectsUsingBlock:^(SpineBone *child, NSUInteger idx, BOOL *stop) {
        SKNode *node = mapBoneToNode[child.name];
        [self animatePoseToNodeTree:node forBone:child map:mapBoneToNode delay:delay];
    }];
    
}

+ (CGFloat) chainAnimations:(NSArray *) animations toNodeTree:(SKNode *) node forBone:(SpineBone *) bone map:(NSDictionary *) mapBoneToNode loop:(BOOL) loop
{
    CGFloat delay = 0;
    for( SpineAnimation *animation in animations) {
        NSLog(@"Applying Animation:%@", animation.name);
        [[self class] applyAnimation:animation toNodeTree:node forBone:bone map:mapBoneToNode delay:delay];
        delay += animation.duration;
    }
    if ( loop ) {
        SKAction *delayAction = [SKAction waitForDuration:delay];
        [node runAction:delayAction completion:^{
            [[self class] chainAnimations:animations toNodeTree:node forBone:bone map:mapBoneToNode loop:loop];
        }];
    }
    
    return delay;
}

#pragma mark - Building Nodes
+ (SKNode *) nodeWithSkeleton:(SpineSkeleton *) skeleton animationName:(NSString *) animationName
                        debug:(BOOL) debug
                          map:(NSMutableDictionary *) mapBoneToNode
                          map:(NSMutableDictionary *) mapSlotToNode
                          map:(NSMutableDictionary *) mapOverrideSlotToAttachment
                         loop:(BOOL) loop
{
    NSArray *animationNames = (animationName ? @[animationName] : nil);
    return [self nodeWithSkeleton:skeleton animationNames:animationNames
                            debug:debug
                              map:mapBoneToNode
                              map:mapSlotToNode
                              map:mapOverrideSlotToAttachment
                             loop:loop
            ];
}

+ (SKNode *) nodeWithSkeleton:(SpineSkeleton *) skeleton animationNames:(NSArray *) animationNames
                        debug:(BOOL) debug
                          map:(NSMutableDictionary *) mapBoneToNode
                          map:(NSMutableDictionary *) mapSlotToNode
                          map:(NSMutableDictionary *) mapOverrideSlotToAttachment
                         loop:(BOOL) loop
{
    NSMutableArray *animations = [NSMutableArray array];
    
    for( NSString *animationName in animationNames) {
        SpineAnimation *animation = [skeleton animationWithName:animationName];
        if ( animation ) {
            [animations addObject:animation];
        }
    }
    
    return [self nodeWithSkeleton:skeleton animations:animations debug:debug map:mapBoneToNode map:mapSlotToNode map:mapOverrideSlotToAttachment loop:loop];
}

+ (SKNode *) nodeWithSkeleton:(SpineSkeleton *) skeleton animations:(NSArray *) animations
                        debug:(BOOL) debug
                          map:(NSMutableDictionary *) mapBoneToNode
                          map:(NSMutableDictionary *) mapSlotToNode
                          map:(NSMutableDictionary *) mapOverrideSlotToAttachment
                         loop:(BOOL) loop
{
    CGPoint center = CGPointMake(0, 0 /*/2 */);
    SKNode *root = [SKNode node];
    root.position = center;
    root.name = @"root";
    if ( debug ) {
        SKSpriteNode *boneAnchor = [[SKSpriteNode alloc] initWithColor:[SKColor redColor] size:CGSizeMake(2,2)];
        [root addChild:boneAnchor];
    }
    
    [mapBoneToNode removeAllObjects];
    
    // Bone tree
    SpineBone *bone = [skeleton boneWithName:@"root"];
    if (bone) {
        // update root position
        center.x += bone.geometry.origin.x;
        center.y += bone.geometry.origin.y;
        root.position = center;
        
        // build children nodes
        mapBoneToNode[@"root"] = root;
        
        [[self class] buildChildNodesForBone:bone parentNode:root animation:nil debug:debug map:mapBoneToNode];
    }
    
    // Attachments to Slots
    [mapSlotToNode removeAllObjects];
    [[skeleton slots] enumerateObjectsUsingBlock:^(SpineSlot *slot, NSUInteger idx, BOOL *stop) {
        if ( slot.attachment ) {
            SKNode *node = mapBoneToNode[slot.bone.name];
            if ( node ) {
                
                // Texture Atlas
                NSString *atlasName = nil;;
                CGRect rect = slot.attachment.rectInAtlas;
                NSDictionary *override = mapOverrideSlotToAttachment[slot.name];
                if ( override ) {
                    atlasName = override[@"textureName"];
                    rect = CGRectFromString(override[@"rectInAtlas"]);
                } else {
                    atlasName = (__bridge NSString *) slot.attachment.rendererObject;
                    rect = slot.attachment.rectInAtlas;
                    // Reverse y axis
                    rect.origin.y = 1 - rect.origin.y;
                }
                
                SKTexture *textureAtlas = [[DZSpineTexturePool sharedPool] textureAtlasWithName:atlasName];
                
                // Texture
                SKTexture *texture = [SKTexture textureWithRect:rect inTexture:textureAtlas];
                SKSpriteNode *sprite = [SKSpriteNode spriteNodeWithTexture:texture];
                [[self class] applyGeometry:slot.attachment.geometry toNode:sprite];
                
                // Texture Scaling at Customg Loading
                sprite.xScale *= skeleton.scale;
                sprite.yScale *= skeleton.scale;
                
                // Texture Rotation at Custom Loading
                if ( slot.attachment.regionRotated) {
                    sprite.zRotation += -M_PI/2;
                }
                [node addChild:sprite];
                
                mapSlotToNode[slot.name] = sprite;
            }
        }
    }];
    
    
    if ( animations.count > 0) {
        // Animations
        if (  animations.count > 0) {
            [[self class] chainAnimations:[animations copy] toNodeTree:root forBone:bone map:mapBoneToNode loop:loop];
        }
    }
    
    return root;
}

#pragma mark - API
+ (SpineSkeleton *) loadSkeletonName:(NSString *) name scale:(CGFloat) scale
{
    spine_set_handler_createtexture(_spine_adapt_createTexture);
    spine_set_handler_disposetexture(_spine_adapt_disposeTexture);
    
    return [SpineSkeleton skeletonWithName:[name stringByAppendingPathExtension:@"json"]
                                 atlasName:[name stringByAppendingPathExtension:@"atlas"]
                                     scale:scale];
}

- (void) setTextureName:(NSString *) textureName rect:(CGRect) rect toSlot:(NSString *) slotName
{
    // Override before build sprite tree
    self.mapOverrideSlotToAttachment[slotName] = @{ @"textureName" : textureName, @"rectInAtlas" : NSStringFromCGRect(rect) };
    
    // Runtime sprite replacement
    SKSpriteNode *sprite = self.mapSlotToNode[slotName];
    if ( sprite) {
        SKTexture *textureAtlas = [[DZSpineTexturePool sharedPool] textureAtlasWithName:textureName];
        SKTexture *texture = [SKTexture textureWithRect:rect inTexture:textureAtlas];
        sprite.texture = texture;
    }
}
#pragma mark - Unstable

+ (CGFloat) mergeAndLoopAnimations:(NSArray *) animations toNodeTree:(SKNode *) node forBone:(SpineBone *) bone map:(NSDictionary *) mapBoneToNode loop:(BOOL) loop
{
    CGFloat duration = 0;
    
    SpineAnimation *merged = nil;
    for( SpineAnimation *animation in animations) {
        if (merged) {
            merged = [merged animationByAdding:animation delay:0];
        } else {
            merged = animation;
        }
    }
    
    if ( merged ) {
        duration = merged.duration;
        
        [[self class] applyAnimation:merged toNodeTree:node forBone:bone map:mapBoneToNode delay:0];
        if ( loop ) {
            SKAction *delayAction = [SKAction waitForDuration:duration];
            [node runAction:delayAction completion:^{
                NSLog(@"Animation done:%@", merged.name);
                [[self class] mergeAndLoopAnimations:animations toNodeTree:node forBone:bone map:mapBoneToNode loop:loop];
            }];
        }
    }
    
    return duration;
}

@end

static void * _spine_adapt_createTexture (const char* path, int *pwidth, int *pheight)
{
    printf("%s[%d]: path='%s'\n", __FUNCTION__, __LINE__, path);
    NSString *name = @(path);
    SKTexture *texture = [[DZSpineTexturePool sharedPool] textureAtlasWithName:name];
    NSUInteger index = [[[DZSpineTexturePool sharedPool] names] indexOfObject:name];
    name = [[DZSpineTexturePool sharedPool] names][index];
    
    *pwidth = texture.size.width;
    *pheight = texture.size.height;
    printf("%s[%d]: name:%p\n", __FUNCTION__, __LINE__, name);
    return (__bridge void *)name;
}

static void _spine_adapt_disposeTexture( void * rendobj )
{
    // Keep the texture atlas in the pool
    /*
     if ( rendobj ) {
     NSString *name = (__bridge NSString *) rendobj;
     [[DZSpineTexturePool sharedPool] unloadTextAtlasWithName:name];
     }
     */
}