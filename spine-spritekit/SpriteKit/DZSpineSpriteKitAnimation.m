//
//  DZSpineSpriteKitAnimation.m
//  PZTool
//
//  Created by Simon Kim on 13. 10. 19..
//  Copyright (c) 2013년 DZPub.com. All rights reserved.
//

#import "DZSpineSpriteKitAnimation.h"
#import <SpriteKit/SpriteKit.h>

#import "SpineAnimation.h"
#import "SpineSequence.h"
#import "DZSpineTexturePool.h"

#define GEOMETRY_FOR_ATTACHMENT(attachment) (SpineGeometryMake((attachment)->x, (attachment)->y, (attachment)->scaleX, (attachment)->scaleY, (attachment)->rotation))
#define GEOMETRY_FOR_BONE(bone) SpineGeometryMake(bone->data->x, bone->data->y, bone->data->scaleX, bone->data->scaleY, bone->data->rotation)

@interface DZSpineSpriteKitAnimation()
@property (nonatomic, readonly) NSMutableDictionary *mapTraceSettings;

- (void) setTraceOn:(BOOL) on type:(NSString *) type part:(NSString *) part;
- (BOOL) isTraceOnForType:(NSString *) type part:(NSString *) part;
@end

@implementation DZSpineSpriteKitAnimation
@synthesize mapTraceSettings = _mapTraceSettings;

- (id) initWithSkeleton:(SpineSkeleton *) skeleton maps:(DZSpineSpriteKitMaps *) maps
{
    self = [super init];
    if ( self ) {
        self.skeleton = skeleton;
        self.maps = maps;
        
    }
    return self;
        
}
#pragma mark - Trace
- (NSMutableDictionary *) mapTraceSettings
{
    if ( _mapTraceSettings == nil ) {
        _mapTraceSettings = [NSMutableDictionary dictionary];
    }
    return _mapTraceSettings;
}

- (void) setTraceOn:(BOOL) on type:(NSString *) type part:(NSString *) part
{
    NSMutableDictionary *mapParts = self.mapTraceSettings[type];
    if ( mapParts == nil ) {
        mapParts = [NSMutableDictionary dictionary];
        self.mapTraceSettings[type] = mapParts;
    }
    mapParts[part] = @(on);
}

- (BOOL) isTraceOnForType:(NSString *) type part:(NSString *) part
{
    NSMutableDictionary *mapParts = self.mapTraceSettings[type];
    return (mapParts != nil && [mapParts[part] boolValue] == YES);
}

#pragma mark - Slot Animation
- (SKTexture *) textureForAttachment:(spAttachment *) attachment
                             rotated:(BOOL *) protated
{
    NSString *atlasName = nil;
    CGRect rect;
    SKTexture *texture = nil;
    *protated = NO;
    
    if ( attachment && attachment->name && attachment->type == ATTACHMENT_REGION) {
        // Try override
        if ( attachment->name ) {
            NSDictionary *override = self.maps.mapOverrideAttachmentToTexture[@(attachment->name)];
            if ( override ) {
                // Override texture?
                atlasName = override[@"textureName"];
                rect = CGRectFromString(override[@"rectInAtlas"]);
            }
        }
        
        // Try attachment
        if ( atlasName == nil) {
            spRegionAttachment *rattach = (spRegionAttachment *) attachment;
            
            atlasName = (__bridge NSString *) ((spAtlasRegion*)rattach->rendererObject)->page->rendererObject;
            rect = spine_uvs2rect(rattach->uvs, protated);
            rect.origin.y = 1 - rect.origin.y;
        }
        
        if ( atlasName ) {
            SKTexture *textureAtlas = [[DZSpineTexturePool sharedPool] textureAtlasWithName:atlasName];
            
            // Texture
            texture = [SKTexture textureWithRect:rect inTexture:textureAtlas];
            if (texture == nil) {
                NSLog(@"sprite: texture missing for %s atlas:%@ rect:%@", attachment->name, atlasName, NSStringFromCGRect(rect));
            }
        }
    }
    return texture;
}

- (spAttachment *) attachmentForSlotName:(NSString *) slotName attachmentName:(NSString *) attachmentName
{
    const char *slotname = [slotName UTF8String];
    const char *attachmentname = [attachmentName UTF8String];
    spAttachment *attachment = 0;
    spSlot *cslot;
    
    cslot = spSkeleton_findSlot(self.skeleton.spineContext->skeleton, slotname);
    if (attachmentname) {
        attachment = spSkeleton_getAttachmentForSlotName(self.skeleton.spineContext->skeleton, slotname, attachmentname);
    } else if ( cslot ) {
        attachment = cslot->attachment;
    }
    if ( attachment && attachment->type != ATTACHMENT_REGION) {
        attachment = 0;
    }
    
    return attachment;
}

