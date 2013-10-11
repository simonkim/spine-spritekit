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
@end
