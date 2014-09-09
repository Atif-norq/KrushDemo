//
//  BaseViewController.m
//  KrushDemo
//
//  Created by Atif Khan on 8/31/14.
//  Copyright (c) 2014 Norq Solutions. All rights reserved.
//

#import "BaseViewController.h"

@interface BaseViewController ()
@property (nonatomic, strong) NSString *titlebackup;
@end

@implementation BaseViewController


-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)setTitle:(NSString *)title{
    if (title.length>0) {
        self.titlebackup    = title;
    }
    super.title         = title;
}

-(IBAction )popViewController{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    self.titlebackup = self.title;
    self.title = @"";
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if (self.titlebackup) {
        self.title = self.titlebackup;
    }
}

@end