- (SKAction *) skActionForSlotName:(NSString *) slotName
                    attachmentName:(NSString *) attachmentName
                          duration:(CGFloat) duration
                            sprite:(SKSpriteNode *) sprite;
{
    SKAction *action = nil;
    spAttachment *attachment = [self attachmentForSlotName:slotName attachmentName:attachmentName];
    NSMutableArray *subActions = [NSMutableArray array];
    SKAction *actionWaitFirst = nil;
    
    CGFloat minDuration = 0.1;
    if ( duration > minDuration) {
        actionWaitFirst = [SKAction waitForDuration:duration - minDuration];
        [subActions addObject:[SKAction waitForDuration:minDuration]];
    } else {
        [subActions addObject:[SKAction waitForDuration:duration]];
    }
    
    if ( attachment && attachment->name) {
        BOOL rotated;
        
        SKTexture *texture = [self textureForAttachment:attachment rotated:&rotated];
        [subActions addObject:[SKAction setTexture:texture]];
        
        SpineGeometry geometry = GEOMETRY_FOR_ATTACHMENT((spRegionAttachment *)attachment);
        geometry.scale.x *= self.skeleton.scale;
        geometry.scale.y *= self.skeleton.scale;
        
        CGFloat radians = (CGFloat)(geometry.rotation * M_PI / 180);
        CGSize size = texture.size;
        if ( rotated ) {
            radians += (-M_PI/2);
            size.width = texture.size.width;
            size.height = texture.size.height;
        }
        /* 
         * Workaround: actual size does not take xScale/yScale into account if a texture of a different size is set
         * Thus, we scale the size explicitly
         */
        size.width *= geometry.scale.x;
        size.height *= geometry.scale.y;
        
        [subActions addObject:[SKAction rotateToAngle:radians duration:0 shortestUnitArc:YES]];
        [subActions addObject:[SKAction moveTo:geometry.origin duration:0]];
        [subActions addObject:[SKAction resizeToWidth:size.width height:size.height duration:0]];
        [subActions addObject:[SKAction scaleXTo:geometry.scale.x y:geometry.scale.y duration:0]];
    } else {
        [subActions addObject:[SKAction runBlock:^{
            sprite.texture = nil;
        }]];
    }
    if ( [self isTraceOnForType:@"slots" part:slotName]) {
        NSString *attachmentName = attachment && attachment->name ? @(attachment->name) : @"";
        [subActions addObject:[SKAction runBlock:^{
            NSLog(@"slots.%@.attachment:%@ duration:%2.4f", slotName, attachmentName, duration);
        }]];
    }
    
    if ( actionWaitFirst ) {
        action = [SKAction sequence:@[actionWaitFirst, [SKAction group:subActions]]];
    } else {
        action = [SKAction group:subActions];
    }
    return action;
}

- (void) applySlotAnimations:(NSArray *) animations loop:(BOOL) loop
{
    // Slot Animations
    CGFloat delay = 0;  // delay between animations
    
    for( NSString *slotName in [self.maps.mapSlotToNode allKeys]) {
        SKSpriteNode *sprite = self.maps.mapSlotToNode[slotName];
        NSMutableArray *actions = [NSMutableArray array];
        CGFloat totalDuration = 0;
        BOOL hasAction = NO;

        if ( [self isTraceOnForType:@"slots" part:slotName]) {
            [actions addObject:[SKAction runBlock:^{
                NSLog(@"Beginning of sequence for sprite:%@", sprite.name);
            }]];
        }
        
        for( SpineAnimation *animation in animations) {
            SpineTimeline *timeline = [animation timelineForType:@"slots" forPart:slotName];
            CGFloat time = 0;
            if ( timeline ) {
                NSLog(@"timeline for slots.%@: %@", slotName, timeline);
                
                NSArray *sequences = [timeline sequencesForType:@"attachment"];
                
                // Setup Pose
                SKAction *action = [self skActionForSlotName:slotName attachmentName:nil duration:0 sprite:sprite];
                [actions addObject:action];
                
                if ( sequences.count > 0 ) {
                    for( SpineSequenceSlot *sequence in sequences ) {
                        CGFloat duration = sequence.time - time;
                        SKAction *action = [self skActionForSlotName:slotName attachmentName:sequence.attachment duration:duration sprite:sprite];
                        [actions addObject:action];
                        
                        time = sequence.time;
                    }
                }
                hasAction = YES;
            }
            [actions addObject:[SKAction waitForDuration:animation.duration - time + delay]];
            totalDuration += animation.duration;
        }
        if ( [self isTraceOnForType:@"slots" part:slotName]) {
            [actions addObject:[SKAction runBlock:^{
                NSLog(@"End of sequence for sprite:%@ totalDuration:%2.3f", sprite.name, totalDuration);
            }]];
        }
        
        if ( hasAction > 0 ) {
            SKAction *action = [SKAction sequence:actions];
            if ( loop ) {
                action = [SKAction repeatActionForever:action];
            }
            [sprite runAction:action];
        }
    }
}

