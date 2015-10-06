//
//  GameScene.m
//  LP4SpaceRun_lchase1
//
//  Created by Luke Chase on 4/13/15.
//  Copyright (c) 2015 Chase.Luke.A. All rights reserved.
//

#import "GameScene.h"
#import "GameOverScene.h"
#import "LCHUDNode.h"
#import "LCStarfield.h"
#import "SKEmitterNode+LCExtensions.h"


@interface GameScene()

@property (nonatomic, weak) UITouch *shipTouch;
@property (nonatomic) NSTimeInterval lastUpdateTime;
@property (nonatomic) NSTimeInterval lastShotFiredTime;
@property (nonatomic) CGFloat shipFireRate;

@property (nonatomic) SKEmitterNode *shipThrust;
@property (nonatomic) CGFloat shipSpeed;
@property (nonatomic) CGFloat shipHealthRate;

@property (nonatomic) SKEmitterNode *shipShield;
@property (nonatomic, strong) SKEmitterNode *shipExplodeTemplate;
@property (nonatomic, strong) SKEmitterNode *obstacleExplodeTemplate;

@property (nonatomic, strong)SKAction *shootSound;
@property (nonatomic, strong)SKAction *shipExplodeSound;
@property (nonatomic, strong)SKAction *obstacleExplodeSound;
@property (nonatomic, strong)SKAction *countdownBeepSound;

@end


@implementation GameScene

-(id)initWithSize:(CGSize)size {
    
    if (self = [super initWithSize:size]) {
        
        self.backgroundColor = [SKColor blackColor];
        
        
        LCStarfield *starField = [LCStarfield node];
        
        [self addChild:starField];
        
        
        self.shipFireRate = 0.5;
        self.shipSpeed = 130;
        self.shipHealthRate = 2.0;
        
        
        NSString *name = @"Spaceship.png";
        SKSpriteNode *ship = [SKSpriteNode spriteNodeWithImageNamed:name];
        ship.position = CGPointMake(size.width/2, size.height/2);
        ship.zPosition = 5;
        ship.size = CGSizeMake(40, 40);
        ship.name = @"ship";
        
        [self addChild:ship];
        
        
        self.shipThrust = [SKEmitterNode lc_nodeWithFile:@"shipThrust.sks"];
        self.shipThrust.position = CGPointMake(0, -20);
        self.shipThrust.zPosition = 4;
        
        [ship addChild:self.shipThrust];
        
        
        self.shipShield = [SKEmitterNode lc_nodeWithFile:@"shield.sks"];
        self.shipShield.position = CGPointMake(0, 30);
        self.shipShield.zPosition = 4;
        
        [ship addChild:self.shipShield];
        

        self.shootSound = [SKAction playSoundFileNamed:@"laserShot.wav" waitForCompletion:NO];
        self.shipExplodeSound = [SKAction playSoundFileNamed:@"darkExplosion.wav" waitForCompletion:NO];
        self.obstacleExplodeSound = [SKAction playSoundFileNamed:@"explosion.wav" waitForCompletion:NO];
        self.countdownBeepSound = [SKAction playSoundFileNamed:@"beep.wav" waitForCompletion:NO];
        
        
        self.shipExplodeTemplate = [SKEmitterNode lc_nodeWithFile:@"shipExplode.sks"];
        self.obstacleExplodeTemplate = [SKEmitterNode lc_nodeWithFile:@"obstacleExplode.sks"];
        
        
        LCHUDNode *hudNode = [LCHUDNode node];
        hudNode.name = @"hud";
        hudNode.zPosition = 100;
        hudNode.position = CGPointMake(size.width/2, size.height/2);
        
        [self addChild:hudNode];
        
        
        [hudNode layoutForScene];
        
    }
    
        return self;
    
}



-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {

    self.shipTouch = [touches anyObject];
    
}



