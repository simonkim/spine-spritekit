//
//  SpineAnimation.h
//  PZTool
//
//  Created by Simon Kim on 13. 10. 9..
//  Copyright (c) 2013 DZPub.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "spine_adapt.h"
#import "SpineTimeline.h"

@interface SpineAnimation : NSObject <NSCopying>
@property (nonatomic, strong) NSString *name;
@property (nonatomic) NSTimeInterval duration;
@property (nonatomic, strong) NSArray *timelines;   // SpineTimeline

+ (id) animationWithCAnimation:(spAnimation *) animation;
+ (id) animationWithName:(NSString *) name duration:(NSTimeInterval) duration;

// type: bones, slots, ...
// part: head, tail,
- (void) setTimeline:(SpineTimeline *) timeline forType:(NSString *) type forPart:(NSString *) part;
- (SpineTimeline *) timelineForType:(NSString *) type forPart:(NSString *) part;

#pragma mark - Unstable
- (id) animationByAdding:(SpineAnimation *) animation delay:(CGFloat) delay;

@end
