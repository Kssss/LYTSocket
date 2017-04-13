//
//  ViewController.m
//  LYTSocketServer
//
//  Created by 谭建中 on 2017/4/13.
//  Copyright © 2017年 谭建中. All rights reserved.

#import "ViewController.h"
#import "LYTSocket.h"
@interface ViewController ()


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    LYTSocket *sock = [LYTSocket sharedSocket];
    [sock startAcceptOnPort:5528];
    
}


@end
