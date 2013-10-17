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

@implementation DZViewController

+ (SKScene *) buildSceneWithSize:(CGSize) size
{
    
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
                        @{ @"skeleton" : @"goblins",
                           @"scale" : @(1),
                           @"position" : NSStringFromCGPoint(CGPointMake(30, -200)),
                           @"animations" : @[
                                                @{@"name" : @"walk"},
                                                @{@"name" : @"walk"},
                                                @{@"name" : @"walk"},
                                              @{@"delayUntil" : @(8)},
                                              @{@"name" : @"walk"},
                                                @{@"name" : @"walk"},
                                              //@{@"delay" : @(1)},
                                              ],
                           @"loop" : @(YES),
                           @"wait" : @(YES) },];
    
    NSArray *textures = @[@{ @"skeleton" : @"spineboy",
                             @"textureName" : @"goblinhead4spineboy",
                             @"slot" : @"head"}];
    
    [tracks enumerateObjectsUsingBlock:^(NSDictionary *track, NSUInteger idx, BOOL *stop) {
        [sceneDesc addTrackRaw: track];
    }];
    [textures enumerateObjectsUsingBlock:^(NSDictionary *texture, NSUInteger idx, BOOL *stop) {
        [sceneDesc addCustomTextureRaw: texture];
    }];
    
    
    DZSpineScene *scene;
    scene = [[DZSpineScene alloc] initWithSize:size];
    
    NSArray *nodes = [sceneDesc buildScene];
    [nodes enumerateObjectsUsingBlock:^(SKNode *node, NSUInteger idx, BOOL *stop) {
        [scene.rootNode addChild:node];
    }];
    return scene;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Configure the view.
    SKView * skView = (SKView *)self.view;
    skView.showsFPS = YES;
    skView.showsNodeCount = YES;
/*
    // 1. Simple Example: Create and configure the scene.
    DZSpineScene * scene = [[DZSpineScene alloc] initWithSize:skView.bounds.size
                                             skeletonName:@"spineboy"
                                           animationName:@"walk"
                                                   scale:1];
    // Replace spinboy's head attachment with a bundle image: goblin's head for test
    [scene setTextureName:@"goblinhead4spineboy" rect:CGRectMake(0, 0, 1, 1) toSlot:@"head"];
    scene.scaleMode = SKSceneScaleModeAspectFill;
 
 */
    // 2. Multiple Skeletons
    SKScene *scene = [[self class] buildSceneWithSize:skView.bounds.size];
    
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

@end
