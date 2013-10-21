//
//  DZSpineScene.m
//  PZTool
//
//  Created by Simon Kim on 13. 10. 6..
//  Copyright (c) 2013 DZPub.com. All rights reserved.
//

#import "DZSpineScene.h"
#import "DZSpineLoader.h"
#import "DZSpineTexturePool.h"
#import "DZSpineSceneBuilder.h"

@interface DZSpineScene()
@property (nonatomic) BOOL contentCreated;
@property (nonatomic, strong) DZSpineSceneBuilder *builder;

@property (nonatomic, strong) NSString *skeletonName;
@property (nonatomic, strong) NSString *animationName;
@property (nonatomic) CGFloat scaleSkeleton;
@property (nonatomic) BOOL debugNodes;

@end

@implementation DZSpineScene
@synthesize rootNode = _rootNode;

- (id) initWithSize:(CGSize)size
{
    self = [super initWithSize:size];
    if ( self ) {
        self.scaleSkeleton = 1;
        self.debugNodes = NO;
        self.builder = nil;
        self.skeletonName = nil;
        self.animationName = nil;
    }
    return self;
}

- (id) initWithSize:(CGSize)size skeletonName:(NSString *) skeletonName animationName:(NSString *) animationName scale:(CGFloat) scale
{
    self = [self initWithSize:size];
    if ( self ) {
        self.scaleSkeleton = scale;
        self.skeletonName = skeletonName;
        self.animationName = animationName;
        self.debugNodes = YES;
        self.builder = [DZSpineSceneBuilder builder];
        self.builder.debug = self.debugNodes;
    }
    return self;
}

- (SKNode *) rootNode
{
    if ( _rootNode == nil ) {
        _rootNode = [SKNode node];
        CGPoint center = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame) /*/2 */);
        _rootNode.position = center;
        [self addChild:_rootNode];
    }
    return _rootNode;
}

#pragma mark - Overrides
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
    
    if ( self.skeletonName ) {
        SpineSkeleton *skeleton = [DZSpineSceneBuilder loadSkeletonName:self.skeletonName scale:self.scaleSkeleton];
        if ( skeleton ) {
            [self.rootNode addChild:[self.builder nodeWithSkeleton:skeleton animationName:self.animationName loop:YES]];
        }
    }
}

- (void) didEvaluateActions
{

}

#pragma mark -
- (void) setTextureName:(NSString *) textureName rect:(CGRect) rect forAttachmentName:(NSString *)attachmentName
{
    [self.builder setTextureName:textureName rect:rect forAttachmentName:attachmentName];
}

#pragma mark - Misc.
- (SKLabelNode *)signatureLabelNode
{
    SKLabelNode *helloNode = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
    helloNode.text = @"Spine-SpriteKit Demo";
    helloNode.fontSize = 26;
    helloNode.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame)/2);
    helloNode.fontColor = [UIColor darkGrayColor];
    
    helloNode.name = @"signatureLabel";
    return helloNode;
}

@end

