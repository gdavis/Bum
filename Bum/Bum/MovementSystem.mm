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

- (void)update:(float)dt
{
    NSArray *moveEntities = [self.entityManager getAllEntitiesPosessingComponentOfClass:[MovementComponent class]];
    
    for (Entity *entity in moveEntities) {
        
        MovementComponent *move = (MovementComponent*)[self.entityManager getComponentOfClass:[MovementComponent class] forEntity:entity];
        RenderComponent *render = (RenderComponent*)[self.entityManager getComponentOfClass:[RenderComponent class] forEntity:entity];
        
        if (!move || !render) return;
        
//        CGPoint vector = ccpSub(move.target, render.node.position);
//        float distance = ccpLength(vector);
//        
//        // stop moving after small distances
//        if (distance < fabsf(0.01)) {
//            render.node.position = move.target;
//            return;
//        }
        
        render.node.position =  move.target = ccpAdd(render.node.position, ccpMult(move.velocity, dt));
        
        NSLog(@"map width: %.2f", _tileMap.mapSize.width);
        
        float posX = MIN(_tileMap.mapSize.width * _tileMap.tileSize.width - render.centerToSides, MAX(render.centerToSides, move.target.x));
        float posY = MIN(3 * _tileMap.tileSize.height + render.centerToBottom, MAX(render.centerToBottom, move.target.y));
        render.node.position = ccp(posX, posY);
        
        NSLog(@"velocity: %@, target: %@, node position: %@",
              NSStringFromCGPoint(move.velocity),
              NSStringFromCGPoint(move.target),
              NSStringFromCGPoint(render.node.position));
        
        
        
    }
}


#pragma mark - Character Movement

- (void)walkWithDirection:(CGPoint)direction
{
    Entity *player = [[self.entityManager getAllEntitiesPosessingComponentOfClass:[PlayerComponent class]] lastObject];
    
    float walkSpeed = 300.f;
    
    CGPoint velocity = player.movement.velocity = ccp(direction.x * walkSpeed, direction.y * walkSpeed);
    NSLog(@"player velocity: %@", NSStringFromCGPoint(velocity));
    
    if (velocity.x >= 0) player.render.node.scaleX = 1.0;
    else player.render.node.scaleX = -1.0;
}


#pragma mark - SimpleDPadDelegate

- (void)simpleDPadTouchesBegan:(SimpleDPad *)dPad
{
    Entity *player = [[self.entityManager getAllEntitiesPosessingComponentOfClass:[PlayerComponent class]] lastObject];
    player.action.actionState = ActionStateWalk;
}

- (void)simpleDPadTouchesEnded:(SimpleDPad *)dPad
{
    Entity *player = [[self.entityManager getAllEntitiesPosessingComponentOfClass:[PlayerComponent class]] lastObject];
    player.movement.velocity = CGPointZero;
    
    if (player.action.actionState == ActionStateWalk) {
        player.action.actionState = ActionStateIdle;
    }
}

- (void)simpleDPad:(SimpleDPad *)dPad didChangeDirectionTo:(CGPoint)direction
{
    [self walkWithDirection:direction];
}

- (void)simpleDPad:(SimpleDPad *)dPad isHoldingDirection:(CGPoint)direction
{
    [self walkWithDirection:direction];
}

@end
