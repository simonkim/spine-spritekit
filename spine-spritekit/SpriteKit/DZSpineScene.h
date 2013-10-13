//
//  DZSpineScene.h
//  PZTool
//
//  Created by Simon Kim on 13. 10. 6..
//  Copyright (c) 2013 DZPub.com. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface DZSpineScene : SKScene

- (id) initWithSize:(CGSize)size skeletonName:(NSString *) skeletonName animationName:(NSString *) animationName scale:(CGFloat) scale;

/*
 * Override texture attachment for the slot specified by 'slotName'
 * @textureName: bundle image name that contains texture to be used for the slot as attachment
 * @rect: parameter to textureWithRect of -textureWithRect:inTexture: of SKTexture class
 * 
 * Can be called before or after presenting this scene to an SKView
 */
- (void) setTextureName:(NSString *) textureName rect:(CGRect) rect toSlot:(NSString *) slotName;
@end
