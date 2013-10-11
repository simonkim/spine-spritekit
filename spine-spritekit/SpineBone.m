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
    [result setGeometry:SpineGeometryMake(bone->x, bone->y, bone->scaleX, bone->scaleY, bone->rotation)];
    [result setWorldGeometry:SpineGeometryMake(bone->worldX, bone->worldY, bone->worldScaleX, bone->worldScaleY, bone->worldRotation)];
    [(SpineBone *)result setLength:(CGFloat)bone->data->length];
    return result;
}

- (NSString *) description
{
    return [NSString stringWithFormat:@"%@ {name:%@ geometry:%@ world:%@}",
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
