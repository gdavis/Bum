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
        
        b2Body *body = render.node.body;
        
        // make sure a body is defined for an object with movement
        assert(body != nil);
        
        // apply velocity
//        b2Vec2 vel = b2Vec2(move.velocity.x, move.velocity.y);
//        body->SetLinearVelocity(vel);
        b2Vec2 linearVelocity = body->GetLinearVelocity();
        
        
        // get the position from box2d to cocos2d and update the sprite
        render.node.position = [LevelHelperLoader metersToPoints:body->GetPosition()];
        render.node.rotation = -1 * CC_RADIANS_TO_DEGREES(body->GetAngle());
    }
}


#pragma mark - Character Movement

- (void)walkWithDirection:(CGPoint)direction
{
    Entity *player = [[self.entityManager getAllEntitiesPosessingComponentOfClass:[PlayerComponent class]] lastObject];
    
    float walkSpeed = .75f;
    
    b2Body *body = player.render.node.body;
    b2Vec2 moveSpeed = b2Vec2(walkSpeed * direction.x, 0.f);
    
    body->ApplyLinearImpulse(moveSpeed, player.render.node.body->GetPosition());
    
    
    CGPoint velocity = player.movement.velocity;
    velocity.x += player.movement.acceleration.x * walkSpeed * direction.x;
    
    if (velocity.x > player.movement.maxVelocity) {
        velocity.x = player.movement.maxVelocity;
    }
    
//    player.movement.velocity = velocity;
    
//    NSLog(@"player velocity: %@", NSStringFromCGPoint(velocity));
    
    if (velocity.x >= 0) player.render.node.scaleX = 1.0;
    else player.render.node.scaleX = -1.0;
}

@end
