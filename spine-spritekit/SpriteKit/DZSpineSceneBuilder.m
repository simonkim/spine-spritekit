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
#import "DZSpineSpriteKitMaps.h"
#import "DZSpineSpriteKitAnimation.h"

static void * _spine_adapt_createTexture (const char* path, int *pwidth, int *pheight);
static void _spine_adapt_disposeTexture( void * rendobj );

@interface DZSpineSceneBuilder()
@property (nonatomic, readonly) DZSpineSpriteKitMaps *maps;
@end

@implementation DZSpineSceneBuilder
@synthesize maps = _maps;

- (SKNode *) nodeWithSkeleton:(SpineSkeleton *) skeleton animationName:(NSString *) animationName loop:(BOOL)loop
{
    return [self nodeWithSkeleton:skeleton animationNames:animationName ? @[animationName] : nil loop:loop];
}

- (SKNode *) nodeWithSkeleton:(SpineSkeleton *) skeleton animationNames:(NSArray *) animationNames loop:(BOOL)loop
{
    return [[self class] nodeWithSkeleton:skeleton animationNames:animationNames
                                    debug:self.debug
                                     maps:self.maps
                                     loop:loop];
}

- (SKNode *) nodeWithSkeleton:(SpineSkeleton *) skeleton animations:(NSArray *) animations loop:(BOOL)loop
{
    return [[self class] nodeWithSkeleton:skeleton animations:animations
                                    debug:self.debug
                                     maps:self.maps
                                     loop:loop];
}


+ (id) builder
{
    return [[[self class] alloc] init];
}

#pragma mark - Properties

- (DZSpineSpriteKitMaps *) maps
{
    if ( _maps == nil ) {
        _maps = [DZSpineSpriteKitMaps maps];
    }
    return _maps;
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

+ (void) buildChildNodesForSpineBone:(SpineBone *) bone
                     parentNode:(SKNode *) parentNode
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
        
        mapBoneToNode[child.name] = node;
        [self buildChildNodesForSpineBone:child parentNode:node debug:debug map:mapBoneToNode];
    }];
}

#pragma mark - Animations

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



#pragma mark - Building Nodes
+ (SKNode *) nodeWithSkeleton:(SpineSkeleton *) skeleton animationName:(NSString *) animationName
                        debug:(BOOL) debug
                         maps:(DZSpineSpriteKitMaps *) maps
                         loop:(BOOL) loop
{
    NSArray *animationNames = (animationName ? @[animationName] : nil);
    return [self nodeWithSkeleton:skeleton animationNames:animationNames
                            debug:debug
                             maps:maps
                             loop:loop
            ];
}

+ (SKNode *) nodeWithSkeleton:(SpineSkeleton *) skeleton animationNames:(NSArray *) animationNames
                        debug:(BOOL) debug
                         maps:(DZSpineSpriteKitMaps *) maps
                         loop:(BOOL) loop
{
    NSMutableArray *animations = [NSMutableArray array];
    
    for( NSString *animationName in animationNames) {
        SpineAnimation *animation = [skeleton animationWithName:animationName];
        if ( animation ) {
            [animations addObject:animation];
        }
    }
    
    return [self nodeWithSkeleton:skeleton
                       animations:animations
                            debug:debug
                             maps:maps
                             loop:loop];
}