-(void)update:(CFTimeInterval)currentTime {

    if (self.lastUpdateTime == 0) {
        self.lastUpdateTime = currentTime;
    }
    
    NSTimeInterval timeDelta = currentTime - self.lastUpdateTime;
    

    if (self.shipTouch) {
        
        [self moveShipTowardPoint: [self.shipTouch locationInNode:self]
                      byTimeDelta: timeDelta];

        if (currentTime - self.lastShotFiredTime > self.shipFireRate) {
            
            [self shoot];
            
            self.lastShotFiredTime = currentTime;
            
        }
        
    }
    
    // release asteroids 1.5% of update
    if (arc4random_uniform(1000) <= 15) {
        [self dropThing];
        
    }
    
    [self checkCollisions];
    
    self.lastUpdateTime = currentTime;
    
}



-(void)moveShipTowardPoint:(CGPoint)point byTimeDelta:(NSTimeInterval)timeDelta {

    SKNode *ship = [self childNodeWithName:@"ship"];
    
    CGFloat distanceLeft = sqrt(pow(ship.position.x - point.x, 2) +
                                pow(ship.position.y - point.y, 2));
    

    if (distanceLeft > 4) {
        
        CGFloat distanceToTravel = timeDelta * self.shipSpeed;
        
        CGFloat angle = atan2(point.y - ship.position.y, point.x - ship.position.x);
        
        CGFloat yOffset = distanceToTravel * sin(angle);
        CGFloat xOffset = distanceToTravel * cos(angle);
        
        ship.position = CGPointMake(ship.position.x + xOffset, ship.position.y + yOffset);
        
    }
    
}



-(void)shoot {
    
    SKNode *ship = [self childNodeWithName:@"ship"];
    
    
    SKSpriteNode *photon = [SKSpriteNode spriteNodeWithImageNamed:@"photon"];
    photon.name = @"photon";  // so we can reference it later in the tree
    photon.position = CGPointMake(ship.position.x, ship.position.y -10);
    photon.zPosition = 4;
    
    [self addChild:photon];
    
    
    SKAction *fly = [SKAction moveByX:0
                                    y:self.size.height + photon.size.height
                             duration:0.5];
    SKAction *remove = [SKAction removeFromParent];
    SKAction *fireAndRemove = [SKAction sequence:@[fly, remove]];
    
    [photon runAction:fireAndRemove];
    
    
    [self runAction:self.shootSound];
    
}



-(void)dropThing {
    
    u_int32_t dice = arc4random_uniform(100);
    
    if (dice < 3) {
        [self dropHealth];
    } else if (dice < 8) {
        [self dropSpeedPowerup];
    } else if (dice < 13) {
        [self dropPhotonPowerup];
    } else if (dice < 28) {
        [self dropEnemyShip];
    } else {  // 72% => asteroid
        [self dropAsteroid];
    }
}



-(void)dropAsteroid {
    
    CGFloat sideSize = arc4random_uniform(30) + 15;
    CGFloat maxX = self.size.width;
    CGFloat quarterX = maxX / 4;
    CGFloat startX = arc4random_uniform(maxX + (quarterX * 2) - quarterX);
    CGFloat startY = self.size.height + sideSize;
    CGFloat endX = arc4random_uniform(maxX);
    CGFloat endY = 0 - sideSize;
    
    
    SKSpriteNode *asteroid = [SKSpriteNode spriteNodeWithImageNamed:@"asteroid"];
    asteroid.size = CGSizeMake(sideSize, sideSize);
    asteroid.position = CGPointMake(startX, startY);
    asteroid.zPosition = 4;
    asteroid.name = @"obstacle";
    
    [self addChild:asteroid];
    
    
    SKAction *move = [SKAction moveTo:CGPointMake(endX, endY)
                             duration:arc4random_uniform(4) + 3];
    SKAction *remove = [SKAction removeFromParent];
    SKAction *travelAndRemove = [SKAction sequence:@[move, remove]];
    SKAction *spin = [SKAction rotateByAngle:3
                                    duration:arc4random_uniform(2) + 1];
    SKAction *spinForever = [SKAction repeatActionForever:spin];
    SKAction *all = [SKAction group:@[spinForever, travelAndRemove]];
    
    [asteroid runAction:all];
    
}



