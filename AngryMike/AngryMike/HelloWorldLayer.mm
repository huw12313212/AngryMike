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
    CCTexture2D *MikeTexture;
    CCTexture2D *SodasTexture;
    CCTexture2D *WhitePixelTexture;
    
	b2World* world;
	GLESDebugDraw *m_debugDraw;
    
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
        
        
		
        CGSize size = [[CCDirector sharedDirector] winSize];
        
        CCSprite* background = [CCSprite spriteWithFile:@"Background.png"];
        background.position = CGPointMake(size.width/2, size.height/2);
        [self addChild:background z:-1];
        
        
        // enable events
		self.touchEnabled = YES;
		
		// init physics
		[self initPhysics];
		

		MikeTexture = [[CCTextureCache sharedTextureCache] addImage:@"Mike.png"];
        SodasTexture =[[CCTextureCache sharedTextureCache] addImage:@"sodas.png"];
        
        WhitePixelTexture = [[CCTextureCache sharedTextureCache] addImage:@"WhitePixel.png"];
        
    
        
        CCSprite* sling1 = [CCSprite spriteWithFile:@"sling1.png"];
        CCSprite* sling2 = [CCSprite spriteWithFile:@"sling2.png"];
        
        [self addChild:sling1 z:2];
        [self addChild:sling2 z:0];
        
        sling1.position = CGPointMake(66, 155);
        sling2.position = CGPointMake(71, 167);
        
        [self addNewMikeAtPosition:CGPointMake(SLING_POINT_X,SLING_POINT_Y)];
        
        [[self addNewMikeAtPosition:CGPointMake(44.5,146)] setRotation:40.0f];
        
        [[self addNewMikeAtPosition:CGPointMake(21.5,146)]setRotation: -22.0f];
        
        
        [[self addNewSodasAtPosition:CGPointMake(275, 139)] setRotation:-17];
        [[self addNewSodasAtPosition:CGPointMake(276, 23)] setRotation:3];
        [[self addNewSodasAtPosition:CGPointMake(407, 129)] setRotation:20];
        [[self addNewSodasAtPosition:CGPointMake(407, 25)] setRotation: -32];
        [[self addNewSodasAtPosition:CGPointMake(407, 232)] setRotation:20];
        
        //包子蓋房子
        [self createRectangle:CGPointMake(238, 60) withWidth:10 andHeight:90 Rotate:0];
        [self createRectangle:CGPointMake(318, 60) withWidth:10 andHeight:90 Rotate:0];
        [self createRectangle:CGPointMake(278, 107) withWidth:100 andHeight:10 Rotate:0];
        [self createRectangle:CGPointMake(238+130, 60) withWidth:10 andHeight:90 Rotate:0];
        [self createRectangle:CGPointMake(318+130, 60) withWidth:10 andHeight:90 Rotate:0];
        [self createRectangle:CGPointMake(278+130, 107) withWidth:100 andHeight:10 Rotate:0];
        [self createRectangle:CGPointMake(238+130, 60+107) withWidth:10 andHeight:90 Rotate:0];
        [self createRectangle:CGPointMake(318+130, 60+107) withWidth:10 andHeight:90 Rotate:0];
        [self createRectangle:CGPointMake(278+130, 107+107) withWidth:100 andHeight:10 Rotate:0];
        
        
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
	

	
	b2Vec2 gravity;
	gravity.Set(0.0f, -200/PTM_RATIO);
	world = new b2World(gravity);
	
	world->SetAllowSleeping(true);
	world->SetContinuousPhysics(true);
	
    

    CGSize s = [[CCDirector sharedDirector] winSize];
	b2BodyDef groundBodyDef;

	b2Body* groundBody = world->CreateBody(&groundBodyDef);
	b2EdgeShape groundBox;
    
    //Gound
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
    
    
    m_debugDraw = new GLESDebugDraw( PTM_RATIO );
	world->SetDebugDraw(m_debugDraw);
	uint32 flags = 0;
    flags += b2Draw::e_shapeBit;
	m_debugDraw->SetFlags(flags);
	
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
	b2BodyDef bodyDef;
	bodyDef.type = b2_kinematicBody;
    bodyDef.bullet = true;
	bodyDef.position.Set(p.x/PTM_RATIO, p.y/PTM_RATIO);
	b2Body *body = world->CreateBody(&bodyDef);

	b2CircleShape Mike;
    Mike.m_radius =10.0f/PTM_RATIO;

	// Define the dynamic body fixture.
	b2FixtureDef fixtureDef;
	fixtureDef.shape = &Mike;
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

