//
//  SpineTimeline.m
//  PZTool
//
//  Created by Simon Kim on 13. 10. 9..
//  Copyright (c) 2013 DZPub.com. All rights reserved.
//

#import "SpineTimeline.h"
#import "SpineSequence.h"

@interface SpineTimeline()
@property (nonatomic, readonly) NSMutableDictionary *sequencesMap;
@end

@implementation SpineTimeline
@synthesize sequencesMap = _sequencesMap;

- (id)copyWithZone:(NSZone *)zone
{
    SpineTimeline *copy = [[[self class] allocWithZone:zone] init];
    
    for( NSString *type in self.types) {
        NSMutableArray *sequences = [NSMutableArray arrayWithArray:[self sequencesForType:type]];
        for( int i = 0; i < sequences.count; i++) {
            sequences[i] = [sequences[i] copy];
        }
        [copy setSequences:sequences forType:type];
    }
    
    return copy;
}

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

#pragma mark - Unstable

- (id) timelineByAdding:(SpineTimeline *) src delay:(CGFloat) delay
{
    SpineTimeline *dst = [self copy];
    NSMutableSet *types = [NSMutableSet setWithArray:src.types];
    [types addObjectsFromArray:dst.types];
    
    for( NSString *type in types) {
        NSMutableArray *sequences = [NSMutableArray arrayWithArray:[src sequencesForType:type]];
        for( int i = 0; i < sequences.count; i++) {
            SpineSequence *sequence = [sequences[i] copy];
            sequence.time += delay;
            sequences[i] = sequence;
        }
        // Set designated pose so animation can start from the beginning
        SpineSequence *pose = [SpineSequence poseSequenceWithType:type time:delay];
        if ( pose ) {
            [sequences insertObject:pose atIndex:0];
        }
        // Dummy wait to hold execution of the first sequence
        [sequences insertObject:[SpineSequence dummySequenceWithTime:delay] atIndex:0];

        NSArray *dstSequences = [dst sequencesForType:type];
        if ( dstSequences ) {
            NSMutableArray *merge = [NSMutableArray arrayWithArray:dstSequences];
            [merge addObjectsFromArray:sequences];
            sequences = merge;
        }
        [dst setSequences:[sequences copy] forType:type];
    }
    return dst;
}

- (void) delayBy:(CGFloat) delay
{
    for( NSString *type in self.types) {
        NSArray *sequences = [NSArray arrayWithArray:[self sequencesForType:type]];
        for( int i = 0; i < sequences.count; i++) {
            SpineSequence *sequence = sequences[i];
            sequence.time += delay;
        }
        NSMutableArray *seqs = [NSMutableArray array];
        // Dummy wait to hold execution of the first sequence
        [seqs addObject:[SpineSequence dummySequenceWithTime:delay]];
        // Set designated pose so animation can start from the beginning
        SpineSequence *pose = [SpineSequence poseSequenceWithType:type time:delay];
        if ( pose ) {
            [seqs addObject:pose];
        }
        
        [seqs addObjectsFromArray:sequences];
        [self setSequences:[seqs copy] forType:type];

    }
}
@end
