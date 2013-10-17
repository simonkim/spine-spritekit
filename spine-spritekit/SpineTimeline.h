//
//  SpineTimeline.h
//  PZTool
//
//  Created by Simon Kim on 13. 10. 9..
//  Copyright (c) 2013 DZPub.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SpineTimeline : NSObject <NSCopying>
@property (nonatomic, copy, readonly) NSArray *types;

+ (id) timeline;
- (void) setSequences:(NSArray *) sequences forType:(NSString *) type;
- (NSArray *) sequencesForType:(NSString *) type;

#pragma mark - Unstable
- (id) timelineByAdding:(SpineTimeline *) timeline delay:(CGFloat) delay;
- (void) delayBy:(CGFloat) delay;
@end
