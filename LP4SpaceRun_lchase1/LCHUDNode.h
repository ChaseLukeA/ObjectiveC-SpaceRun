//
//  LCHUDNode.h
//  LP4SpaceRun_lchase1
//
//  Created by Luke Chase on 4/29/15.
//  Copyright (c) 2015 Chase.Luke.A. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>


@interface LCHUDNode : SKNode


@property (nonatomic) NSInteger score;


-(void)layoutForScene;

-(void)addPoints:(NSInteger)points;

-(void)updateHealth:(CGFloat)shipHealth;

-(void)powerupTimer:(NSTimeInterval)time;


@end
