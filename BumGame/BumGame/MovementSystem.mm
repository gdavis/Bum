//
//  MovementSystem.m
//  Bum
//
//  Created by Grant Davis on 3/13/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "MovementSystem.h"
#import "MovementComponent.h"
#import "RenderComponent.h"
#import "PlayerComponent.h"
#import "ActionComponent.h"

@implementation MovementSystem

- (id)initWithEntityManager:(EntityManager *)entityManager
              entityFactory:(EntityFactory *)entityFactory
                      world:(b2World *)world
{
    if (self = [super initWithEntityManager:entityManager entityFactory:entityFactory]) {
        _world = world;
    }
    return self;
}

- (void)update:(float)dt
{
    NSArray *moveEntities = [self.entityManager getAllEntitiesPosessingComponentOfClass:[MovementComponent class]];
    
//    for (Entity *entity in moveEntities) {
//        
//        MovementComponent *move = [entity movement];
//        RenderComponent *render = [entity render];
//        
//        if (!move || !render) continue;
//        
//        move.velocity = ccpMult(move.velocity, move.friction);
//        move.rotationVelocity *= move.friction;
//        
//        // get the position from box2d to cocos2d and update the sprite
//        render.node.position = ccpAdd(render.node.position, move.velocity);
//        render.node.rotation += move.rotationVelocity;
//    }
    
    // update physics sprites in the simulation
    for(b2Body *b = _world->GetBodyList(); b; b=b->GetNext()) {
        if (b->GetUserData() != NULL) {
            CCSprite *ballData = (__bridge CCSprite *)b->GetUserData();
            ballData.position = ccp(b->GetPosition().x * PTM_RATIO,
                                    b->GetPosition().y * PTM_RATIO);
            ballData.rotation = -1 * CC_RADIANS_TO_DEGREES(b->GetAngle());
        }
    }
}

@end
