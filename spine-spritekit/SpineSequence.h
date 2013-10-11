//
//  SpineSequence.h
//  PZTool
//
//  Created by Simon Kim on 13. 10. 9..
//  Copyright (c) 2013년 DZPub.com. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    SpineSequenceCurveLinear,
    SpineSequenceCurveStepped,
    SpineSequenceCurveBezier
} SpineSequenceCurve;

extern NSString *kSpineSequenceTypeBonesTranslate;
extern NSString *kSpineSequenceTypeBonesRotate;
extern NSString *kSpineSequenceTypeBonesScale;
extern NSString *kSpineSequenceTypeSlotsAtachment;
extern NSString *kSpineSequenceTypeSlotsColor;

@interface SpineSequence : NSObject
@property (nonatomic, strong) NSString *type;   // translate, rotate, scale, slot, event, draworder
@property (nonatomic) NSTimeInterval time;
@property (nonatomic) NSTimeInterval duration;
// curve: linear, stepped, cx1, cx2, cy1, cy2
@property (nonatomic) SpineSequenceCurve curve;
@property (nonatomic) CGPoint bezier1;
@property (nonatomic) CGPoint bezier2;

+ (id) sequenceWithType:(NSString *) type dictionary:(NSDictionary *) dictionary scale:(CGFloat) scale;
@end

@interface SpineSequenceBone : SpineSequence
@property (nonatomic) CGPoint translate;
@property (nonatomic) CGPoint scale;
@property (nonatomic) CGFloat angle;
@end

@interface SpineSequenceSlot : SpineSequence
// curve: linear, stepped, cx1, cx2, cy1, cy2
@property (nonatomic, strong) NSString *attachment;
@property (nonatomic, strong) UIColor *color;
@end
