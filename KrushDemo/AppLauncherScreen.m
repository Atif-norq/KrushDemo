//
//  AppLauncherScreen.m
//  KrushDemo
//
//  Created by Atif Khan on 8/28/14.
//  Copyright (c) 2014 Norq Solutions. All rights reserved.
//

#import "AppLauncherScreen.h"
#import "UniqueRandomObjectGetter.h"

@interface AppLauncherScreen(){
    NSTimeInterval spawnDuration;
    NSTimeInterval minimumJourneyTime;
    NSTimeInterval maxJourneyTime;
    
}
@property (nonatomic) NSTimeInterval lastSpawnTimeInterval;
@property (nonatomic) NSTimeInterval lastUpdateTimeInterval;
@property (nonatomic, strong) NSArray *spawnIcons;
@property (nonatomic, strong) NSMutableSet *unspawnedItems;
@property (nonatomic, strong) NSString *lastSpawnedIcon;
@property (nonatomic, strong) UniqueRandomObjectGetter *randomRegionGetter;
@property (nonatomic, strong) UniqueRandomObjectGetter *spawnPointA;
@property (nonatomic, strong) UniqueRandomObjectGetter *spawnPointB;
@property (nonatomic, strong) UniqueRandomObjectGetter *spawnPointC;

@end

@implementation AppLauncherScreen

-(void) setFont:(UIFont *)font onButtons:(NSArray *)buttons{

    for (UIButton *bt in buttons) {
        bt.titleLabel.font = font;
    }
}

-(instancetype)initWithSize:(CGSize)size{
    if(self = [super initWithSize:size]){
        self.backgroundColor    = [SKColor colorWithRed:30/255.f green:176/255.f blue:245/255.f alpha:1.];
        spawnDuration           = 2.f;
        self.spawnIcons         = @[@"camera.png", @"chair.png",@"headphone.png",@"laptop.png",@"mobile.png"];
        self.unspawnedItems     = [NSMutableSet setWithArray:_spawnIcons];
        self.spawnPointA        = [[UniqueRandomObjectGetter alloc] initWithObjects:_unspawnedItems];
        self.spawnPointB        = [_spawnPointA copy];
        self.spawnPointC        = [_spawnPointA copy];
        minimumJourneyTime      = 25;
        maxJourneyTime          = 50;
    }
    return self;
}

-(void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
    // If we drop below 60fps, we still want everything to move the same distance.
    CFTimeInterval timeSinceLast = currentTime - self.lastUpdateTimeInterval;
    self.lastUpdateTimeInterval = currentTime;
    if (timeSinceLast > 1) { // more than a second since last update
        timeSinceLast = 1.0 / 60.0;
        self.lastUpdateTimeInterval = currentTime;
    }
    [self updateWithTimeSinceLastUpdate:timeSinceLast];
}

-(SKSpriteNode *)spawnIconNode:(NSString *)icon fromPoint:(CGPoint) origin journeyTime:(NSTimeInterval )journeyTime{
    SKSpriteNode *node      = [SKSpriteNode spriteNodeWithImageNamed:icon];
    node.name               = icon;
    node.alpha              = .1;
    node.position           = origin;
    int nodeItemWidthHalf   = node.size.width/2;
    int nodeItemHeightHalf  = node.size.height/2;
    CGSize sceneSize        = self.frame.size;
    origin.x                = origin.x - nodeItemWidthHalf;
    origin.y                = origin.y - nodeItemHeightHalf;
    [self addChild:node];
    
    CGPoint endPoint        = CGPointMake(origin.x ,sceneSize.height+ nodeItemHeightHalf);
    
    SKAction *actionMove = [SKAction moveTo:endPoint  duration:journeyTime];
    SKAction * actionMoveDone = [SKAction removeFromParent];
    [node runAction:[SKAction sequence:@[actionMove, actionMoveDone]]];
    
    return node;
}


-(void )spawnIcon{
    [self spawnIconAtOriginY:-32];
}

-(void )spawnIconAtOriginY:(float )y{
    CGSize sceneSize        = self.frame.size;
    NSString *icon = nil;
    static int spawncount = 0;
    spawncount +=1;
    int x = 32+20;
    NSTimeInterval timeInterval = 27;
    if (spawncount %3 == 2 ) {
        x = sceneSize.width/2;
        icon = [_spawnPointB getRandomItem];
        timeInterval = 38;
    }else if(spawncount %3 == 0){
        x = 32+sceneSize.width/2+80;
        timeInterval = 25;
        icon = [_spawnPointC getRandomItem];
    }else{
        icon = [_spawnPointA getRandomItem];
    }
    if (y>-32) {
        float journeyProgress = ((y - 32)/sceneSize.height);
        timeInterval = timeInterval*(1-journeyProgress);
    }else{
        int variantRange = 40;
        float xVariant = arc4random() %variantRange;
        if (xVariant>variantRange/2) {
            x += xVariant - variantRange/2;
        }else{
            x -= xVariant;
        }
    }
    [self spawnIconNode:icon fromPoint:CGPointMake(x, y) journeyTime:timeInterval];
    
}

- (void)updateWithTimeSinceLastUpdate:(CFTimeInterval)timeSinceLast {
    
    
    self.lastSpawnTimeInterval += timeSinceLast;
    if (self.lastSpawnTimeInterval > spawnDuration) {
        self.lastSpawnTimeInterval = 0;
        [self spawnIcon];
        
    }
}

-(void )prePopulateNodes{
    CGSize sceneSize = self.frame.size;
    
    [self spawnIconAtOriginY:(sceneSize.height - .8*sceneSize.height)];
    [self spawnIconAtOriginY:(sceneSize.height - .1*sceneSize.height)];
    [self spawnIconAtOriginY:(sceneSize.height - .5*sceneSize.height)];
    [self spawnIconAtOriginY:(sceneSize.height - .3*sceneSize.height)];
    [self spawnIconAtOriginY:(sceneSize.height - .7*sceneSize.height)];


    
}

@end
