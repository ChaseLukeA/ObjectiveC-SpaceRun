//
//  LCStarfield.m
//  LP4SpaceRun_lchase1
//
//  Created by Luke Chase on 4/27/15.
//  Copyright (c) 2015 Chase.Luke.A. All rights reserved.
//

#import "LCStarfield.h"


@implementation LCStarfield


- (instancetype)init {
    
    if (self = [super init]) {
        
        __weak LCStarfield *weakSelf = self;
        
        SKAction *update = [SKAction runBlock:^{
    
            if (arc4random_uniform(10) < 3) {
                [weakSelf launchStar];
            }
            
            if (arc4random_uniform(1000) < 1) {
                [weakSelf launchPlanet];
            }
        
        }];
        
        
        SKAction *delay = [SKAction waitForDuration:0.01];
        SKAction *updateLoop = [SKAction sequence:@[delay, update]];
        
        [self runAction:[SKAction repeatActionForever:updateLoop]];
        
    }
    
    return self;
    
}



- (void)launchStar {
    
    CGFloat randX = arc4random_uniform(self.scene.size.width);
    CGFloat maxY = self.scene.size.height;
    CGPoint randomStart = CGPointMake(randX, maxY);
    
    SKSpriteNode *star = [SKSpriteNode spriteNodeWithImageNamed:@"shootingstar"];
    star.size = CGSizeMake(2, 10);
    star.alpha = 0.1 + (arc4random_uniform(10) / 10.0f);
    star.position = randomStart;
    star.zPosition = 0;
    
    CGFloat destY = 0 - self.scene.size.height - star.size.height;
    CGFloat duration = star.alpha = 0.1 + (arc4random_uniform(10) / 10.0f);
    
    SKAction *move = [SKAction moveByX:0 y:destY duration:duration];
    SKAction *remove = [SKAction removeFromParent];
    
    [star runAction:[SKAction sequence:@[move, remove]]];
    
    [self addChild:star];
    
}



- (void)launchPlanet {
    
    CGFloat randX = arc4random_uniform(self.scene.size.width);
    CGFloat maxY = self.scene.size.height;
    CGPoint randomStart = CGPointMake(randX, maxY);
    
    SKSpriteNode *planet;
    CGFloat planetTexture = arc4random_uniform(100);
    
    if (planetTexture > 75) {
        planet = [SKSpriteNode spriteNodeWithImageNamed:@"planet1"];
    } else if (planetTexture > 50) {
        planet = [SKSpriteNode spriteNodeWithImageNamed:@"planet2"];
    } else if (planetTexture > 25) {
        planet = [SKSpriteNode spriteNodeWithImageNamed:@"planet3"];
    } else {
        planet = [SKSpriteNode spriteNodeWithImageNamed:@"planet4"];
    }
    
    CGFloat planetSize = arc4random_uniform(150) + 25;
    planet.size = CGSizeMake(planetSize, planetSize);
    planet.alpha = 0.1 + (arc4random_uniform(10) / 10.0f);
    planet.position = randomStart;
    planet.zPosition = 1;
    
    CGFloat destY = 0 - self.scene.size.height - planet.size.height;
    CGFloat duration = planet.alpha = 0.1 + (arc4random_uniform(500) / 10.0f);
    
    SKAction *move = [SKAction moveByX:0 y:destY duration:duration];
    SKAction *remove = [SKAction removeFromParent];
    
    [planet runAction:[SKAction sequence:@[move, remove]]];
    
    [self addChild:planet];
    
}


@end