-(void)dropEnemyShip {
    
    CGFloat sideSize = 30;
    CGFloat startX = arc4random_uniform(self.size.width - 40) + 20;
    CGFloat startY = self.size.height + sideSize;
    
    
    SKSpriteNode *enemy = [SKSpriteNode spriteNodeWithImageNamed:@"enemy"];
    enemy.size = CGSizeMake(sideSize, sideSize);
    enemy.position = CGPointMake(startX, startY);
    enemy.zPosition = 4;
    enemy.name = @"obstacle";
    
    [self addChild:enemy];
    
    
    CGPathRef shipPath = [self buildEnemyShipMovementPath];
    
    SKAction *followPath = [SKAction followPath:shipPath asOffset:YES orientToPath:YES duration:7];
    SKAction *remove = [SKAction removeFromParent];
    SKAction *all = [SKAction sequence:@[followPath, remove]];
    
    [enemy runAction:all];
    
}



-(CGPathRef)buildEnemyShipMovementPath {
    
    UIBezierPath* bezierPath = [UIBezierPath bezierPath];
    
    [bezierPath moveToPoint: CGPointMake(0.5, -0.5)];
    [bezierPath addCurveToPoint: CGPointMake(-2.5, -59.5)
                  controlPoint1: CGPointMake(0.5, -0.5)
                  controlPoint2: CGPointMake(4.55, -29.48)];
    [bezierPath addCurveToPoint: CGPointMake(-27.5, -154.5)
                  controlPoint1: CGPointMake(-9.55, -89.52)
                  controlPoint2: CGPointMake(-43.32, -115.43)];
    [bezierPath addCurveToPoint: CGPointMake(30.5, -243.5)
                  controlPoint1: CGPointMake(-11.68, -193.57)
                  controlPoint2: CGPointMake(17.28, -186.95)];
    [bezierPath addCurveToPoint: CGPointMake(-52.5, -379.5)
                  controlPoint1: CGPointMake(43.72, -300.05)
                  controlPoint2: CGPointMake(-47.71, -335.76)];
    [bezierPath addCurveToPoint: CGPointMake(54.5, -449.5)
                  controlPoint1: CGPointMake(-57.29, -423.24)
                  controlPoint2: CGPointMake(-8.14, -482.45)];
    [bezierPath addCurveToPoint: CGPointMake(-5.5, -348.5)
                  controlPoint1: CGPointMake(117.14, -416.55)
                  controlPoint2: CGPointMake(52.25, -308.62)];
    [bezierPath addCurveToPoint: CGPointMake(10.5, -494.5)
                  controlPoint1: CGPointMake(-63.25, -388.38)
                  controlPoint2: CGPointMake(-14.48, -457.43)];
    [bezierPath addCurveToPoint: CGPointMake(0.5, -559.5)
                  controlPoint1: CGPointMake(23.74, -514.16)
                  controlPoint2: CGPointMake(6.93, -537.57)];
    [bezierPath addCurveToPoint: CGPointMake(-2.5, -644.5)
                  controlPoint1: CGPointMake(-5.2, -578.93)
                  controlPoint2: CGPointMake(-2.5, -644.5)];
    
    return bezierPath.CGPath;
    
}



-(void)dropPhotonPowerup {
    
    CGFloat sideSize = 30;
    CGFloat startX = arc4random_uniform(self.size.width - 60) + 30;
    CGFloat startY = self.size.height + sideSize;
    CGFloat endY = 0 - sideSize;
    
    SKSpriteNode *photonPowerup = [SKSpriteNode spriteNodeWithImageNamed:@"rapidfire"];
    photonPowerup.name = @"photonPowerup";
    photonPowerup.size = CGSizeMake(sideSize, sideSize);
    photonPowerup.position = CGPointMake(startX, startY);
    photonPowerup.zPosition = 4;
    
    [self addChild:photonPowerup];
    
    
    SKAction *move = [SKAction moveTo:CGPointMake(startX, endY) duration:6];
    SKAction *spin = [SKAction rotateByAngle:-1 duration:1];
    SKAction *remove = [SKAction removeFromParent];
    SKAction *spinForever = [SKAction repeatActionForever:spin];
    SKAction *travelAndRemove = [SKAction sequence:@[move, remove]];
    SKAction *all = [SKAction group:@[spinForever, travelAndRemove]];
    
    [photonPowerup runAction:all];
    
}



