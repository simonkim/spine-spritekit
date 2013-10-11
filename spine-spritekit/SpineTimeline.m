//
//  SpineTimeline.m
//  PZTool
//
//  Created by Simon Kim on 13. 10. 9..
//  Copyright (c) 2013년 DZPub.com. All rights reserved.
//

#import "SpineTimeline.h"
@interface SpineTimeline()
@property (nonatomic, readonly) NSMutableDictionary *sequencesMap;
@end

@implementation SpineTimeline
@synthesize sequencesMap = _sequencesMap;

#pragma mark - Properties
- (NSArray *) types
{
    return [self.sequencesMap allKeys];
}

- (NSMutableDictionary *) sequencesMap
{
    if ( _sequencesMap == nil ) {
        _sequencesMap = [NSMutableDictionary dictionary];
    }
    return _sequencesMap;
}

#pragma mark - API

+ (id) timeline
{
    return [[[self class] alloc] init];
}

- (void) setSequences:(NSArray *) sequences forType:(NSString *) type
{
    if ( sequences ) {
        self.sequencesMap[type] = sequences;
    } else {
        [self.sequencesMap removeObjectForKey:type];
    }
}

- (NSArray *) sequencesForType:(NSString *) type
{
    return self.sequencesMap[type];
}

- (NSString *) description {
    return [NSString stringWithFormat:@"%@ {%@}", NSStringFromClass([self class]), self.sequencesMap];
}
@end
