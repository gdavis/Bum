//
//  EntityManager.h
//  EndlessRPG
//
//  Created by Grant Davis on 3/5/13.
//
//

#import <Foundation/Foundation.h>
#import "Box2D.h"

@class Component;
@class Entity;
@interface EntityManager : NSObject

- (uint32_t) generateNewEid;

- (Entity *)createEntity;
- (void)removeEntity:(Entity *)entity;

- (void)addComponent:(Component *)component toEntity:(Entity *)entity;
- (void)removeComponent:(Component *)component fromEntity:(Entity *)entity;

- (Component *)getComponentOfClass:(Class)klass forEntity:(Entity *)entity;
- (NSArray *)getAllEntitiesPosessingComponentOfClass:(Class)klass;


@property (unsafe_unretained, nonatomic) b2World *world;

- (id)initWithWorld:(b2World *)world;

+ (EntityManager *)sharedManager;

@end