#pragma mark - Bone Animation
+ (void) removeActionsFromNodeTree:(SKNode *) parentNode
{
    [parentNode removeAllActions];
    [[parentNode children] enumerateObjectsUsingBlock:^(SKNode *node, NSUInteger idx, BOOL *stop) {
        [self removeActionsFromNodeTree:node];
    }];
}

#pragma mark - Experimental Bone Animation

- (SKAction *) skActionForBone:(spBone *) bone sequence:(SpineSequence *) sequence
{
    SKAction *action = nil;
    SpineGeometry geometry = GEOMETRY_FOR_BONE(bone);
    NSString *boneName = @(bone->data->name);
    
    if ( sequence.dummy ) {
        action = [SKAction waitForDuration:sequence.duration];
    } else if ( [sequence.type isEqualToString:kSpineSequenceTypeBonesTranslate]) {
        CGPoint point = geometry.origin; //node.position;
        point.x += ((SpineSequenceBone *)sequence).translate.x;
        point.y += ((SpineSequenceBone *)sequence).translate.y;
        
        action = [SKAction moveTo:point duration:sequence.duration];
        
    } else if ( [sequence.type isEqualToString:kSpineSequenceTypeBonesRotate]) {
        CGFloat radians = geometry.rotation * M_PI / 180;
        radians += ((SpineSequenceBone *)sequence).angle * M_PI / 180;
        action = [SKAction rotateToAngle:radians duration:sequence.duration shortestUnitArc:YES];
    } else if ( [sequence.type isEqualToString:kSpineSequenceTypeBonesScale]) {
        CGPoint scale = geometry.scale;
        scale.x *= ((SpineSequenceBone *)sequence).scale.x;
        scale.y *= ((SpineSequenceBone *)sequence).scale.y;
        action = [SKAction scaleXTo:scale.x y:scale.y duration:sequence.duration];
    } else {
        NSLog(@"Unsupported sequence type:%@", sequence.type);
        action = [SKAction waitForDuration:sequence.duration];
    }
    
    if ( [self isTraceOnForType:@"bones" part:boneName]) {
        action = [SKAction group:@[action, [SKAction runBlock:^{
            NSLog(@"bones.%@.type:%@ duration:%2.4f sequence:%@", boneName, sequence.type, sequence.duration, sequence);
        }]]];
    }
    
    return action;
}

- (SKAction *) skActionsForBone:(spBone *) bone sequences:(NSArray *) sequences sequenceType:(NSString *) sequenceType
{
    NSMutableArray *actions = [NSMutableArray array];
    CGFloat totalDuration = 0;
    NSString *boneName = @(bone->data->name);
    SpineSequence *lastSequence = sequences[0];
    
    lastSequence.duration = lastSequence.time;
    [actions addObject:[self skActionForBone:bone sequence:lastSequence]];
    
    totalDuration += lastSequence.duration;
    SpineSequence *sequence = nil;
    for( int i = 1; i < sequences.count; i++ ) {
        sequence = sequences[i];
        sequence.duration = sequence.time - lastSequence.time;
        SKAction *action = [self skActionForBone:bone sequence:sequence];
        
        // Apply curve data in the last sequence
        if (lastSequence.curve == SpineSequenceCurveBezier ) {
            action.timingMode = SKActionTimingEaseInEaseOut;
        } else {
            action.timingMode = SKActionTimingLinear;
        }
        [actions addObject:action];
        totalDuration += sequence.duration;
        
        lastSequence = sequence;
    }
    
    if ( [self isTraceOnForType:@"bones" part:boneName]) {
        [actions addObject:[SKAction runBlock:^{
            NSLog(@"End of sequence for bone:%@ type:%@ totalDuration:%2.3f", boneName, sequenceType, totalDuration);
        }]];
    }
    return [SKAction sequence:actions];
}

