//
//  UniqueRandomObjectGetter.h
//  KrushDemo
//
//  Created by Atif Khan on 8/28/14.
//  Copyright (c) 2014 Norq Solutions. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UniqueRandomObjectGetter : NSObject<NSCopying>

-(instancetype )initWithObjects:(NSSet *)setOfItems;

-(id )getRandomItem;



@end
