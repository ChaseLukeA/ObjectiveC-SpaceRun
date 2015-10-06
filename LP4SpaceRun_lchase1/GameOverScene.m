//
//  GameOverScene.m
//  LP4SpaceRun_lchase1
//
//  Created by Luke Chase on 5/6/15.
//  Copyright (c) 2015 Chase.Luke.A. All rights reserved.
//

#import "GameOverScene.h"
#import "GameScene.h"
#import "LCStarfield.h"
#import "SKEmitterNode+LCExtensions.h"


@interface GameOverScene ()

@property (nonatomic) SKEmitterNode *scoreOnFire;

@end


@implementation GameOverScene


-(id)initWithSize:(CGSize)size score: (NSInteger)score{  //updated the existing method
    
    if (self = [super initWithSize:size]) {
        
        self.backgroundColor = [SKColor blackColor];
        
        LCStarfield *starField = [LCStarfield node];
        [self addChild:starField];
        
        self.scoreOnFire = [SKEmitterNode lc_nodeWithFile:@"score.sks"];
        
        self.scoreOnFire.position = CGPointMake(self.size.width/2, (self.size.height/5) * 2.25);
        self.scoreOnFire.zPosition = 2;
        
        [self addChild:self.scoreOnFire];
        
        
        // game over message
        SKNode *gameOverMessage = [SKNode node];
        SKLabelNode *line1 = [SKLabelNode labelNodeWithFontNamed:@"Optima-ExtraBlack"];
        line1.fontSize = 25;
        line1.fontColor = [SKColor redColor];
        SKLabelNode *line2 = [SKLabelNode labelNodeWithFontNamed:@"Optima-ExtraBlack"];
        line2.fontSize = 40;
        line2.fontColor = [SKColor redColor];
        line2.position = CGPointMake(line2.position.x, line2.position.y - 50);
        line1.text = @"Game over, man,";
        line2.text = @"GAME OVER!!!";
        [gameOverMessage addChild:line1];
        [gameOverMessage addChild:line2];
        gameOverMessage.position = CGPointMake(self.size.width/2, (self.size.height/5) * 4);
        gameOverMessage.zPosition = 3;
        [self addChild:gameOverMessage];
        
        // score
        SKLabelNode *endScore = [SKLabelNode labelNodeWithFontNamed:@"Optima-ExtraBlack"];
        endScore.text = [NSString stringWithFormat:@"Score:\r%li", (long)score];
        endScore.fontSize = 40;
        endScore.fontColor = [SKColor blackColor];
        endScore.position = CGPointMake(self.size.width/2, (self.size.height/5) * 2.125);
        endScore.zPosition = 3;
        endScore.name = @"score";
        [self addChild:endScore];
        
        // replay * quit buttons
        SKNode *actionButtons = [SKNode node];
        SKLabelNode *replayButton = [SKLabelNode labelNodeWithFontNamed:@"Optima-ExtraBlack"];
        replayButton.text = @"Replay Game";
        replayButton.fontSize = 25;
        replayButton.fontColor = [SKColor orangeColor];
        replayButton.name = @"replay";
        [actionButtons addChild:replayButton];
        
        // quit button
        SKLabelNode *quitButton = [SKLabelNode labelNodeWithFontNamed:@"Optima-ExtraBlack"];
        quitButton.text = @"Quit Game";
        quitButton.fontSize = 25;
        quitButton.fontColor = [SKColor orangeColor];
        quitButton.position = CGPointMake(quitButton.position.x, quitButton.position.y - 50);
        quitButton.name = @"quit";
        actionButtons.position = CGPointMake(self.size.width/2, self.size.height/5);
        actionButtons.zPosition = 3;
        [actionButtons addChild:quitButton];
        
        [self addChild:actionButtons];
        
        
    }
    
    return self;
    
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];
    SKNode *node = [self nodeAtPoint:location];
    
    if ([node.name isEqualToString:@"replay"]) {
        SKTransition *reveal = [SKTransition flipHorizontalWithDuration:2.5];
        
        GameScene * scene = [GameScene sceneWithSize:self.view.bounds.size];
        scene.scaleMode = SKSceneScaleModeAspectFill;
        [self.view presentScene:scene transition: reveal];
        
    } else if ([node.name isEqualToString:@"quit"]) {
        exit(0);
    }
    
}


@end