- (SKAction *) skActionForBone:(spBone *) bone timeline:(SpineTimeline *) timeline duration:(CGFloat) duration delay:(CGFloat) delay
{
    NSMutableArray *actions = [NSMutableArray array];
    NSArray *sequenceTypes = [timeline types];
    SKAction *poseGroup = nil;
    NSString *boneName = @(bone->data->name);
    
    // Pose actions
    if ( [self isTraceOnForType:@"bones" part:boneName]) {
        [actions addObject:[SKAction runBlock:^{
            NSLog(@"Beginning of sequence for bone:%@", boneName);
        }]];
    }
    
    // Ugly Hack: pose setup if the first sequence is not a time 0s
    SpineGeometry geometry = GEOMETRY_FOR_BONE(bone);
    CGFloat poseDelay = delay;
    if ( ![sequenceTypes containsObject:kSpineSequenceTypeBonesTranslate] || [[timeline sequencesForType:kSpineSequenceTypeBonesTranslate][0] time] != 0) {
        [actions addObject:[SKAction moveTo:geometry.origin duration:poseDelay]];
    }
    if ( ![sequenceTypes containsObject:kSpineSequenceTypeBonesRotate] || [[timeline sequencesForType:kSpineSequenceTypeBonesRotate][0] time] != 0) {
        CGFloat radians = (CGFloat)(geometry.rotation * M_PI / 180);
        [actions addObject:[SKAction rotateToAngle:radians duration:poseDelay shortestUnitArc:YES]];
    }
    if ( ![sequenceTypes containsObject:kSpineSequenceTypeBonesScale] || [[timeline sequencesForType:kSpineSequenceTypeBonesScale][0] time] != 0) {
        [actions addObject:[SKAction scaleXTo:geometry.scale.x y:geometry.scale.y duration:poseDelay]];
    }
    
    if ( [self isTraceOnForType:@"bones" part:boneName]) {
        [actions addObject:[SKAction runBlock:^{
            NSLog(@"After Pose for bone:%@", boneName);
        }]];
    }
    poseGroup = [SKAction group:actions];
    [actions removeAllObjects];
    
    for( NSString *sequenceType in sequenceTypes) {
        NSArray *sequences = [timeline sequencesForType:sequenceType];
        SKAction *action = [self skActionsForBone:bone sequences:sequences sequenceType:sequenceType];
        [actions addObject:action];
    }
    
    
    NSMutableArray *mainActions = [NSMutableArray array];
    if ( poseGroup ) {
        [mainActions addObject:poseGroup];
    }
    if ( actions.count > 0) {
        [mainActions addObject:[SKAction group:actions]];
    }
    
    SKAction *action = nil;
    if ( mainActions.count > 0 ) {
        if ( [self isTraceOnForType:@"bones" part:boneName]) {
            [mainActions addObject:[SKAction runBlock:^{
                NSLog(@"End of sequence for bone:%@ totalDuration:%2.3f", boneName, duration);
            }]];
        }
        
        [actions removeAllObjects];
        [actions addObject:[SKAction sequence:mainActions]];
        
        // Synchronize the whole duration of the part animation
        [actions addObject:[SKAction waitForDuration:duration]];
        action = [SKAction group:actions];
    }
    return action;
}

- (void) applyBoneAnimations:(NSArray *) animations loop:(BOOL) loop
{
    CGFloat delay = 0;
    
    for( NSString *boneName in [self.maps.mapBoneToNode allKeys]) {
        SKNode *node = self.maps.mapBoneToNode[boneName];
        spBone *bone = spSkeleton_findBone(self.skeleton.spineContext->skeleton, [boneName UTF8String]);
        
        
        if ( node && bone ) {
            NSMutableArray *actions = [NSMutableArray array];
            
            for (SpineAnimation *animation in animations) {
                SpineTimeline *timeline = [animation timelineForType:@"bones" forPart:boneName];
                //if ( timeline ) {
                SKAction *action = [self skActionForBone:bone timeline:timeline duration:animation.duration delay:delay];
                    if ( action ) {
                        [actions addObject:action];
                    }
                //}
            }
            if ( actions.count > 0) {
                SKAction *action = [SKAction sequence:actions];
                if ( loop ) {
                    action = [SKAction repeatActionForever:action];
                }
                [node runAction:action];
            }
            
        }
        
    }
}
@end
