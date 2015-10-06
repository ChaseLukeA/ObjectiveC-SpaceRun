//
//  LCHUDNode.m
//  LP4SpaceRun_lchase1
//
//  Created by Luke Chase on 4/29/15.
//  Copyright (c) 2015 Chase.Luke.A. All rights reserved.
//

#import "LCHUDNode.h"


// declare variables and properties in here - don't want them exposed
// "private instance variables" (no @-sign variables), don't need to
// be in the .h; you DECLARE them here but cannot initialize them here
@interface LCHUDNode()

@property (nonatomic, strong) NSNumberFormatter *scoreFormatter;
@property (nonatomic, strong) NSNumberFormatter *timeFormatter;

//@property (nonatomic, strong) NSNumberFormatter *scoreFormatter;  // use something similar for the health

@end


@implementation LCHUDNode

// used to be "id" a lot, now they use "instancetype"
-(instancetype)init {
    
    // very very common to check if node was created ok;
    // super is for parent class (SKNode)
    if (self = [super init]) {
        
        // scoreGroup -------------------------------------------------------------------------|
        
        // we build an empty SKNode as our containing group
        // and name it scoreGroup (contains score label and
        // value); we name it so we can reference it later
        //
        // sending "node" to the SKNode is the way SKNodes
        // like to do their version of "alloc init"
        SKNode *scoreGroup = [SKNode node];
        scoreGroup.name = @"scoreGroup";
        
        // scoreTitle -------------------------------------------------------------------------|
        
        // create an SKLabelNode for the scoreTitle that has
        // a font size and color
        SKLabelNode *scoreTitle = [SKLabelNode labelNodeWithFontNamed:@"Optima-ExtraBlack"];
        scoreTitle.fontColor = [SKColor whiteColor];
        scoreTitle.fontSize = 12;
        
        // set the vertical and horizontal alignment modes
        // in a way to help us lay out the labels inside
        // this group node
        scoreTitle.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeLeft;
        scoreTitle.verticalAlignmentMode = SKLabelVerticalAlignmentModeBottom;
        scoreTitle.text = @"SCORE";
        scoreTitle.position = CGPointMake(0, 4);
        
        // add the title to the parent node
        [scoreGroup addChild:scoreTitle];
        
        // scoreValue -------------------------------------------------------------------------|
        
        SKLabelNode *scoreValue = [SKLabelNode labelNodeWithFontNamed:@"Optima-ExtraBlack"];
        scoreValue.fontColor = [SKColor whiteColor];
        scoreValue.fontSize = 20;
        
        // set the vertical and horizontal alignment modes
        // in a way to help us lay out the labels inside
        // this group node
        scoreValue.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeLeft;
        scoreValue.verticalAlignmentMode = SKLabelVerticalAlignmentModeTop;
        scoreValue.name = @"scoreValue";
        scoreValue.text = @"0";
        scoreValue.position = CGPointMake(0, -4);
        
        // add the Value to the parent node
        [scoreGroup addChild:scoreValue];
        
        // add the parent group to the grandparent node
        [self addChild:scoreGroup];
        
        // ------------------------------------------------------------------------------------|
        
    // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // //
        
        SKNode *healthGroup = [SKNode node];
        healthGroup.name = @"healthGroup";
        
        // healthTitle -------------------------------------------------------------------------|
        
        SKLabelNode *healthTitle = [SKLabelNode labelNodeWithFontNamed:@"Optima-ExtraBlack"];
        healthTitle.fontColor = [SKColor whiteColor];
        healthTitle.fontSize = 12;
        
        healthTitle.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeRight;
        healthTitle.verticalAlignmentMode = SKLabelVerticalAlignmentModeBottom;
        healthTitle.text = @"HEALTH";
        healthTitle.position = CGPointMake(0, 4);
        
        [healthGroup addChild:healthTitle];
        
        // healthValue -------------------------------------------------------------------------|
        
        SKLabelNode *healthValue = [SKLabelNode labelNodeWithFontNamed:@"Optima-ExtraBlack"];
        healthValue.fontColor = [SKColor whiteColor];
        healthValue.fontSize = 20;
        
        healthValue.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeRight;
        healthValue.verticalAlignmentMode = SKLabelVerticalAlignmentModeTop;
        healthValue.name = @"healthValue";
        healthValue.text = @"50%";
        healthValue.position = CGPointMake(0, -4);
        
        [healthGroup addChild:healthValue];
        
        [self addChild:healthGroup];
        
    // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // //
        
        SKNode *powerupGroup = [SKNode node];
        powerupGroup.name = @"powerupGroup";
        
        SKLabelNode *powerupTitle = [SKLabelNode labelNodeWithFontNamed:@"Optima-ExtraBlack"];
        powerupTitle.fontColor = [SKColor redColor];
        powerupTitle.fontSize = 14;
        
        powerupTitle.verticalAlignmentMode = SKLabelVerticalAlignmentModeBottom;
        powerupTitle.text = @"POWERUP!";
        powerupTitle.position = CGPointMake(0, 4);
        
        [powerupGroup addChild:powerupTitle];
        
        SKLabelNode *powerupValue = [SKLabelNode labelNodeWithFontNamed:@"Optima-ExtraBlack"];
        powerupValue.name = @"powerupValue";
        powerupValue.fontColor = [SKColor redColor];
        powerupValue.fontSize = 20;
        
        powerupValue.verticalAlignmentMode = SKLabelVerticalAlignmentModeTop;
        powerupValue.text = @"0s";
        powerupValue.position = CGPointMake(0, -4);
        powerupValue.zPosition = 100;
        
        [powerupGroup addChild:powerupValue];
        
        [self addChild:powerupGroup];
        
        powerupGroup.alpha = 0;
        
        
    // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // //
        
        
        
        // look up the numberStyle
        self.scoreFormatter = [[NSNumberFormatter alloc] init];
        self.scoreFormatter.numberStyle = NSNumberFormatterDecimalStyle;
        
        self.timeFormatter = [[NSNumberFormatter alloc] init];
        self.timeFormatter.numberStyle = NSNumberFormatterDecimalStyle;
        self.timeFormatter.minimumFractionDigits = 1;
        self.timeFormatter.maximumFractionDigits = 1;
        
    }
    
    return self;
    
}


