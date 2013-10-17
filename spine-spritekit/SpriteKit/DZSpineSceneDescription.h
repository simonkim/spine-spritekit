//
//  DZSpineSceneDescription.h
//  PZTool
//
//  Created by Simon Kim on 13. 10. 14..
//  Copyright (c) 2013년 DZPub.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DZSpineSceneDescription : NSObject

- (void) addTrackRaw:(NSDictionary *) raw;
- (void) addCustomTextureRaw:(NSDictionary *) raw;
- (NSArray *) buildScene;
+ (id) description;
@end