+ (SKTexture *) textureForAttachment:(spAttachment *) attachment
                             rotated:(BOOL *) protated
                                 map:(NSDictionary *) mapOverride
{
    NSString *atlasName = nil;
    CGRect rect;
    SKTexture *texture = nil;
    *protated = NO;
    
    if ( attachment && attachment->name && attachment->type == ATTACHMENT_REGION) {
        // Try override
        if ( attachment->name ) {
            NSDictionary *override = mapOverride[@(attachment->name)];
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

+ (SKNode *) nodeWithSkeleton:(SpineSkeleton *) skeleton animations:(NSArray *) animations
                        debug:(BOOL) debug
                         maps:(DZSpineSpriteKitMaps *) maps
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
    
    [maps.mapBoneToNode removeAllObjects];
    
    // Bone tree
    SpineBone *bone = [skeleton boneWithName:@"root"];
    if (bone) {
        // update root position
        center.x += bone.geometry.origin.x;
        center.y += bone.geometry.origin.y;
        root.position = center;
        
        // build children nodes
        maps.mapBoneToNode[@"root"] = root;
        
        [[self class] buildChildNodesForSpineBone:bone parentNode:root debug:debug map:maps.mapBoneToNode];
    }
    
    // Sprites: Slot->Attachment
    [maps.mapSlotToNode removeAllObjects];
    for( int i = 0; i < skeleton.spineContext->skeleton->slotCount; i++ ) {
        spSlot *slot = skeleton.spineContext->skeleton->drawOrder[i];
        SKNode *node;
        SKSpriteNode *sprite;
        const char *boneName = slot->bone->data->name;
        if ( boneName ) {
            node = maps.mapBoneToNode[@(boneName)];
            if ( slot->attachment && slot->attachment->type == ATTACHMENT_REGION ) {
                BOOL rotated = NO;
                SKTexture *texture = [self textureForAttachment:slot->attachment rotated:&rotated map:maps.mapOverrideAttachmentToTexture];
                sprite = [SKSpriteNode spriteNodeWithTexture:texture];

                spRegionAttachment *rattach = (spRegionAttachment *) slot->attachment;
                SpineGeometry geometry = SpineGeometryMake((rattach)->x, (rattach)->y, (rattach)->scaleX, (rattach)->scaleY, (rattach)->rotation);
                [[self class] applyGeometry:geometry toNode:sprite];

                // Texture Rotation at Custom Loading
                if ( rotated) {
                    sprite.zRotation += -M_PI/2;
                }
                
            } else {
                // Empty node for later use
                sprite = [SKSpriteNode spriteNodeWithColor:nil size:CGSizeMake(0, 0)];
                
            }
            // Texture Scaling at Customg Loading
            sprite.xScale *= skeleton.scale;
            sprite.yScale *= skeleton.scale;
            
            [node addChild:sprite];
            sprite.name = @(slot->data->name);
            maps.mapSlotToNode[@(slot->data->name)] = sprite;
        }
    }

    if ( animations.count > 0) {
        // Animations
        if (  animations.count > 0) {
            DZSpineSpriteKitAnimation *skAnimation = [[DZSpineSpriteKitAnimation alloc] initWithSkeleton:skeleton maps:maps];
            
            // Bone Animations
            //[skAnimation chainAnimations:[animations copy] rootBone:bone rootNode:root loop:loop];
            [skAnimation applyBoneAnimations:animations loop:loop];
            
            // Slot Animations
            [skAnimation applySlotAnimations:animations loop:loop];
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

- (void) setTextureName:(NSString *) textureName rect:(CGRect) rect forAttachmentName:(NSString *) attachmentName
{
    if ( textureName && attachmentName ) {
        // Override before building sprite tree
        self.maps.mapOverrideAttachmentToTexture[attachmentName] = @{ @"textureName" : textureName, @"rectInAtlas" : NSStringFromCGRect(rect) };
    } else if ( attachmentName ) {
        self.maps.mapOverrideAttachmentToTexture[attachmentName] = nil;
    }
}

/*
 * Runtime sprite texture replacement for slot name
 */
- (void) setTextureWithName:(NSString *)textureName rect:(CGRect)rect forSlotName:(NSString *)slotName
{
    // Runtime sprite replacement
    SKSpriteNode *sprite = self.maps.mapSlotToNode[slotName];
    if ( sprite) {
        SKTexture *textureAtlas = [[DZSpineTexturePool sharedPool] textureAtlasWithName:textureName];
        SKTexture *texture = [SKTexture textureWithRect:rect inTexture:textureAtlas];
        sprite.texture = texture;
    }
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