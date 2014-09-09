//
//  UniqueRandomObjectGetter.m
//  KrushDemo
//
//  Created by Atif Khan on 8/28/14.
//  Copyright (c) 2014 Norq Solutions. All rights reserved.
//

#import "UniqueRandomObjectGetter.h"

@interface UniqueRandomObjectGetter(){

}
@property (nonatomic, strong) id lastFetchedItem;
@property (nonatomic, strong) NSSet *setOfItems;
@property (nonatomic, strong) NSMutableSet *setOfUnFetchedItems;
@end

@implementation UniqueRandomObjectGetter

-(instancetype )initWithObjects:(NSSet *)setOfItems{
    if (setOfItems.count == 0) {
        return nil;
    }
    self = [super init];
    self.setOfItems = setOfItems;
    self.setOfUnFetchedItems = [setOfItems mutableCopy];
    return self;
}

-(id )getRandomItem{
    
    if (_setOfUnFetchedItems.count == 0) {
        self.setOfUnFetchedItems = [_setOfItems mutableCopy];
        if (_setOfUnFetchedItems.count>1) {
            [_setOfUnFetchedItems removeObject:_lastFetchedItem];
        }
    }
    
    if (_setOfUnFetchedItems.count >0) {
        NSArray *unfetchedItems = _setOfUnFetchedItems.allObjects;
        int randomIndex         = arc4random()%unfetchedItems.count;
        id item                 = unfetchedItems[randomIndex];
        [_setOfUnFetchedItems removeObject:item];
        self.lastFetchedItem    = item;
        return item;
    }
    return nil;

}

- (id)copyWithZone:(NSZone *)zone{
    UniqueRandomObjectGetter *copy = [[UniqueRandomObjectGetter alloc] initWithObjects:_setOfItems];
    return copy;
}

@end
