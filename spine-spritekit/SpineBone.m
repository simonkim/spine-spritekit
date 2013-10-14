//
//  SpineBone.m
//  PZTool
//
//  Created by Simon Kim on 13. 10. 9..
//  Copyright (c) 2013 DZPub.com. All rights reserved.
//

#import "SpineBone.h"

@interface SpineBone()
@property (nonatomic, readonly) NSMutableArray *mchildren;
@end

@implementation SpineBone
@synthesize mchildren = _mchildren;

-(id) init
{
    self = [super init];
    if ( self ) {
        self.drawOrderIndex = NSNotFound;
    }
    return self;
}

#pragma mark - Properties
- (NSArray *) children
{
    return [self.mchildren copy];
}

- (NSMutableArray *) mchildren
{
    if ( _mchildren == nil ) {
        _mchildren = [NSMutableArray array];
    }
    return _mchildren;
}

#pragma mark - API

+ (id) boneWithCBone:(spBone *) bone
{
    id result = [[[self class] alloc] init];
    [result setName:@(bone->data->name)];
    /* 
     take bone's pose geometry instead of time 0 key frame update so the second animation can start from pose
     */
    [result setGeometry:SpineGeometryMake(bone->data->x, bone->data->y, bone->data->scaleX, bone->data->scaleY, bone->data->rotation)];
    [result setWorldGeometry:SpineGeometryMake(bone->worldX, bone->worldY, bone->worldScaleX, bone->worldScaleY, bone->worldRotation)];
    [(SpineBone *)result setLength:(CGFloat)bone->data->length];
    return result;
}

- (NSString *) description
{
    return [NSString stringWithFormat:@"%@ {\n- name:%@\n- geometry:%@\n- world:%@}",
            NSStringFromClass([self class]),
            self.name,
            NSStringFromSpineGeometry(self.geometry),
            NSStringFromSpineGeometry(self.worldGeometry)
            ];
}

- (void) addChild:(SpineBone *) child
{
    [self.mchildren addObject:child];
}

@end
