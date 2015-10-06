//
//  SKEmitterNode+LCExtensions.h
//  LP4SpaceRun_lchase1
//
//  Created by Luke Chase on 4/27/15.
//  Copyright (c) 2015 Chase.Luke.A. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>


@interface SKEmitterNode (LCExtensions)


+ (SKEmitterNode *)lc_nodeWithFile:(NSString *)fileName;

- (void)lc_dieOutInDuration:(NSTimeInterval)duration;


@end
