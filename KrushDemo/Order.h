//
//  Order.h
//  KrushDemo
//
//  Created by Atif Khan on 9/4/14.
//  Copyright (c) 2014 Norq Solutions. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Order : NSObject
@property (nonatomic, strong) NSString *orderID;
@property (nonatomic, strong) NSString *customerName;
@property (nonatomic, strong) NSString *shipperCity;
@property (nonatomic, strong) NSNumber *isShipped;

-(instancetype )initWithDictionary:(NSDictionary *)info;

@end
