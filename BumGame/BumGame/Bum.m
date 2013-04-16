//
//  Bum.m
//  BumGame
//
//  Created by Grant Davis on 4/13/13.
//
//

#import "Bum.h"
#import "MovementComponent.h"

@implementation Bum

- (void)didLoadFromCCB
{
    NSLog(@"Bum loaded, sprite: %@", sprite);
    [self addComponent:[[MovementComponent alloc] init]];
}

@end