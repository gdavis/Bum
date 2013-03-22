//
//  ControlsSystem.m
//  Bum
//
//  Created by Grant Davis on 3/22/13.
//
//

#import "ControlsSystem.h"
#import "Box2D.h"
#import "RenderComponent.h"
#import "PlayerComponent.h"
#import "ActionComponent.h"

#define ACCELERATION 10.f
#define JUMP_ACCELERATION_REDUCTION .666
#define JUMP_MAX_HOLD_TIME 1.f
#define STOP_SPEED_FRICTION .333f
#define TURN_SPEED_FRICTION .1f

typedef enum CharacterDirection {
    CharacterDirectionNone = 0,
    CharacterDirectionLeft,
    CharacterDirectionRight
} CharacterDirection;

typedef enum CharacterMoveState {
    CharacterMoveStateIdle = 0,
    CharacterMoveStateWalking,
    CharacterMoveStateRunning
} CharacterMoveState;

@interface ControlsSystem () {
    CGPoint _direction;
    CharacterDirection _characterDirection;
    CharacterMoveState _moveState;
}

@end

@implementation ControlsSystem

- (id)init
{
    if (self = [super init]) {
        _characterDirection = CharacterDirectionRight;
    }
    return self;
}

- (void)update:(float)dt
{
    b2Body *body = _playerEntity.render.node.body;
    b2Vec2 vel = body->GetLinearVelocity();
    
    // JUMPING ---------------------------------------------------------------------
    

    // MOVEMENT ---------------------------------------------------------------------
    
    // find the characters speed
    float maxVelocity;
    
    switch (_moveState) {
        case CharacterMoveStateRunning:
            maxVelocity = _playerEntity.player.runSpeed;
            break;
        case CharacterMoveStateWalking:
        default:
            maxVelocity = _playerEntity.player.walkSpeed;
            break;
    }
    
    float targetVelocity;
    switch (_characterDirection) {
        case CharacterDirectionNone:
            targetVelocity = vel.x * STOP_SPEED_FRICTION;
            break;
            
        case CharacterDirectionLeft:
            targetVelocity = b2Max( vel.x - ACCELERATION, -maxVelocity );;
            break;
            
        case CharacterDirectionRight:
            targetVelocity = b2Min( vel.x + ACCELERATION, maxVelocity );;
            break;
            
        default:
            break;
    }
    
    float velChange = (targetVelocity - vel.x) * TURN_SPEED_FRICTION;    
    float impulse = body->GetMass() * velChange;
    body->ApplyLinearImpulse( b2Vec2(impulse,0), body->GetWorldCenter() );
}

#pragma mark - Character Movement

- (void)walkWithDirection:(CGPoint)direction
{
    _moveState = CharacterMoveStateWalking;
    [self setDirection:direction];
}


- (void)runWithDirection:(CGPoint)direction
{
    _moveState = CharacterMoveStateRunning;
    [self setDirection:direction];
}


- (void)jump
{
    b2Body *body = _playerEntity.render.node.body;
    body->ApplyLinearImpulse( b2Vec2(0,50.f), body->GetWorldCenter() );
}


- (void)setDirection:(CGPoint)direction
{
    _direction = direction;
    
    if (CGPointEqualToPoint(direction, CGPointZero)) {
        _characterDirection = CharacterDirectionNone;
    }
    else if (direction.x >= 0) {
        _characterDirection = CharacterDirectionRight;
        _playerEntity.render.node.scaleX = 1.0;
    }
    else {
        _characterDirection = CharacterDirectionLeft;
        _playerEntity.render.node.scaleX = -1.0;
    }
}


#pragma mark - SimpleDPadDelegate

- (void)simpleDPadTouchesBegan:(SimpleDPad *)dPad
{
}


- (void)simpleDPadTouchesEnded:(SimpleDPad *)dPad
{
    _playerEntity.action.actionState = ActionStateIdle;
    _moveState = CharacterMoveStateIdle;
    _characterDirection = CharacterDirectionNone;
}


- (void)simpleDPad:(SimpleDPad *)dPad didChangeDirectionTo:(CGPoint)direction
{
    [self walkWithDirection:direction];
}


- (void)simpleDPad:(SimpleDPad *)dPad isHoldingDirection:(CGPoint)direction
{
    [self walkWithDirection:direction];
}



#pragma mark - GameButtonDelegate

- (void)gameButtonTouchesBegan:(GameButton *)gameButton
{
    [self jump];
}


- (void)gameButtonTouchesEnded:(GameButton *)gameButton
{
}


- (void)gameButtonTouchesDidLeave:(GameButton *)gameButton
{
}


- (void)gameButtonIsBeingHeld:(GameButton *)gameButton
{
}

@end