-(void)dropSpeedPowerup {
    
    CGFloat sideSize = 30;
    CGFloat startX = arc4random_uniform(self.size.width - 60) + 30;
    CGFloat startY = self.size.height + sideSize;
    CGFloat endY = 0 - sideSize;
    
    SKSpriteNode *speedPowerup = [SKSpriteNode spriteNodeWithImageNamed:@"speedup"];
    speedPowerup.name = @"speedPowerup";
    speedPowerup.size = CGSizeMake(sideSize, sideSize);
    speedPowerup.position = CGPointMake(startX, startY);
    speedPowerup.zPosition = 4;
    
    [self addChild:speedPowerup];
    
    
    SKAction *move = [SKAction moveTo:CGPointMake(startX, endY) duration:4];
    SKAction *grow = [SKAction scaleTo:1.1 duration:0.25];
    SKAction *shrink = [SKAction scaleTo:0.9 duration:0.25];
    SKAction *pulse = [SKAction repeatActionForever:[SKAction sequence:@[grow, shrink]]];
    SKAction *off = [SKAction fadeAlphaTo:0.25 duration:0.125];
    SKAction *on = [SKAction fadeAlphaTo:1 duration:0.125];
    SKAction *flicker = [SKAction repeatActionForever:[SKAction sequence:@[off, on]]];
    SKAction *remove = [SKAction removeFromParent];
    SKAction *travelAndRemove = [SKAction sequence:@[move, remove]];
    SKAction *all = [SKAction group:@[pulse, flicker, travelAndRemove]];
    
    [speedPowerup runAction:all];
    
}



