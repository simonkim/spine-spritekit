//
//  DZSpineScene.m
//  PZTool
//
//  Created by Simon Kim on 13. 10. 6..
//  Copyright (c) 2013 DZPub.com. All rights reserved.
//

#import "DZSpineScene.h"
#import "DZSpineLoader.h"
#import "SpineSkeleton.h"
#import "SpineTimeline.h"
#import "SpineSequence.h"
#import "DZSpineTexturePool.h"
#import "spine_adapt.h"

void * _spine_adapt_createTexture (const char* path, int *pwidth, int *pheight);
void _spine_adapt_disposeTexture( void * rendobj );


@interface DZSpineScene()

@property (nonatomic, strong) SpineSkeleton *skeleton;

@property (nonatomic) BOOL contentCreated;
@property (nonatomic, strong) NSString *skeletonName;
@property (nonatomic, strong) NSString *animationName;
@property (nonatomic) CGFloat scaleSkeleton;
@property (nonatomic, readonly) NSMutableDictionary *mapBoneToNode;
@property (nonatomic) BOOL buildDebuggingNodes;
@end

@implementation DZSpineScene
@synthesize mapBoneToNode = _mapBoneToNode;

- (id) initWithSize:(CGSize)size skeletonName:(NSString *) skeletonName animationName:(NSString *) animationName scale:(CGFloat) scale
{
    self = [super initWithSize:size];
    if ( self ) {
        self.scaleSkeleton = scale;
        self.skeletonName = skeletonName;
        self.animationName = animationName;
        self.buildDebuggingNodes = YES;
    }
    return self;
}

#pragma mark - Properties
- (NSMutableDictionary *) mapBoneToNode
{
    if ( _mapBoneToNode == nil ) {
        _mapBoneToNode = [NSMutableDictionary dictionary];
    }
    return _mapBoneToNode;
}

- (SpineSkeleton *) loadSkeletonName:(NSString *) name scale:(CGFloat) scale
{
    spine_set_handler_createtexture(_spine_adapt_createTexture);
    spine_set_handler_disposetexture(_spine_adapt_disposeTexture);
    
    return [SpineSkeleton skeletonWithName:[name stringByAppendingPathExtension:@"json"]
                                          atlasName:[name stringByAppendingPathExtension:@"atlas"]
                                              scale:scale];
}

- (void) didMoveToView:(SKView *)view
{
    if( !self.contentCreated) {
        [self createSceneContents];
        self.contentCreated = YES;
    }
}

- (void)createSceneContents
{
    self.backgroundColor = [SKColor blueColor];
    self.scaleMode = SKSceneScaleModeAspectFit;
    [self addChild: [self signatureLabelNode]];
    
    self.skeleton = [self loadSkeletonName:self.skeletonName scale:self.scaleSkeleton];
    if ( self.skeleton ) {
        [self addChild:[self nodeWithSkeleton:self.skeleton animationName:self.animationName]];
    }
}


+ (SKAction *) skactionWithSpineSequence:(SpineSequence *) sequence forNode:(SKNode *) node
{
    SKAction *action = nil;
    if ( [sequence.type isEqualToString:kSpineSequenceTypeBonesTranslate]) {
        CGPoint point = node.position;
        point.x += ((SpineSequenceBone *)sequence).translate.x;
        point.y += ((SpineSequenceBone *)sequence).translate.y;
        
        action = [SKAction moveTo:point duration:sequence.duration];
    } else if ( [sequence.type isEqualToString:kSpineSequenceTypeBonesRotate]) {
        CGFloat radians = node.zRotation;
        radians += ((SpineSequenceBone *)sequence).angle * M_PI / 180;
        action = [SKAction rotateToAngle:radians duration:sequence.duration shortestUnitArc:YES];
    } else if ( [sequence.type isEqualToString:kSpineSequenceTypeBonesScale]) {
        CGPoint scale = CGPointMake(node.xScale, node.yScale);
        scale.x *= ((SpineSequenceBone *)sequence).scale.x;
        scale.y *= ((SpineSequenceBone *)sequence).scale.y;
        action = [SKAction scaleXTo:scale.x y:scale.y duration:sequence.duration];
    } else {
        NSLog(@"Unsupported sequence type:%@", sequence.type);
        action = [SKAction waitForDuration:sequence.duration];
    }
    
    return action;
}

