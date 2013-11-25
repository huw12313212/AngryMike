//
//  HelloWorldLayer.mm
//  AngryMike
//
//  Created by 王 瀚宇 on 2013/11/24.
//  Copyright 王 瀚宇 2013年. All rights reserved.
//

// Import the interfaces
#import "HelloWorldLayer.h"

// Not included in "cocos2d.h"
#import "CCPhysicsSprite.h"

// Needed to obtain the Navigation Controller
#import "AppDelegate.h"


enum {
	kTagParentNode = 1,
};


#pragma mark - HelloWorldLayer



@interface HelloWorldLayer()
{
    CCTexture2D *MikeTexture;	// weak ref
    CCTexture2D *BackGroundTexture; //
    
	b2World* world;					// strong ref
	GLESDebugDraw *m_debugDraw;		// strong ref
    
    NSMutableArray* Mikes;
    int MikeIndex;
    bool MikeClicked;
}



-(void) initPhysics;
-(CCSprite*) addNewMikeAtPosition:(CGPoint)p;
-(void) createMenu;

@end

@implementation HelloWorldLayer

+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	HelloWorldLayer *layer = [HelloWorldLayer node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

-(id) init
{
	if( (self=[super init])) {
		
        MikeIndex = 0;
        Mikes = [[NSMutableArray alloc]init];
        MikeClicked = false;
        
		// enable events
			CGSize size = [[CCDirector sharedDirector] winSize];
		self.touchEnabled = YES;
		self.accelerometerEnabled = YES;
		
		// init physics
		[self initPhysics];
		

		MikeTexture = [[CCTextureCache sharedTextureCache] addImage:@"Mike.png"];
        
        BackGroundTexture =[[CCTextureCache sharedTextureCache] addImage:@"Background.png"];
        CCSprite* background = [CCSprite spriteWithTexture:BackGroundTexture];
        
        background.position = CGPointMake(size.width/2, size.height/2);//size/2 ; //size
        [self addChild:background z:-1];
        
        
        CCSprite* sling1 = [CCSprite spriteWithFile:@"sling1.png"];
        CCSprite* sling2 = [CCSprite spriteWithFile:@"sling2.png"];
        
        [self addChild:sling1 z:2];
        
        [self addChild:sling2 z:0];
        
        sling1.position = CGPointMake(66, 155);
        sling2.position = CGPointMake(71, 167);
        
        [self addNewMikeAtPosition:CGPointMake(SLING_POINT_X,SLING_POINT_Y)];
        
        [[self addNewMikeAtPosition:CGPointMake(44.5,146)] setRotation:40.0f];
        
        [[self addNewMikeAtPosition:CGPointMake(21.5,146)]setRotation: -22.0f];
        
        
        
        
        
        
        CCMenuItemLabel *reset = [CCMenuItemFont itemWithString:@"Reset" block:^(id sender){
            [[CCDirector sharedDirector] replaceScene: [CCTransitionFade transitionWithDuration:0.5f scene:[HelloWorldLayer scene]]];
        }];
        
        reset.scale = 0.5f;
        
        CCMenu *menu = [CCMenu menuWithItems:reset, nil];
        menu.position = CGPointMake(size.width - 50, size.height - 50);
        [self addChild:menu];
        
        
		[self scheduleUpdate];
	}
	return self;
}

-(void) dealloc
{
	delete world;
	world = NULL;
	
	delete m_debugDraw;
	m_debugDraw = NULL;
	
	[super dealloc];
}	


-(void) initPhysics
{
	
	CGSize s = [[CCDirector sharedDirector] winSize];
	
	b2Vec2 gravity;
	gravity.Set(0.0f, -320/PTM_RATIO);
	world = new b2World(gravity);
	
	
	// Do we want to let bodies sleep?
	world->SetAllowSleeping(true);
	
	world->SetContinuousPhysics(true);
	
	m_debugDraw = new GLESDebugDraw( PTM_RATIO );
	world->SetDebugDraw(m_debugDraw);
	
	uint32 flags = 0;
	flags += b2Draw::e_shapeBit;
	//		flags += b2Draw::e_jointBit;
	//		flags += b2Draw::e_aabbBit;
	//		flags += b2Draw::e_pairBit;
	//		flags += b2Draw::e_centerOfMassBit;
	m_debugDraw->SetFlags(flags);		
	
	
	// Define the ground body.
	b2BodyDef groundBodyDef;
	groundBodyDef.position.Set(0, 0); // bottom-left corner
	
	// Call the body factory which allocates memory for the ground body
	// from a pool and creates the ground box shape (also from a pool).
	// The body is also added to the world.
	b2Body* groundBody = world->CreateBody(&groundBodyDef);
	
	// Define the ground box shape.
	b2EdgeShape groundBox;		
	
	// bottom
    
    NSLog(@"%f,%f",s.width,s.height);
	
	groundBox.Set(b2Vec2(0.0f/PTM_RATIO,135.0f/PTM_RATIO), b2Vec2(76.0f/PTM_RATIO,135.0f/PTM_RATIO));
	groundBody->CreateFixture(&groundBox,0);

	groundBox.Set(b2Vec2(152.0f/PTM_RATIO/2,(640.0f-370.0f)/PTM_RATIO/2), b2Vec2(152.0f/PTM_RATIO/2,(640.0f-610.0f)/PTM_RATIO/2));
	groundBody->CreateFixture(&groundBox,0);

	groundBox.Set(b2Vec2(152.0f/PTM_RATIO/2,(640.0f-610.0f)/PTM_RATIO/2), b2Vec2(959.0f/PTM_RATIO/2,(640.0f-610.0f)/PTM_RATIO/2));
	groundBody->CreateFixture(&groundBox,0);
    
    
    // top
	groundBox.Set(b2Vec2(0,s.height/PTM_RATIO), b2Vec2(s.width/PTM_RATIO,s.height/PTM_RATIO));
	groundBody->CreateFixture(&groundBox,0);
	
	// left
	groundBox.Set(b2Vec2(0,s.height/PTM_RATIO), b2Vec2(0,0));
	groundBody->CreateFixture(&groundBox,0);
	
	// right
	groundBox.Set(b2Vec2(s.width/PTM_RATIO,s.height/PTM_RATIO), b2Vec2(s.width/PTM_RATIO,0));
	groundBody->CreateFixture(&groundBox,0);
}

-(void) draw
{
	[super draw];
	
	ccGLEnableVertexAttribs( kCCVertexAttribFlag_Position );
	
	kmGLPushMatrix();
	
	world->DrawDebugData();	
	
	kmGLPopMatrix();
}



-(CCSprite*) addNewMikeAtPosition:(CGPoint)p
{
	CCLOG(@"Add sprite %0.2f x %02.f",p.x,p.y);
	// Define the dynamic body.
	//Set up a 1m squared box in the physics world
	b2BodyDef bodyDef;
	bodyDef.type = b2_kinematicBody;
	bodyDef.position.Set(p.x/PTM_RATIO, p.y/PTM_RATIO);
	b2Body *body = world->CreateBody(&bodyDef);
	
	// Define another box shape for our dynamic body.
    
	b2CircleShape dynamicMike;
    dynamicMike.m_radius =10.0f/PTM_RATIO;

	// Define the dynamic body fixture.
	b2FixtureDef fixtureDef;
	fixtureDef.shape = &dynamicMike;	
	fixtureDef.density = 1.0f;
	fixtureDef.friction = 0.3f;
	body->CreateFixture(&fixtureDef);
	
    
	CCPhysicsSprite *sprite = [CCPhysicsSprite spriteWithTexture:MikeTexture];
	[self addChild:sprite];
	
	[sprite setPTMRatio:PTM_RATIO];
	[sprite setB2Body:body];
	[sprite setPosition: ccp( p.x, p.y)];
    
    [sprite setScale:0.8f];
    
    [Mikes addObject:sprite];
    
    return sprite;

}

-(void) update: (ccTime) dt
{
	int32 velocityIterations = 8;
	int32 positionIterations = 1;
	
	world->Step(dt, velocityIterations, positionIterations);	
}

- (void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    for( UITouch *touch in touches )
    {
        CGPoint location = [self convertTouchToNodeSpace: touch];
        CCPhysicsSprite* currentMike =(CCPhysicsSprite*)Mikes[MikeIndex];
        
        if (CGRectContainsPoint(currentMike.boundingBox, location))
        {
            NSLog(@"clicked");
            
            MikeClicked = true;
           // currentMike.b2Body->SetType(b2_dynamicBody);
        }
    }
}


- (void)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    if(MikeClicked)
    {
        for( UITouch *touch in touches )
        {
         CCPhysicsSprite* currentMike =(CCPhysicsSprite*)Mikes[MikeIndex];
        
            
            CGPoint location = [self convertTouchToNodeSpace: touch];
            
            
            float distx = (location.x - SLING_POINT_X);
            float disty = (location.y - SLING_POINT_Y);
            
            double dist = sqrt(distx * distx + disty * disty);
             NSLog(@"%lf",dist);
            
            if(dist > SLING_RADIO)
            {
                float normalizeX = distx / dist;
                float normalizeY = disty / dist;
                
                float newX = normalizeX*SLING_RADIO;
                float newY = normalizeY*SLING_RADIO;
                
                 currentMike.position = CGPointMake(SLING_POINT_X+newX, SLING_POINT_Y+newY);
                
                NSLog(@"case1");
            }
            else
            {
                 NSLog(@"case2");
                 currentMike.position = location;
            }
        
       
        }
    }
    
    //    NSLog(@"here");
    //
    //
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

-(void)LoadNewMike
{
    if(MikeIndex <2)
    {
        MikeIndex+=1;
        
        CCAction* action = [CCMoveTo actionWithDuration:0.5f position:CGPointMake(SLING_POINT_X, SLING_POINT_Y)];
        [Mikes[MikeIndex] runAction:action];
    }
}


- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	//Add a new body/atlas sprite at the touched location
	for( UITouch *touch in touches ) {
		CGPoint location = [touch locationInView: [touch view]];
		
		if(MikeClicked)
        {
            CCPhysicsSprite* currentMike =(CCPhysicsSprite*)Mikes[MikeIndex];
            currentMike.b2Body->SetType(b2_dynamicBody);
            currentMike.b2Body->SetAwake(true);
            //currentMike.b2Body->SetLinearVelocity(<#const b2Vec2 &v#>)

            
            CGPoint location = [self convertTouchToNodeSpace: touch];
            
            float distx = (location.x - SLING_POINT_X);
            float disty = (location.y - SLING_POINT_Y);

            
            b2Vec2 v2 = b2Vec2(-distx,-disty);
            currentMike.b2Body->SetLinearVelocity(v2);
            
            [self LoadNewMike];
            
            MikeClicked = false;
        }
	}
}

@end
