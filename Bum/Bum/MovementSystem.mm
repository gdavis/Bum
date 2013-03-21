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
#import "Box2D.h"

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
    
    for (Entity *entity in moveEntities) {
        
        MovementComponent *move = [entity movement];
        RenderComponent *render = [entity render];
        PlayerComponent *player = [entity player];
        
        if (!move || !render) continue;
        
        b2Body *b = render.node.body;
        LHSprite *myActor = (__bridge LHSprite *)b->GetUserData();
    
        if (!myActor) continue;
        
        // apply velocity
        b2Body *body = render.node.body;
        b2Vec2 vel = b2Vec2(move.velocity.x, move.velocity.y);
        body->SetLinearVelocity(vel);
        
        // get the position from box2d to cocos2d and update the sprite
        myActor.position = [LevelHelperLoader metersToPoints:b->GetPosition()];
        myActor.rotation = -1 * CC_RADIANS_TO_DEGREES(b->GetAngle());
    }
}


#pragma mark - Character Movement

- (void)walkWithDirection:(CGPoint)direction
{
    Entity *player = [[self.entityManager getAllEntitiesPosessingComponentOfClass:[PlayerComponent class]] lastObject];
    
    float walkSpeed = 40.f;
    
    CGPoint velocity = player.movement.velocity = ccp(direction.x * walkSpeed, direction.y * walkSpeed);
    NSLog(@"player velocity: %@", NSStringFromCGPoint(velocity));
    
    if (velocity.x >= 0) player.render.node.scaleX = 1.0;
    else player.render.node.scaleX = -1.0;
}

@end