+ (SKAction *) skactionsWithSpineSequences:(NSArray *) sequences sequenceType:(NSString *) sequenceType forNode:(SKNode *) node
{
    NSMutableArray *actions = [NSMutableArray array];
    
    SpineSequence *lastSequence = sequences[0];
    lastSequence.duration = lastSequence.time;
    [actions addObject:[SKAction waitForDuration:lastSequence.duration]];
    
    SpineSequence *sequence = nil;
    for( int i = 1; i < sequences.count; i++ ) {
        sequence = sequences[i];
        sequence.duration = sequence.time - lastSequence.time;
        SKAction *action = [self skactionWithSpineSequence:sequence forNode:node];
        [actions addObject:action];
        
        // Apply curve data in the last sequence
        if (lastSequence.curve == SpineSequenceCurveBezier ) {
            action.timingMode = SKActionTimingEaseInEaseOut;
        } else {
            action.timingMode = SKActionTimingLinear;
        }
        
        lastSequence = sequence;
    }
    
    //[actions enumerateObjectsUsingBlock:^(SKAction *action, NSUInteger idx, BOOL *stop) {
    //    NSLog(@"action[%d]: duration=%2.2f", idx, action.duration);
    //}];
    return [SKAction sequence:actions];

}

- (void) applyAnimation:(SpineAnimation *) animation toNode:(SKNode *) node forBone:(SpineBone *) bone
{
    SpineTimeline *boneTimeline = [animation timelineForType:@"bones" forPart:bone.name];
    NSMutableArray *actions = [NSMutableArray array];
    NSArray *sequenceTypes = [boneTimeline types];
    for( NSString *sequenceType in sequenceTypes) {
        NSLog(@"sequences type:%@", sequenceType);
        
        NSArray *sequences = [boneTimeline sequencesForType:sequenceType];
        SKAction *action = [[self class] skactionsWithSpineSequences:sequences sequenceType:sequenceType forNode:node]; // type, params, duration
        [actions addObject:action];
    }
    if ( actions.count > 0) {
        // Synchronize the whole duration of the part animation
        [actions addObject:[SKAction waitForDuration:animation.duration]];
        SKAction *group = [SKAction group:actions];
        NSLog(@"Action duration:%2.2f %@", group.duration, group);
        [node runAction: [SKAction repeatActionForever:group]];
    }
}

+ (void) applyGeometry:(SpineGeometry) geometry toNode:(SKNode *) node
{
    node.position = geometry.origin;
    node.xScale = geometry.scale.x;
    node.yScale = geometry.scale.y;
    CGFloat radians = (CGFloat)(geometry.rotation * M_PI / 180);
    node.zRotation = radians;
}

