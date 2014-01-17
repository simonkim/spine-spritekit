//
//  SpineSkeleton.m
//  PZTool
//
//  Created by Simon Kim on 13. 10. 9..
//  Copyright (c) 2013 DZPub.com. All rights reserved.
//

#import "SpineSkeleton.h"
#import "DZSpineLoader.h"

@interface SpineSkeleton()
@property (nonatomic, readonly) NSMutableArray *mslots;
@property (nonatomic, readonly) NSMutableArray *mbones;
@property (nonatomic, readonly) NSMutableDictionary *bonesDictionary;
@property (nonatomic, readonly) NSMutableArray *manimations;
@property (nonatomic, readonly) NSMutableDictionary *animationMap;
@property (nonatomic) CGFloat scale;
@property (nonatomic) struct spinecontext *spineContext;
@property (nonatomic) BOOL ownsSpineContext;

@end

@implementation SpineSkeleton
@synthesize mslots = _mslots;
@synthesize mbones = _mbones;
@synthesize bonesDictionary = _bonesDictionary;
@synthesize manimations = _manimations;
@synthesize animationMap = _animationMap;
@synthesize animationNames = _animationNames;

#pragma makr - Properties
- (NSArray *) slots
{
    return [self.mslots copy];
}

- (NSArray *) bones
{
    return [self.mbones copy];
}

- (NSArray *) animations
{
    return [self.manimations copy];
}

- (NSArray *) animationNames
{
    if ( _animationNames == nil ) {
        NSMutableArray *names = [NSMutableArray array];
        [self.manimations enumerateObjectsUsingBlock:^(SpineAnimation *animation, NSUInteger idx, BOOL *stop) {
            [names addObject:animation.name];
        }];
        _animationNames = [names copy];
    }
    return _animationNames;
}

- (NSMutableArray *) mslots
{
    if ( _mslots == nil ) {
        _mslots = [NSMutableArray array];
    }
    return _mslots;
}


- (NSMutableArray *) mbones
{
    if ( _mbones == nil ) {
        _mbones = [NSMutableArray array];
    }
    return _mbones;
}

- (NSMutableDictionary *) bonesDictionary
{
    if ( _bonesDictionary == nil ) {
        _bonesDictionary = [NSMutableDictionary dictionary];
    }
    return _bonesDictionary;
}

- (NSMutableArray *) manimations
{
    if ( _manimations == nil ) {
        _manimations = [NSMutableArray array];
    }
    return _manimations;
}

- (NSMutableDictionary *) animationMap
{
    if ( _animationMap == nil ) {
        _animationMap = [NSMutableDictionary dictionary];
    }
    return _animationMap;
}

#pragma mark - API
- (void) addSlot:(SpineSlot *) slot
{
    [self.mslots addObject:slot];
}

- (void) addBone:(SpineBone *) bone
{
    if ( self.bonesDictionary[bone.name] == nil) {
        [self.mbones addObject:bone];
        self.bonesDictionary[bone.name] = bone;
    }
}

- (SpineBone *) boneWithName:(NSString *) name
{
    return self.bonesDictionary[name];
}

- (void) addAnimation:(SpineAnimation *) animation
{
    if ( self.animationMap[animation.name] == nil) {
        [self.manimations addObject:animation];
        self.animationMap[animation.name] = animation;
        
        // trigger enumerate again next time animationNames property access
        _animationNames = nil;
    }
}

- (SpineAnimation *) animationWithName:(NSString *) name
{
    return self.animationMap[name];
}

- (void) setSpineContext:(struct spinecontext *)spineContext owns:(BOOL)owns
{
    if ( spineContext ) {
        [self unsetSpineContext];
        self.ownsSpineContext = owns;
        if ( owns ) {
            _spineContext = malloc(sizeof(struct spinecontext));
            memcpy(_spineContext, spineContext, sizeof(struct spinecontext));
        } else {
            _spineContext = spineContext;
        }
    } else {
        [self unsetSpineContext];
    }
}

- (void) setSpineContext:(struct spinecontext *)spineContext
{
    [self setSpineContext:spineContext owns:NO];
}

- (void) unsetSpineContext
{
    if ( self.ownsSpineContext && _spineContext ) {
        spine_dispose(_spineContext);
        free(_spineContext);
    }
    _spineContext = NULL;
    self.ownsSpineContext = NO;
}

+ (id) skeletonWithName:(NSString *) name atlasName:(NSString *) atlasName scale:(CGFloat) scale
{
    SpineSkeleton *skeleton = [DZSpineLoader skeletonWithName:name atlasName:atlasName scale:scale animationName:nil];
    if ( skeleton ) {
        skeleton.name = name;
        skeleton.scale = scale;
    }
    return skeleton;
}

- (void) dealloc
{
    [self unsetSpineContext];
}
@end
