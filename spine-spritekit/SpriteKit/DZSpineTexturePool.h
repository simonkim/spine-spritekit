//
//  DZSpineTexturePool.h
//  PZTool
//
//  Created by Simon Kim on 13. 10. 11..
//  Copyright (c) 2013 DZPub.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SpriteKit/SpriteKit.h>

@interface DZSpineTexturePool : NSObject
@property (nonatomic, copy, readonly) NSArray *names;

- (SKTexture *) textureAtlasWithName:(NSString *) name;
- (void) unloadTextAtlasWithName:(NSString *) name;
- (void) unloadAll;

+ (id) sharedPool;
@end
