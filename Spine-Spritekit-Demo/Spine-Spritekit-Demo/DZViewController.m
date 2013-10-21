//
//  DZViewController.m
//  Spine-Spritekit-Demo
//
//  Created by Simon Kim on 13. 10. 11..
//  Copyright (c) 2013 DZPub.com. All rights reserved.
//

#import "DZViewController.h"
#import "DZSpineScene.h"
#import "DZSpineSceneDescription.h"
#import "DZSpineSceneBuilder.h"

@implementation DZViewController

+ (SKScene *) buildSpineboyWithSize:(CGSize) size
{
    // 1. Simple Example: An Animation for a Skeleton
    DZSpineScene * scene = [[DZSpineScene alloc] initWithSize:size
                                                 skeletonName:@"spineboy"
                                                animationName:@"walk"
                                                        scale:1];
    // adjust root position
    scene.rootNode.position = CGPointMake(size.width /2, size.height /3);
    scene.scaleMode = SKSceneScaleModeAspectFill;
    
    return scene;
}

+ (SKScene *) buildSpineboyLoopWithSize:(CGSize) size
{
    // 2. Series Animations for a Skeleton
    SKScene *scene = [[SKScene alloc] initWithSize:size];
    scene.scaleMode = SKSceneScaleModeAspectFill;
    scene.backgroundColor = [UIColor whiteColor];
    
    SpineSkeleton *skeleton = [DZSpineSceneBuilder loadSkeletonName:@"spineboy" scale:1];
    DZSpineSceneBuilder *builder = [DZSpineSceneBuilder builder];
    SKNode *node = [builder nodeWithSkeleton:skeleton animationNames:@[@"walk", @"jump", @"walk"] loop:YES];

    // place holder node for position adjustment
    SKNode *placeHolder = [SKNode node];
    placeHolder.position = CGPointMake(size.width /2, size.height /3);
    [placeHolder addChild:node];
    [scene addChild:placeHolder];
    
    return scene;
}

+ (SKScene *) buildGoblinWithSize:(CGSize) size
{
    
    // 3. Series Animations with Delays Between Animations and Skin
    SpineSkeleton *skeleton = [DZSpineSceneBuilder loadSkeletonName:@"goblins" scale:1];
    
    // skin: "goblin"
    spSkeleton_setSkinByName(skeleton.spineContext->skeleton, "goblin");
    spSkeleton_setSlotsToSetupPose(skeleton.spineContext->skeleton);
    
    DZSpineSceneDescription *sceneDesc = [DZSpineSceneDescription description];
    NSArray *tracks = @[
                        // goblin
                        @{ @"skeleton" : skeleton,
                           @"scale" : @(1),
                           @"position" : NSStringFromCGPoint(CGPointMake(0, -200)),
                           @"animations" : @[
                                   @{@"name" : @"walk"},
                                   @{@"delay" : @(1.5)},        // delay for 1.5s
                                   @{@"name" : @"walk"},
                                   @{@"name" : @"walk"},
                                   @{@"delayUntil" : @(5)},     // delay until 5s from the beginning
                                   ],
                           @"loop" : @(YES) }
                           ];
    
    
    [tracks enumerateObjectsUsingBlock:^(NSDictionary *track, NSUInteger idx, BOOL *stop) {
        [sceneDesc addTrackRaw: track];
    }];

    NSArray *nodes = [sceneDesc buildScene];
    
    SKNode *placeHolder = [SKNode node];
    placeHolder.position = CGPointMake(size.width /2, size.height /3);
    
    [nodes enumerateObjectsUsingBlock:^(SKNode *node, NSUInteger idx, BOOL *stop) {
        [placeHolder addChild:node];
    }];
    
    SKScene *scene = [[SKScene alloc] initWithSize:size];
    scene.scaleMode = SKSceneScaleModeAspectFill;
    scene.backgroundColor = [UIColor whiteColor];

    [scene addChild:placeHolder];
    return scene;
}


