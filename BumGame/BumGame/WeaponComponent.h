//
//  WeaponComponent.h
//  Bum
//
//  Created by Grant Davis on 4/5/13.
//
//

#import "Component.h"

@interface WeaponComponent : Component

- (id)initWithSprite:(CCSprite *)sprite
               range:(float)range
              damage:(float)dmg
        areaOfEffect:(BOOL)aoe;

@property (strong, nonatomic) CCSprite *sprite;

@property (nonatomic) float range;
@property (nonatomic) float damage;
@property (nonatomic) float projectileSpeed;
@property (nonatomic) float fireRate;
@property (nonatomic) float lastFireTime;

@property (nonatomic) float animationDuration;
@property (nonatomic) BOOL isAreaOfEffectDamage;
@property (nonatomic) CGPoint weaponPosition; // default is (.5, .5). position is percent based within the bounding box

@property (strong, nonatomic) NSString *projectileName;
@property (strong, nonatomic) CCSprite *weapon;

@end
