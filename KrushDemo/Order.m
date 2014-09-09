//
//  Order.m
//  KrushDemo
//
//  Created by Atif Khan on 9/4/14.
//  Copyright (c) 2014 Norq Solutions. All rights reserved.
//

#import "Order.h"

@implementation Order

-(id )valueFromDictionary:(NSDictionary *)dictionary key:(NSString *)key{
    if (!key) {
        return nil;
    }
    id value = dictionary[key];
    if ([value isKindOfClass:[NSNull class]]) {
        return nil;
    }
    return value;
}

-(instancetype )initWithDictionary:(NSDictionary *)info{
    self = [super init];
    
    if (self) {
        self.orderID        = [self valueFromDictionary:info key:@"orderID"];
        self.customerName   = [self valueFromDictionary:info key:@"customerName"];
        self.shipperCity    = [self valueFromDictionary:info key:@"shipperCity"];
        self.isShipped      = [self valueFromDictionary:info key:@"isShipped"] ;
    }
    return self;
}

@end
