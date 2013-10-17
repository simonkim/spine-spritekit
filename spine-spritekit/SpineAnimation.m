//
//  SpineAnimation.m
//  PZTool
//
//  Created by Simon Kim on 13. 10. 9..
//  Copyright (c) 2013 DZPub.com. All rights reserved.
//

#import "SpineAnimation.h"

@interface SpineAnimation()
@property (nonatomic, readonly) NSMutableDictionary *timelineMap;
@end

@implementation SpineAnimation
@synthesize timelineMap = _timelineMap;

#pragma mark - Properties

- (NSMutableDictionary *) timelineMap
{
    if ( _timelineMap == nil ) {
        _timelineMap = [NSMutableDictionary dictionary];
    }
    return _timelineMap;
}

#pragma mark - API
- (void) setTimeline:(SpineTimeline *) timeline forType:(NSString *) type forPart:(NSString *)part
{
    NSMutableDictionary *partTimelines = self.timelineMap[type];
    if ( partTimelines == nil ) {
        partTimelines = [NSMutableDictionary dictionary];
        self.timelineMap[type] = partTimelines;
    }
    if ( timeline ) {
        partTimelines[part] = timeline;
    } else {
        [partTimelines removeObjectForKey:part];
        if ( [partTimelines count] == 0 ) {
            self.timelineMap[type] = nil;
        }
    }
}

- (SpineTimeline *) timelineForType:(NSString *) type forPart:(NSString *)part
{
    return self.timelineMap[type][part];
}

+ (id) animationWithCAnimation:(spAnimation *) animation
{
    id result = [[[self class] alloc] init];
    [result setName:@(animation->name)];
    [result setDuration:animation->duration];
    
    NSLog(@"animation:%@ duration:%2.2f timelineCount:%d", [result name], animation->duration, animation->timelineCount);
    return result;
}

+ (id) animationWithName:(NSString *) name duration:(NSTimeInterval) duration
{
    id result = [[[self class] alloc] init];
    [result setName:name];
    [result setDuration:duration];
    return result;
}

- (NSString *) description
{
    return [NSString stringWithFormat:@"%@ {name:%@ duration:%2.2f}",
            NSStringFromClass([self class]),
            self.name, self.duration
            ];
}

#pragma mark - Unstable
- (id)copyWithZone:(NSZone *)zone
{
    SpineAnimation *copy = [[[self class] allocWithZone:zone] init];
    copy.name = self.name;
    copy.duration = self.duration;
    
    for( NSString *type in [self.timelineMap allKeys]) {
        NSMutableDictionary *partTimelines = self.timelineMap[type];
        for( NSString *part in [partTimelines allKeys]) {
            SpineTimeline *timeline = [[self timelineForType:type forPart:part] copy];
            [copy setTimeline:timeline forType:type forPart:part];
        }
    }
    
    return copy;
}

- (id) animationByAdding:(SpineAnimation *) src delay:(CGFloat) delay
{
    // copy self to dst
    SpineAnimation *dst = [self copy];
    
    for( NSString *type in [src.timelineMap allKeys]) {
        NSMutableDictionary *partTimelines = src.timelineMap[type];
        NSMutableSet *parts = [NSMutableSet setWithArray:[partTimelines allKeys]];
        [parts addObjectsFromArray:[dst.timelineMap[type] allKeys]];
        
        for( NSString *part in parts) {
            SpineTimeline *timeline = partTimelines[part];
            SpineTimeline *dstTimeline = [dst timelineForType:type forPart:part];
            if (dstTimeline) {
                timeline = [dstTimeline timelineByAdding:timeline delay:delay + dst.duration];
            } else {
                timeline = [timeline copy];
                [timeline delayBy:delay + dst.duration];
            }
            [dst setTimeline:timeline forType:type forPart:part];
        }
    }
    dst.duration += delay + src.duration;
    return dst;
}

@end