+ (SKScene *) buildComplexSceneWithSize:(CGSize) size
{
    // 4. Multi Skeletons Scene
    SpineSkeleton *goblin = [DZSpineSceneBuilder loadSkeletonName:@"goblins" scale:1];
    
    // skin: "goblingirl"
    spSkeleton_setSkinByName(goblin.spineContext->skeleton, "goblingirl");
    spSkeleton_setSlotsToSetupPose(goblin.spineContext->skeleton);
    
    DZSpineSceneDescription *sceneDesc = [DZSpineSceneDescription description];
    
    NSArray *tracks = @[
                        // spineboy
                        @{ @"skeleton" : @"spineboy",
                           @"scale" : @(1),
                           @"position" : NSStringFromCGPoint(CGPointMake(-80, -100)),
                           @"animations" : @[
                                            @{@"name" : @"walk"},
                                            @{@"name" : @"walk"},
                                            @{@"name" : @"jump"},
                                            @{@"name" : @"walk"},
                                            @{@"name" : @"jump"},
                                            @{@"delayUntil" : @(8)},
                                            @{@"name" : @"jump"},
                                            @{@"name" : @"walk"}],
                           @"loop" : @(YES),
                           @"wait" : @(YES) },

                        // goblin
                        @{ @"skeleton" : goblin,
                           @"scale" : @(0.8),
                           @"position" : NSStringFromCGPoint(CGPointMake(30, -200)),
                           @"animations" : @[
                                                @{@"name" : @"walk"},
                                                @{@"name" : @"walk"},
                                                @{@"name" : @"walk"},
                                              @{@"delayUntil" : @(8)},
                                              @{@"name" : @"walk"},
                                                @{@"name" : @"walk"},
                                              ],
                           @"loop" : @(YES),
                           @"wait" : @(YES) },];
    
    
    [tracks enumerateObjectsUsingBlock:^(NSDictionary *track, NSUInteger idx, BOOL *stop) {
        [sceneDesc addTrackRaw: track];
    }];
    
    NSArray *textures = @[@{ @"skeleton" : @"spineboy",
                             @"textureName" : @"goblinhead4spineboy",
                             @"attachment" : @"head"}];
    [textures enumerateObjectsUsingBlock:^(NSDictionary *texture, NSUInteger idx, BOOL *stop) {
        [sceneDesc addCustomTextureRaw: texture];
    }];
    
    
    NSArray *nodes = [sceneDesc buildScene];
    
    SKNode *placeHolder = [SKNode node];
    placeHolder.position = CGPointMake(size.width /2, size.height /2);
    
    // Give zPosition to each character so they don't mix sprites in draw orders
    CGFloat __block zPosition = 1000;
    [nodes enumerateObjectsUsingBlock:^(SKNode *node, NSUInteger idx, BOOL *stop) {
        node.zPosition = zPosition;
        [placeHolder addChild:node];
        zPosition += 100;
    }];
    
    SKScene *scene = [[SKScene alloc] initWithSize:size];
    scene.scaleMode = SKSceneScaleModeAspectFill;
    scene.backgroundColor = [UIColor whiteColor];
    
    [scene addChild:placeHolder];
    return scene;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Configure the view.
    SKView * skView = (SKView *)self.view;
    skView.showsFPS = YES;
    skView.showsNodeCount = YES;

    SKScene *scene = [[self class] buildSpineboyWithSize:skView.bounds.size];
    
    // Present the scene.
    [skView presentScene:scene];
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return UIInterfaceOrientationMaskAllButUpsideDown;
    } else {
        return UIInterfaceOrientationMaskAll;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - Actions

- (IBAction)actionSegment:(UISegmentedControl *)sender {
    SKView * skView = (SKView *)self.view;
    skView.paused = YES;
    switch (sender.selectedSegmentIndex) {
        case 0:
        {
            SKScene *scene = [[self class] buildSpineboyLoopWithSize:skView.bounds.size];
            
            // Present the scene.
            [skView presentScene:scene];
        }
            break;
            
        case 1:
        {
            SKScene *scene = [[self class] buildGoblinWithSize:skView.bounds.size];
            
            // Present the scene.
            [skView presentScene:scene];
        }
            break;
        case 2:
        {
            SKScene *scene = [[self class] buildComplexSceneWithSize:skView.bounds.size];
            
            // Present the scene.
            [skView presentScene:scene];
        }
            break;
    }
    skView.paused = NO;
    
}

@end
