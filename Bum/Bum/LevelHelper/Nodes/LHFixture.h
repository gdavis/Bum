//
//  LHFixture.h
//
//  Created by Bogdan Vladu on 4/3/12.
//  Copyright (c) 2012 Bogdan Vladu. All rights reserved.
//

#import "lhConfig.h"

#ifdef LH_USE_BOX2D
#import <Foundation/Foundation.h>
#import "cocos2d.h"
#include "Box2D.h"

@class LHSprite;
@interface LHFixture : NSObject
{
    NSString* fixtureName;
    int fixtureID;
}
@property (readonly) NSString* fixtureName;
@property (readonly) int fixtureID;

+(id)fixtureWithDictionary:(NSDictionary*)dictionary 
                      body:(b2Body*)body 
                    sprite:(LHSprite*)sprite;

+(bool) isLHFixture:(id)object;//in order to test if the user data from a b2Fixture object is really a LHFixture;
+(LHFixture*) fixtureForb2Fixture:(b2Fixture*)fix;

//this class is added as userData to b2Fixture object - it is removed when the body is removed from the sprite (on sprite dealloc or or specific body destroy)
//it should not be removed in any other way
@end
#endif
