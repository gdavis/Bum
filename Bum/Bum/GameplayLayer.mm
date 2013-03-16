//
//  GameplayLayer.m
//  Bum
//
//  Created by Grant Davis on 3/10/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "GameplayLayer.h"
#import "EntityManager.h"
#import "EntityFactory.h"
#import "HealthSystem.h"
#import "RenderComponent.h"
#import "MovementComponent.h"
#import "MovementSystem.h"
#import "Box2D.h"
#import "GLES-Render.h"
#import "ActionSystem.h"
#import "ActionComponent.h"
#import "SimpleDPad.h"


typedef enum {
    DepthLevelBackground = 0,
    DepthLevelMainMap,
    DepthLevelCharacters
} DepthLevel;

@interface GameplayLayer () {
    
    // cocos2d
    CCSpriteBatchNode *_batchNode;
    CCTMXTiledMap *_tileMap;
    
    // box2d
    b2World* world;
    GLESDebugDraw *m_debugDraw;
    
    // entity system
    EntityManager *_entityManager;
    EntityFactory *_entityFactory;
    
    HealthSystem *_healthSystem;
    MovementSystem *_movementSystem;
    ActionSystem *_actionSystem;
    
    Entity * _player;
    Entity * _enemy;
}

@end

@implementation GameplayLayer


- (id)init
{
    if (self = [super init]) {
        [self setup];
        [self createGameObjects];
    }
    return self;
}


- (void)setHud:(HUDLayer *)hud
{
    if (_hud) {
        _hud.dPad.delegate = nil;
    }
    
    _hud = hud;
    _hud.dPad.delegate = _movementSystem;
}


- (void)setup
{
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"bum.plist"];
    
    _batchNode = [CCSpriteBatchNode batchNodeWithFile:@"bum.pvr.ccz"];
    [self addChild:_batchNode z:DepthLevelCharacters];
    
    [self initBackground];
    [self initTileMap];
//    [self initPhysics];
    [self scheduleUpdate];
}


- (void)initBackground
{
//    CCSprite *background = [CCSprite spriteWithSpriteFrameName:@"background.png"];
//    background.position = ccp(background.contentSize.width * .5, background.contentSize.height * .5);
//    [self addChild:background z:DepthLevelBackground];
}


- (void)initTileMap
{
    _tileMap = [[CCTMXTiledMap alloc] initWithTMXFile:@"pd_tilemap.tmx"];
    for (CCTMXLayer *child in [_tileMap children]) {
        // This method ensures that anti-aliasing is turned off for all the textures used in the tiled map,
        // so that you can retain the pixel-like style of the textures even when the map is scaled.
        [[child texture] setAliasTexParameters];
    }
    [self addChild:_tileMap z:DepthLevelMainMap];
}


-(void) initPhysics
{
	CGSize s = [[CCDirector sharedDirector] winSize];
	
	b2Vec2 gravity;
	gravity.Set(0.0f, -10.0f);
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
	
	groundBox.Set(b2Vec2(0,0), b2Vec2(s.width/PTM_RATIO,0));
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


- (void)createGameObjects
{
    _entityManager = [[EntityManager alloc] init];
    _entityFactory = [[EntityFactory alloc] initWithEntityManager:_entityManager batchNode:_batchNode];
    
    [self createGameSystems];
    [self addHero];
    [self addEnemy];
}

- (void)createGameSystems
{
    _healthSystem = [[HealthSystem alloc] initWithEntityManager:_entityManager entityFactory:_entityFactory];
    _movementSystem = [[MovementSystem alloc] initWithEntityManager:_entityManager entityFactory:_entityFactory tileMap:_tileMap];
    _actionSystem = [[ActionSystem alloc] initWithEntityManager:_entityManager entityFactory:_entityFactory];
}


- (void)addHero
{
    _player = [_entityFactory createHumanPlayer];
    RenderComponent * humanRender = _player.render;
    MovementComponent *movement = _player.movement;
    
    CGPoint humanStartPoint = ccp(humanRender.centerToSides, humanRender.centerToBottom);
    if (humanRender) {
        humanRender.node.position = humanStartPoint;
    }
    if (movement) {
        movement.target = humanStartPoint;
    }
}

- (void)addEnemy
{
    _enemy = [_entityFactory createAIPlayer];
    RenderComponent *aiRenderer = _enemy.render;
    if (aiRenderer) {
        aiRenderer.node.position = ccp(SCREEN.width, aiRenderer.centerToBottom);
    }
}


- (void)update:(ccTime)dt
{
    //It is recommended that a fixed time step is used with Box2D for stability
	//of the simulation, however, we are using a variable time step here.
	//You need to make an informed choice, the following URL is useful
	//http://gafferongames.com/game-physics/fix-your-timestep/
	
//	int32 velocityIterations = 8;
//	int32 positionIterations = 1;
	
	// Instruct the world to perform a single step of simulation. It is
	// generally best to keep the time step and iterations fixed.
//	world->Step(dt, velocityIterations, positionIterations);
    
    
    [_movementSystem update:dt];
    [_healthSystem update:dt];
    [_actionSystem update:dt];
}

- (void)draw
{
    [_healthSystem draw];
}


@end
