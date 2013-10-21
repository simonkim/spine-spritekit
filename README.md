spine-spritekit
===============

Unofficial iOS 7 SpriteKit Runtime for Spine 2D (http://esotericsoftware.com)

Official runtimes are here: http://esotericsoftware.com/spine-runtimes

I wrote a quick code for my own project that uses SpriteKit and Spine 2D at the same time. 
Though it does not fully support all the features of Spine 2D, it basically,
- Places Bones and Skot Attachments on SKScene (SpriteKit Scene object)
- Animates Bone Timelines using SKAction for translate, rotate, and scale sequences

Until the official release of SpriteKit Runtime from esoteric software, hope it's a quick starter for your projects if you are considering use of Spine and SpriteKit at the same time.

Feel free to fork and send pull requests!
# Updates
## Oct. 22nd, 2013 
- Attachment(Slots) Animation
- Allowed Access to spine-c structures per skeleton (SpineSkeleton’s spineContext property)
- Override texture for ‘attachment’ instead of ‘slot’

# Screenshots

![iPad](https://raw.github.com/simonkim/spine-spritekit/43396b75aa283d6cc7fe6a2bfc9e53a7f6f375ee/Screenshots/iPad.png)
![iPhone](https://raw.github.com/simonkim/spine-spritekit/43396b75aa283d6cc7fe6a2bfc9e53a7f6f375ee/Screenshots/iPhone.png)

# Building and running
<blockquote>Don't forget to init and update submodule for spine-runtimes, which is the offcial runtimes, once you've cloned this project</blockquote>

<pre>
$ git clone https://github.com/simonkim/spine-spritekit

$ git submodule init

$ git submodule update
</pre>

## Open the demo project from Xcode 5
- Located at Spine-Spritekit-Demo/Spine-Spritekit-Demo.xcodeproject
- Build and run

# How to use
The examples below assume that skeleton (.JSON), atlas (.atlas) and texture atlas image (.png) are included as bundle in the app. For example, the demo app contains the following files for spineboy and goblins skeletons

- spineboy.json
- spineboy.atlas
- spineboy.png
- goblins.json
- goblins.atlas
- goblins.png

Also, skeleton name arguments used in the examples are used to resolve the name of skeleton, and atlas files by appending extensions: .json, and .atlas

## Simple Example: An Animation for a Skeleton
<pre>
// Use DZSpineScene class to load skeleton JSON, atlas, and texture image files with scale parameter to build an SKScene object
    DZSpineScene * scene = [[DZSpineScene alloc] initWithSize:size
                                                 skeletonName:@"spineboy"
                                                animationName:@"walk"
                                                        scale:1];
// adjust root position
    scene.rootNode.position = CGPointMake(size.width /2, size.height /3);
    scene.scaleMode = SKSceneScaleModeAspectFill;
// Present the scene to an SKView object    
    SKView * skView = (SKView *)self.view;
    [skView presentScene:scene];
</pre>

## Series Animations for a Skeleton
<pre>
+ (SKScene *) buildSpineboyLoopWithSize:(CGSize) size
{
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
</pre>
## Series Animations with Delays Between Animations and Skin
<pre>
+ (SKScene *) buildGoblinWithSize:(CGSize) size
{
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
</pre>

## Multi Skeletons Scene
<pre>
+ (SKScene *) buildComplexSceneWithSize:(CGSize) size
{
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
</pre>
