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

@implementation SpineSequence

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

- (NSString *) description
{
    return [NSString stringWithFormat:@"%@ {type:%@ time:%2.2f duration:%2.2f curve:}",
            NSStringFromClass([self class]), self.type, self.time, self.duration
            ];
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

@end

@implementation SpineSequenceSlot

+ (id) sequenceWithType:(NSString *) type dictionary:(NSDictionary *) dictionary scale:(CGFloat)scale
{
    SpineSequenceSlot *sequence = nil;
    
    sequence = [[SpineSequenceSlot alloc] init];
    sequence.type = type;
    sequence.time = [dictionary[@"time"] floatValue];
    sequence.duration = 0;  // unknown
    
    if ( [type isEqualToString:kSpineSequenceTypeSlotsAtachment] ) {
        sequence.attachment = dictionary[@"name"];
    } else if( [type isEqualToString:kSpineSequenceTypeSlotsColor] ) {
        sequence.color = [UIColor redColor];
        NSLog(@"Warning: Color decoding not implemented: %@[%d]", @(__FILE__), __LINE__);
    }
     
    return sequence;
}

@end
