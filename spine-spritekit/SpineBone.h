//
//  SpineBone.h
//  PZTool
//
//  Created by Simon Kim on 13. 10. 9..
//  Copyright (c) 2013 DZPub.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SpineGeometry.h"
#import "spine_adapt.h"

@class SpineBone;

@interface SpineBone : NSObject
@property (nonatomic, strong) NSString *name;
@property (nonatomic) SpineGeometry geometry;
@property (nonatomic) SpineGeometry worldGeometry;
@property (nonatomic) CGFloat length;
@property (nonatomic, weak) SpineBone *parent;
@property (nonatomic) NSUInteger drawOrderIndex; // zPosition = self.drawOrderIndex - self.parent.drawOrderIndex;
@property (nonatomic, copy, readonly) NSArray *children;

+ (id) boneWithCBone:(spBone *) bone;
- (void) addChild:(SpineBone *) child;
@end
