//
//  LYTSocket.h
//  AsynsocketTest
//
//  Created by 谭建中 on 2017/4/12.
//  Copyright © 2017年 谭建中. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LYTSocket : NSObject
@property (nonatomic, assign) uint16_t port; // 端口
@property (nonatomic, copy) NSString *socketHost; // 服务器地址


+ (instancetype)sharedSocket;
- (void)startConnectSocket;

@end
