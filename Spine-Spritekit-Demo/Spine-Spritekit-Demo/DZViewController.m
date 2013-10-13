//
//  DZViewController.m
//  Spine-Spritekit-Demo
//
//  Created by Simon Kim on 13. 10. 11..
//  Copyright (c) 2013 DZPub.com. All rights reserved.
//

#import "DZViewController.h"
#import "DZSpineScene.h"

@implementation DZViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Configure the view.
    SKView * skView = (SKView *)self.view;
    skView.showsFPS = YES;
    skView.showsNodeCount = YES;
    
    // Create and configure the scene.
    DZSpineScene * scene = [[DZSpineScene alloc] initWithSize:skView.bounds.size
                                             skeletonName:@"spineboy"
                                           animationName:@"walk"
                                                   scale:1];
    
    // Replace spinboy's head attachment with a bundle image: goblin's head for test
    [scene setTextureName:@"goblinhead4spineboy" rect:CGRectMake(0, 0, 1, 1) toSlot:@"head"];
    scene.scaleMode = SKSceneScaleModeAspectFill;
    
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
