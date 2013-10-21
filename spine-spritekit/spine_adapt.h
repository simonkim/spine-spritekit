//
//  spine_adapt.h
//  PZTool
//
//  Created by Simon Kim on 13. 10. 9..
//  Copyright (c) 2013 DZPub.com. All rights reserved.
//

#ifndef PZTool_spine_adapt_h
#define PZTool_spine_adapt_h

#include <spine/spine.h>
#include <spine/extension.h>

typedef void *(*spine_adapt_createtexture_t)(const char* path, int *pwidth, int *pheight);
typedef void (*spine_adapt_disposetexture_t)(void *rendobj);

struct spinecontext {
    spAtlas* atlas;
    spSkeletonJson* json;
    spSkeletonData *skeletonData;
    spSkeleton* skeleton;
    spAnimationState *state;
};

int spine_load(struct spinecontext *ctx, const char *skeletonname, const char *atlasname, float scale, const char *animationName);
int spine_dump_animation(struct spinecontext *ctx, const char *animationName);
int spine_dispose( struct spinecontext *ctx);
int spine_load_test(char *skeletonname, char *atlasname, float scale, char *animationName);
void spine_logUVS( float *uvs, int atlas_width, int atlas_height);
void spine_set_handler_createtexture(spine_adapt_createtexture_t handler);
void spine_set_handler_disposetexture(spine_adapt_disposetexture_t handler);
CGRect spine_uvs2rect(float *uvs, BOOL *protated);

#endif
