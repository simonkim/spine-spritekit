//
//  DZSpineSceneTrack.h
//  PZTool
//
//  Created by Simon Kim on 13. 10. 14..
//  Copyright (c) 2013년 DZPub.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SpineSkeleton.h"

@interface DZSpineSceneTrack : NSObject
@property (nonatomic, strong) NSString *skeletonName;
@property (nonatomic, strong) SpineSkeleton *skeleton;
@property (nonatomic, strong) NSArray *animations;
@property (nonatomic) CGFloat duration;
@property (nonatomic) BOOL loop;
@property (nonatomic) BOOL wait;
@property (nonatomic) CGPoint position;

@end