-(void)checkCollisions {
    
    SKNode *ship = [self childNodeWithName:@"ship"];
    
    
    [self enumerateChildNodesWithName:@"photonPowerup" usingBlock:^(SKNode *powerup, BOOL *stop) {
        
        if ([ship intersectsNode:powerup]) {
            [powerup removeFromParent];
            
            LCHUDNode *hud = (LCHUDNode *)[self childNodeWithName:@"hud"];
            [hud powerupTimer:5];
            self.shipFireRate = 0.1;
            
            SKAction *powerdown = [SKAction runBlock:^{
                self.shipFireRate = 0.5;
            }];
            SKAction *wait = [SKAction waitForDuration:5];
            SKAction *waitAndPowerdown = [SKAction sequence:@[wait, powerdown]];
            
            [ship removeActionForKey:@"waitAndPowerdown"];
            [ship runAction:waitAndPowerdown withKey:@"waitAndPowerdown"];
            
        }
        
    }];
    
    
    [self enumerateChildNodesWithName:@"speedPowerup" usingBlock:^(SKNode *powerup, BOOL *stop) {
        
        if ([ship intersectsNode:powerup]) {
            [powerup removeFromParent];
            
            self.shipSpeed = 260;
            [self.shipThrust setParticleScale:0.6];
            [self.shipThrust setSpeed:600];
            
            
            SKLabelNode *powerupTimer = [SKLabelNode labelNodeWithFontNamed:@"Optima-ExtraBlack"];
            powerupTimer.fontColor = [SKColor blueColor];
            powerupTimer.fontSize = 13;
            powerupTimer.zPosition = 100;
            powerupTimer.position = CGPointMake(-1, -31);
            __block int time = 10;
            
            [ship addChild:powerupTimer];
            
            
            SKAction *timerCountdown = [SKAction repeatAction:[SKAction sequence:@[[SKAction runBlock:^{
                powerupTimer.text = [NSString stringWithFormat:@"%i", time];
                time--;
                [self runAction:self.countdownBeepSound];
            }], [SKAction waitForDuration:1]]] count:10];
            SKAction *powerdown = [SKAction runBlock:^{
                self.shipSpeed = 130;
                [self.shipThrust setParticleScale:0.3];
                [self.shipThrust setSpeed:300];
                [powerupTimer removeFromParent];
            }];
            SKAction *timerCountdownAndPowerdown = [SKAction sequence:@[timerCountdown, powerdown]];
            
            [ship removeActionForKey:@"timerCountdownAndPowerdown"];
            [ship runAction:timerCountdownAndPowerdown withKey:@"timerCountdownAndPowerdown"];
            
        }
        
    }];
    

    [self enumerateChildNodesWithName:@"shipHealth" usingBlock:^(SKNode *powerup, BOOL *stop) {
        
        if ([ship intersectsNode:powerup]) {
            [powerup removeFromParent];
            
            LCHUDNode *hud = (LCHUDNode *)[self childNodeWithName:@"hud"];
            
            self.shipHealthRate = 4.0;
            [hud updateHealth:self.shipHealthRate];
            [self.shipShield setParticleScale:(self.shipHealthRate * 0.05)];
            
        }
        
    }];
    

    [self enumerateChildNodesWithName:@"obstacle" usingBlock:^(SKNode *obstacle, BOOL *stop) {
        
        if ([ship intersectsNode:obstacle]) {
            
            [self runAction:self.obstacleExplodeSound];
                
            SKEmitterNode *explosion = [self.obstacleExplodeTemplate copy];
            explosion.position = obstacle.position;
            explosion.zPosition = 4;
            [explosion lc_dieOutInDuration:0.1];
                
            [self addChild:explosion];
            
            [obstacle removeFromParent];
            
            
            LCHUDNode *hud = (LCHUDNode *)[self childNodeWithName:@"hud"];
            
            self.shipHealthRate--;
            
            [hud updateHealth:self.shipHealthRate];
            [self.shipShield setParticleScale:(self.shipHealthRate * 0.05)];
            
            // check if health is left
            if (self.shipHealthRate == 0) {
                
                self.shipTouch = nil;
                
                [ship removeFromParent];
                
                [self runAction:self.shipExplodeSound];
                
                SKEmitterNode *explosion = [self.shipExplodeTemplate copy];
                explosion.position = obstacle.position;
                explosion.zPosition = 4;
                [explosion lc_dieOutInDuration:1.0];
                
                [self addChild:explosion];
                
                
                SKAction *wait = [SKAction waitForDuration:5];
                SKAction *loadGameOverScene = [SKAction runBlock:^{
                    SKTransition *reveal = [SKTransition flipHorizontalWithDuration:2.5];
                    SKScene * gameOverScene = [[GameOverScene alloc] initWithSize:self.size score:hud.score];
                    [self.view presentScene:gameOverScene transition: reveal];
                }];
                
                [self runAction:(SKAction *)[SKAction sequence:@[wait, loadGameOverScene]]];

            }
            
        }
        
        
        [self enumerateChildNodesWithName:@"photon" usingBlock:^(SKNode *photon, BOOL *stop) {
            
            if ([photon intersectsNode:obstacle]) {
                
                [photon removeFromParent];
                [obstacle removeFromParent];
                
                [self runAction:self.obstacleExplodeSound];
                
                
                SKEmitterNode *explosion = [self.obstacleExplodeTemplate copy];
                explosion.position = obstacle.position;
                explosion.zPosition = 4;
                [explosion lc_dieOutInDuration:0.1];
                
                [self addChild:explosion];
                
                
                LCHUDNode *hud = (LCHUDNode *)[self childNodeWithName:@"hud"];
                
                NSInteger score = 10;
                
                [hud addPoints:score];
                
                *stop = YES;
                
            }
            
        }];
        
    }];
    
}



-(void)dropHealth {
    
    CGFloat sideSize = 20;
    CGFloat startX = arc4random_uniform(self.size.width - 60) + 30;
    CGFloat startY = self.size.height + sideSize;
    CGFloat endY = 0 - sideSize;
    
    SKSpriteNode *shipHealth = [SKSpriteNode spriteNodeWithImageNamed:@"health"];
    shipHealth.name = @"shipHealth";
    shipHealth.size = CGSizeMake(sideSize, sideSize);
    shipHealth.position = CGPointMake(startX, startY);
    shipHealth.zPosition = 4;
    
    [self addChild:shipHealth];
    
    
    SKAction *move = [SKAction moveTo:CGPointMake(startX, endY) duration:5];
    SKAction *scale = [SKAction resizeToWidth:10 height:10 duration:5];
    SKAction *fade = [SKAction fadeAlphaTo:0 duration:5];
    SKAction *remove = [SKAction removeFromParent];
    SKAction *travelAndRemove = [SKAction sequence:@[move, remove]];
    SKAction *all = [SKAction group:@[scale, fade, travelAndRemove]];
    
    [shipHealth runAction:all];
    
}

@end
