//
//  DZSpineScene.h
//  PZTool
//
//  Created by Simon Kim on 13. 10. 6..
//  Copyright (c) 2013 DZPub.com. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface DZSpineScene : SKScene
@property (nonatomic, readonly) SKNode *rootNode;

- (id) initWithSize:(CGSize)size;
- (id) initWithSize:(CGSize)size skeletonName:(NSString *) skeletonName animationName:(NSString *) animationName scale:(CGFloat) scale;

/*
 * Override texture for the attachment specified by 'attachmentName'
 * @textureName: bundle image name that contains texture to be used for the slot as attachment
 * @rect: parameter to textureWithRect of -textureWithRect:inTexture: of SKTexture class
 * @attachmentName: name of attachment in .JSON file to override texture image
 
 * Can be called before or after presenting this scene to an SKView
 */
- (void) setTextureName:(NSString *) textureName rect:(CGRect) rect forAttachmentName:(NSString *) attachmentName;
@end
