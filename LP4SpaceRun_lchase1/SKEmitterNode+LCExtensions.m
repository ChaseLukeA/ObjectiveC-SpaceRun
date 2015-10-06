//
//  SKEmitterNode+LCExtensions.m
//  LP4SpaceRun_lchase1
//
//  Created by Luke Chase on 4/27/15.
//  Copyright (c) 2015 Chase.Luke.A. All rights reserved.
//

#import "SKEmitterNode+LCExtensions.h"


@implementation SKEmitterNode (LCExtensions)


+ (SKEmitterNode *)lc_nodeWithFile:(NSString *)fileName {
    
    NSString *baseName = [fileName stringByDeletingPathExtension];
    NSString *extension = [fileName pathExtension];
    
    if ([extension length] == 0) {
        extension = @"sks";
    }
    
    NSString *path = [[NSBundle mainBundle] pathForResource:baseName ofType:extension];
    
    SKEmitterNode *node = (id)[NSKeyedUnarchiver unarchiveObjectWithFile:path];
    
    return node;
    
}



- (void)lc_dieOutInDuration:(NSTimeInterval)duration {
    
    SKAction *firstWait = [SKAction waitForDuration:duration];
    
    __weak SKEmitterNode *weakSelf = self;
    
    SKAction *stop = [SKAction runBlock:^{
        weakSelf.particleBirthRate = 0;
    }];
    SKAction *secondWait = [SKAction waitForDuration:self.particleLifetime];
    SKAction *remove = [SKAction removeFromParent];
    SKAction *dieOut = [SKAction sequence:@[firstWait, stop, secondWait, remove]];
    
    [self runAction:dieOut];
    
}


@end