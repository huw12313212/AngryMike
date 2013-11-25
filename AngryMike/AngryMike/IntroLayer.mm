//
//  IntroLayer.m
//  AngryMike
//
//  Created by 王 瀚宇 on 2013/11/24.
//  Copyright 王 瀚宇 2013年. All rights reserved.
//


// Import the interfaces
#import "IntroLayer.h"
#import "HelloWorldLayer.h"
#import "SimpleAudioEngine.h"


#pragma mark - IntroLayer


// HelloWorldLayer implementation
@implementation IntroLayer


// Helper class method that creates a Scene with the HelloWorldLayer as the only child.
+(CCScene *) scene
{
	CCScene *scene = [CCScene node];
	IntroLayer *layer = [IntroLayer node];
	[scene addChild: layer];
	
	return scene;
}

-(id) init
{
	if( (self=[super init])) {
		
        self.PlayPressed = false;
        self.touchEnabled = true;
        
        //取得坐標
		CGSize size = [[CCDirector sharedDirector] winSize];


        //setting label
        CCLabelTTF *label = [CCLabelTTF labelWithString:@"Angry Mike" fontName:@"Marker Felt" fontSize:32];
		[label setColor:ccc3(254,222,143)];
		label.position = ccp( size.width/2, size.height/2 + 40);
		[self addChild:label z:0];
        
        
        self.PlayButton = [CCSprite spriteWithFile:@"Play.png"];
		self.PlayButton.position = ccp(size.width/2, size.height/2 - 30);
		[self addChild: self.PlayButton z:0];
        
        
        CCActionInterval* scaleUpAction = [CCScaleTo actionWithDuration:0.3 scale:1.2];
        CCEaseIn* easeUp =[CCEaseOut actionWithAction:scaleUpAction rate:3];
        CCActionInterval* scaleDownAction = [CCScaleTo actionWithDuration:0.3 scale:1];
        CCEaseOut* easeDown =[CCEaseIn actionWithAction:scaleDownAction rate:3];
        CCFiniteTimeAction* holdAction = [CCDelayTime actionWithDuration:2];
        CCActionInterval* sequence = [CCSequence actions:holdAction,easeUp,easeDown,easeUp,easeDown,holdAction, nil];
        CCAction* repeatAction = [CCRepeatForever actionWithAction:sequence];
        
        

        [label runAction:repeatAction];
	}
	
	return self;
}

- (void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    for( UITouch *touch in touches )
    {
        CGPoint location = [self convertTouchToNodeSpace: touch];
        if (CGRectContainsPoint(self.PlayButton.boundingBox, location))
        {
            NSLog(@"Clicked");
            
            [self ClickDownPlay];
        }
    }
}

-(void)ClickDownPlay
{
    self.PlayPressed = true;
    
    CCActionInterval* scaleUpAction = [CCScaleTo actionWithDuration:0.1 scale:0.9];
    
    [self.PlayButton runAction:scaleUpAction];
    
    
}

- (void)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
//    NSLog(@"here");
//    
//    for( UITouch *touch in touches ) {
//        
//        CGPoint touchLocation = [touch locationInView: [touch view]];
//        CGPoint prevLocation = [touch previousLocationInView: [touch view]];
//        
//        touchLocation = [[CCDirector sharedDirector] convertToGL: touchLocation];
//        prevLocation = [[CCDirector sharedDirector] convertToGL: prevLocation];
//        
//        CGPoint diff = ccpSub(touchLocation,prevLocation);
//        
//        self.position  = ccpAdd(self.position,diff);
//        
//	}
}

- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if(self.PlayPressed)
    {
        self.PlayPressed = false;
        CCActionInterval* scaleUpAction = [CCScaleTo actionWithDuration:0.1 scale:1];
        [self.PlayButton runAction:scaleUpAction];
        
        [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0 scene:[HelloWorldLayer scene]]];
        
 
  

    }
}

- (void)ccTouchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    
}

-(void) onEnter
{
	[super onEnter];
}
@end