-(void)layoutForScene {
    
    // when a node exists in the scene graph, it can get
    // access to the scene through its "scene" property;
    // that property is "nil" if the node doesn't yet
    // belong to a scene (hasn't been added)
    //
    // we will use the NSAssert() macro to cause a fatal
    // error if the self.scene property is "nil"; this
    // will give us feedback while developing if we try
    // to call the method without a scene
    NSAssert(self.scene, @"Cannot be called unless added to a scene.");
    
    // grab the calling scene's size
    CGSize sceneSize = self.scene.size;
    
    // create a variable to help us calculate the
    // position of each group
    CGSize groupSize = CGSizeZero;
    
    // look up the group by its assigned name and
    // calculate the size of the enclosing frame
    // around the node; this will help us calculate
    // how far down from the top of the scene the node
    // should be
    SKNode *scoreGroup = [self childNodeWithName:@"scoreGroup"];
    groupSize = [scoreGroup calculateAccumulatedFrame].size;
    scoreGroup.position = CGPointMake(0 - sceneSize.width / 2 + 20, sceneSize.height / 2 - groupSize.height);
    
    SKNode *healthGroup = [self childNodeWithName:@"healthGroup"];
    groupSize = [healthGroup calculateAccumulatedFrame].size;
    healthGroup.position = CGPointMake(sceneSize.width / 2 - 20, sceneSize.height / 2 - groupSize.height);
    
    SKNode *powerupGroup = [self childNodeWithName:@"powerupGroup"];
    groupSize = [powerupGroup calculateAccumulatedFrame].size;
    powerupGroup.position = CGPointMake(0, sceneSize.height / 2 - groupSize.height);
}


-(void)addPoints:(NSInteger)points {
    
    self.score += points;
    
    // grandchildren are found using a name path
    SKLabelNode *scoreValue = (SKLabelNode *)[self childNodeWithName:@"scoreGroup/scoreValue"];
    
    // we want the scores to be formatted with the
    // thousands separator, so we'll use the
    // NSNumberFormatter object that we will cache
    // in the self.scoreFormatter property
    scoreValue.text = [NSString stringWithFormat:@"%@", [self.scoreFormatter stringFromNumber:@(self.score)]];
    
    SKAction *scale = [SKAction scaleTo:1.1 duration:0.02];
    
    SKAction *shrink = [SKAction scaleTo:1.0 duration:0.07];
    
    [scoreValue runAction:[SKAction sequence:@[scale, shrink]]];
    
}

    // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // //

-(void)updateHealth:(CGFloat)shipHealth {
    
    SKLabelNode *healthValue = (SKLabelNode *)[self childNodeWithName:@"healthGroup/healthValue"];
    
    healthValue.text = [NSString stringWithFormat:@"%.lf%%", (shipHealth * 25)];
    
    
    
}
    // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // //

-(void)powerupTimer:(NSTimeInterval)time {
    
    SKNode *powerupGroup = [self childNodeWithName:@"powerupGroup"];
    
    SKLabelNode *powerupValue = (SKLabelNode *)[powerupGroup childNodeWithName:@"powerupValue"];
    
    [powerupGroup removeActionForKey:@"powerupTimer"];
    
    NSTimeInterval start = [NSDate timeIntervalSinceReferenceDate];
    
    __weak LCHUDNode *weakSelf = self;
    
    SKAction *block = [SKAction runBlock:^{
        
        NSTimeInterval elapsed = [NSDate timeIntervalSinceReferenceDate] - start;
        
        NSTimeInterval left = time - elapsed;
    
        if (left < 0) {
            
            left = 0;
            
        }
        
        powerupValue.text = [NSString stringWithFormat:@"%@s",
                            [weakSelf.timeFormatter stringFromNumber:@(left)]];
    
    }];
    
    SKAction *blockPause = [SKAction waitForDuration:0.05];
    
    SKAction *countdownSequence = [SKAction sequence:@[block, blockPause]];
    
    SKAction *countdown = [SKAction repeatActionForever:countdownSequence];
    
    SKAction *fadeIn = [SKAction fadeAlphaTo:1 duration:0.1];
    
    SKAction *wait = [SKAction waitForDuration:time];
    
    SKAction *fadeOut = [SKAction fadeAlphaTo:0 duration:1];
    
    SKAction *stopAction = [SKAction runBlock:^{
        
        [powerupGroup removeActionForKey:@"powerupTimer"];
    
    }];
    
    SKAction *visuals = [SKAction sequence:@[fadeIn, wait, fadeOut, stopAction]];
    
    [powerupGroup runAction:[SKAction group:@[countdown, visuals]] withKey:@"powerupTimer"];
    
}

    // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // //


@end