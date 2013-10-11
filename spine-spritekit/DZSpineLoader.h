//
//  DZSpineLoader.h
//  PZTool
//
//  Created by Simon Kim on 13. 10. 9..
//  Copyright (c) 2013 DZPub.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SpineSkeleton.h"

@interface DZSpineLoader : NSObject

+ (SpineSkeleton *) skeletonWithName:(NSString *) name atlasName:(NSString *) atlasName scale:(CGFloat) scale animationName:(NSString *) animationName;

@end