-(CCSprite*) addNewSodasAtPosition:(CGPoint)p
{
	b2BodyDef bodyDef;
	bodyDef.type = b2_dynamicBody;
    bodyDef.bullet = true;
	bodyDef.position.Set(p.x/PTM_RATIO, p.y/PTM_RATIO);
	b2Body *body = world->CreateBody(&bodyDef);
	
	// Define another box shape for our dynamic body.
    
	b2CircleShape dynamicSodas;
    dynamicSodas.m_radius =10.0f/PTM_RATIO;
    
	// Define the dynamic body fixture.
	b2FixtureDef fixtureDef;
	fixtureDef.shape = &dynamicSodas;
	fixtureDef.density = 1.0f;
	fixtureDef.friction = 0.3f;
    
	body->CreateFixture(&fixtureDef);
    
	CCPhysicsSprite *sprite = [CCPhysicsSprite spriteWithTexture:SodasTexture];
    
	[self addChild:sprite z:1];
	
	[sprite setPTMRatio:PTM_RATIO];
	[sprite setB2Body:body];
	[sprite setPosition: ccp( p.x, p.y)];
    
    [sprite setScale:0.4f];
    
    return sprite;
}


-(CCSprite*) createRectangle:(CGPoint)p withWidth :(float)width andHeight :(float)height Rotate:(float)angle
{
    b2BodyDef bodyDef;
	bodyDef.type = b2_dynamicBody;
	bodyDef.position.Set(p.x/PTM_RATIO, p.y/PTM_RATIO);
	b2Body *body = world->CreateBody(&bodyDef);
	
    
	b2PolygonShape rectangle;
    rectangle.SetAsBox(width/2.0f/PTM_RATIO, height/2.0f/PTM_RATIO);
    
	b2FixtureDef fixtureDef;
	fixtureDef.shape = &rectangle;
	fixtureDef.density = 1.0f;
    
	fixtureDef.friction = 0.3f;
	body->CreateFixture(&fixtureDef);
	
	CCPhysicsSprite *sprite = [CCPhysicsSprite spriteWithTexture:WhitePixelTexture];

	[self addChild:sprite];
	
    sprite.scaleX = width*2;
    sprite.scaleY = height*2;
    
	[sprite setPTMRatio:PTM_RATIO];
	[sprite setB2Body:body];
	[sprite setPosition: ccp( p.x, p.y)];
    [sprite setRotation:angle];
    [sprite setColor:ccc3(rand()%255,rand()%255,rand()%255)];
    
    return sprite;
}

-(void) update: (ccTime) dt
{
	int32 velocityIterations = 8;
	int32 positionIterations = 3;
	
	world->Step(dt, velocityIterations, positionIterations);	
}

- (void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    for( UITouch *touch in touches )
    {
        CGPoint location = [self convertTouchToNodeSpace: touch];
        
        NSLog(@"location = %f,%f",location.x,location.y);
        
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
                NSLog(@"case1");
                
                float normalizeX = distx / dist;
                float normalizeY = disty / dist;
                
                float newX = normalizeX*SLING_RADIO;
                float newY = normalizeY*SLING_RADIO;
                
                 currentMike.position = CGPointMake(SLING_POINT_X+newX, SLING_POINT_Y+newY);
                
            }
            else
            {
                 NSLog(@"case2");
                 currentMike.position = location;
            }
        }
    }
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

            
            b2Vec2 v2 = b2Vec2(-distx/3,-disty/3);
            currentMike.b2Body->SetLinearVelocity(v2);
            
            [self LoadNewMike];
            
            MikeClicked = false;
        }
	}
}

@end