- (SKNode *) buildNodeWithBone:(SpineBone *) bone
{
    SKNode *node = [[SKNode alloc] init];
//    [[SKSpriteNode alloc] initWithColor:[SKColor redColor] size:CGSizeMake(16,16)];
    [[self class] applyGeometry:bone.geometry toNode:node];
    node.name = bone.name;
    
    if ( self.buildDebuggingNodes ) {
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

- (void) buildChildNodesForBone:(SpineBone *) bone parentNode:(SKNode *) parentNode
                      animation:(SpineAnimation *) animation
{
    
    [bone.children enumerateObjectsUsingBlock:^(SpineBone *child, NSUInteger idx, BOOL *stop) {
        SKNode *node = [self buildNodeWithBone:child];
        if ( animation ) [self applyAnimation:animation toNode:node forBone:child];
        [parentNode addChild:node];
        if ( child.drawOrderIndex != NSNotFound && bone.drawOrderIndex != NSNotFound) {
            node.zPosition = ((int) child.drawOrderIndex - (int)bone.drawOrderIndex);
            NSLog(@"%@: zPosition=%2.2f drawOrderIndex:%d", child.name, node.zPosition, child.drawOrderIndex);
        }
        
        self.mapBoneToNode[child.name] = node;
        [self buildChildNodesForBone:child parentNode:node animation:animation];
    }];
}

- (SKNode *) nodeWithSkeleton:(SpineSkeleton *) skeleton animationName:(NSString *) animationName
{
    
    CGPoint center = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame)/2);
    SKNode *root = [SKNode node];
    root.position = center;
    root.name = @"root";
    if ( self.buildDebuggingNodes ) {
        SKSpriteNode *boneAnchor = [[SKSpriteNode alloc] initWithColor:[SKColor redColor] size:CGSizeMake(2,2)];
        [root addChild:boneAnchor];
    }
    
    if ( animationName == nil)
        animationName = [skeleton.animations[0] name];
    
    SpineAnimation *animation = [skeleton animationWithName:animationName];
    if ( animation == nil ) {
        NSLog(@"Animation not found for name:%@, falling back to default", animationName);
        animation = skeleton.animations[0];
        animationName = [skeleton.animations[0] name];
    }
    NSLog(@"Animation:%@", animationName);
    
    SpineBone *bone = [skeleton boneWithName:@"root"];
    if (bone) {
        // update root position
        center.x += bone.geometry.origin.x;
        center.y += bone.geometry.origin.y;
        root.position = center;
        
        // build children nodes
        [self.mapBoneToNode removeAllObjects];
        self.mapBoneToNode[@"root"] = root;
        [self buildChildNodesForBone:bone parentNode:root animation:animation];
    }
    
    // Attachments to Slots
    [[skeleton slots] enumerateObjectsUsingBlock:^(SpineSlot *slot, NSUInteger idx, BOOL *stop) {
        if ( slot.attachment ) {
            
            SKNode *node = self.mapBoneToNode[slot.bone.name];
            if ( node ) {
                NSLog(@"\nSlot:%@ bone:%@ attachment:%@ node:%@ %@", slot.name, slot.bone.name, slot.attachment.name, node.name,
                      NSStringFromCGRect(slot.attachment.rectInAtlas));
                
                
                NSString *atlasName = (__bridge NSString *) slot.attachment.rendererObject;
                SKTexture *textureAtlas = [[DZSpineTexturePool sharedPool] textureAtlasWithName:atlasName];
                
                // Reverse y axis
                CGRect rect = slot.attachment.rectInAtlas;
                rect.origin.y = 1 - rect.origin.y;
                
                SKTexture *texture = [SKTexture textureWithRect:rect inTexture:textureAtlas];
                SKSpriteNode *sprite = [SKSpriteNode spriteNodeWithTexture:texture];
                [[self class] applyGeometry:slot.attachment.geometry toNode:sprite];
                
                // Texture Scaling at Customg Loading
                sprite.xScale *= self.scaleSkeleton;
                sprite.yScale *= self.scaleSkeleton;
                
                // Texture Rotation at Custom Loading
                if ( slot.attachment.regionRotated) {
                    sprite.zRotation += -M_PI/2;
                }
                [node addChild:sprite];
            }
        }
    }];
    
    return root;
}

- (SKLabelNode *)signatureLabelNode
{
    SKLabelNode *helloNode = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
    helloNode.text = @"Spine-SpriteKit Demo";
    helloNode.fontSize = 26;
    helloNode.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame)/2);
    
    helloNode.name = @"signatureLabel";
    return helloNode;
}

@end

void * _spine_adapt_createTexture (const char* path, int *pwidth, int *pheight)
{
    printf("%s[%d]: path='%s'\n", __FUNCTION__, __LINE__, path);
    NSString *name = @(path);
    SKTexture *texture = [[DZSpineTexturePool sharedPool] textureAtlasWithName:name];
    *pwidth = texture.size.width;
    *pheight = texture.size.height;
    return (__bridge void *)name;
}

void _spine_adapt_disposeTexture( void * rendobj )
{
    // Keep the texture atlas in the pool
    /*
    if ( rendobj ) {
        NSString *name = (__bridge NSString *) rendobj;
        [[DZSpineTexturePool sharedPool] unloadTextAtlasWithName:name];
    }
     */
}