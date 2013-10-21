//
//  SpineSequence.m
//  PZTool
//
//  Created by Simon Kim on 13. 10. 9..
//  Copyright (c) 2013 DZPub.com. All rights reserved.
//

#import "SpineSequence.h"

NSString *kSpineSequenceTypeBonesTranslate = @"translate";
NSString *kSpineSequenceTypeBonesRotate = @"rotate";
NSString *kSpineSequenceTypeBonesScale = @"scale";
NSString *kSpineSequenceTypeSlotsAtachment = @"attachment";
NSString *kSpineSequenceTypeSlotsColor = @"color";
NSString *kSpineSequenceTypeSDummy = @"dummywait";

@implementation SpineSequence

- (id)copyWithZone:(NSZone *)zone
{
    id copy = [[[self class] allocWithZone:zone] init];
    [copy setType:self.type];
    [copy setTime:self.time];
    [copy setDuration:self.duration];
    [copy setCurve:self.curve];
    [copy setBezier1:self.bezier1];
    [copy setBezier2:self.bezier2];
    [copy setDummy:self.dummy];
    return copy;
}

+ (id) sequenceWithType:(NSString *) type dictionary:(NSDictionary *) dictionary scale:(CGFloat)scale
{
    SpineSequence *sequence = nil;
    if ( [type isEqualToString:kSpineSequenceTypeBonesTranslate]
        || [type isEqualToString:kSpineSequenceTypeBonesRotate]
        || [type isEqualToString:kSpineSequenceTypeBonesScale]
        ) {
        sequence = [SpineSequenceBone sequenceWithType:type dictionary:dictionary scale:scale];
    } else if ( [type isEqualToString:kSpineSequenceTypeSlotsAtachment]
               || [type isEqualToString:kSpineSequenceTypeSlotsColor]
               ) {
        sequence = [SpineSequenceSlot sequenceWithType:type dictionary:dictionary scale:scale];
    } else {
        NSLog(@"Warning: Unsupported sequence type:%@ %@[%d]", type, @(__FILE__), __LINE__);
    }
    
    return sequence;
}

+ (NSString *) curveName:(SpineSequenceCurve) curve
{
    NSString *name = @"unknown";
    switch (curve) {
        case SpineSequenceCurveBezier:
            name = @"bezier";
            break;
        case SpineSequenceCurveLinear:
            name = @"linear";
            break;
        case SpineSequenceCurveStepped:
            name = @"stepped";
            break;
        default:
            break;
    }
    return name;
}

- (NSString *) description
{
    return [NSString stringWithFormat:@"%@ {type:%@ time:%2.2f duration:%2.2f curve:%@}",
            NSStringFromClass([self class]), self.type, self.time, self.duration, [[self class] curveName:self.curve ]
            ];
}
#pragma mark - Unstable
+ (id) dummySequenceWithTime:(CGFloat) time
{
    id sequence = [[[self class] alloc] init];
    [sequence setType:kSpineSequenceTypeSDummy];
    [sequence setDummy:YES];
    [sequence setTime:time];
    return sequence;
}

+ (id) poseSequenceWithType:(NSString *) type time:(CGFloat) time
{
    id result = nil;
    if ( [type isEqualToString:kSpineSequenceTypeBonesTranslate]
        || [type isEqualToString:kSpineSequenceTypeBonesRotate]
        || [type isEqualToString:kSpineSequenceTypeBonesScale]
        ) {
        result = [SpineSequenceBone poseSequenceWithType:type time:time];
    }
    
    return result;
}

@end

@implementation SpineSequenceBone
+ (id) sequenceWithType:(NSString *) type dictionary:(NSDictionary *) dictionary scale:(CGFloat)scale
{
    SpineSequenceBone *sequence = nil;
    
    sequence = [[SpineSequenceBone alloc] init];
    sequence.type = type;
    sequence.time = [dictionary[@"time"] floatValue];
    sequence.duration = 0;  // unknown
    sequence.curve = SpineSequenceCurveLinear;
    
    id curve = dictionary[@"curve"];
    if ( [curve isKindOfClass:[NSString class]] && [curve isEqualToString:@"stepped"]) {
        sequence.curve = SpineSequenceCurveStepped;
    } else if ( [curve isKindOfClass:[NSArray class]] && [curve count] == 4) {
        NSArray *bezier = curve;
        sequence.bezier1 = CGPointMake([bezier[0] floatValue], [bezier[1] floatValue]);
        sequence.bezier2 = CGPointMake([bezier[2] floatValue], [bezier[3] floatValue]);
        sequence.curve = SpineSequenceCurveBezier;
    }
    if ( [type isEqualToString:kSpineSequenceTypeBonesTranslate] ) {
        sequence.translate = CGPointMake([dictionary[@"x"] floatValue] * scale, [dictionary[@"y"] floatValue] * scale);
    } else if ( [type isEqualToString:kSpineSequenceTypeBonesScale] ) {
        sequence.scale = CGPointMake([dictionary[@"x"] floatValue], [dictionary[@"y"] floatValue]);
    } else if ( [type isEqualToString:kSpineSequenceTypeBonesRotate] ) {
        sequence.angle = [dictionary[@"angle"] floatValue];
    }
    
    return sequence;
}

- (NSString *) description
{
    NSString *description = [super description];
    
    return [description stringByAppendingFormat:@"{translate:%@ scale:%@ angle:%2.2f}",
            NSStringFromCGPoint(self.translate),
            NSStringFromCGPoint(self.scale),
            self.angle
            ];
}

#pragma mark - Unstable
- (id)copyWithZone:(NSZone *)zone
{
    SpineSequenceBone *copy = [super copyWithZone:zone];
    [copy setTranslate:self.translate];
    [copy setAngle:self.angle];
    [copy setScale:self.scale];
    
    return copy;
}

+ (id) poseSequenceWithType:(NSString *) type time:(CGFloat) time
{
    SpineSequenceBone *result = [[[self class] alloc] init];
    result.type = type;
    result.time = time;
    result.duration = 0;  // unknown
    result.curve = SpineSequenceCurveLinear;
    result.translate = CGPointMake(0, 0);
    result.scale = CGPointMake(1, 1);
    result.angle = 0;
    return result;
}


@end

@implementation SpineSequenceSlot
- (id)copyWithZone:(NSZone *)zone
{
    SpineSequenceSlot *copy = [super copyWithZone:zone];
    [copy setAttachment:self.attachment];
    [copy setColor:self.color];
    return copy;
}

+ (id) sequenceWithType:(NSString *) type dictionary:(NSDictionary *) dictionary scale:(CGFloat)scale
{
    SpineSequenceSlot *sequence = nil;
    
    sequence = [[SpineSequenceSlot alloc] init];
    sequence.type = type;
    sequence.time = [dictionary[@"time"] floatValue];
    sequence.duration = 0;  // unknown
    
    if ( [type isEqualToString:kSpineSequenceTypeSlotsAtachment] ) {
        sequence.attachment = dictionary[@"name"];
        if ( [sequence.attachment isKindOfClass:[NSNull class]]) {
            sequence.attachment = nil;
        }
    } else if( [type isEqualToString:kSpineSequenceTypeSlotsColor] ) {
        sequence.color = [UIColor redColor];
        NSLog(@"Warning: Color decoding not implemented: %@[%d]", @(__FILE__), __LINE__);
    }
     
    return sequence;
}

- (NSString *) description
{
    NSString *description = [super description];
    
    return [description stringByAppendingFormat:@"{attachment:%@ color:%@}",
            self.attachment,
            self.color
            ];
}
@end
