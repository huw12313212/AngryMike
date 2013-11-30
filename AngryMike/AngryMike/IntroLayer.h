//
//  IntroLayer.h
//  AngryMike
//
//  Created by 王 瀚宇 on 2013/11/24.
//  Copyright 王 瀚宇 2013年. All rights reserved.
//


// When you import this file, you import all the cocos2d classes
#import "cocos2d.h"

// HelloWorldLayer
@interface IntroLayer : CCLayer
{
    
}
@property (strong,nonatomic)CCSprite* PlayButton;
@property bool PlayPressed;

// returns a CCScene that contains the HelloWorldLayer as the only child
+(CCScene *) scene;

@end
