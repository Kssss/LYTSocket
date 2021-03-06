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

/**
 连接服务器

 @param port 端口号
 @param host 主机
 */
- (void)startConnectSocket:(uint16_t)port host:(NSString *)host;

/**
 监听端口号

 @param prot 端口号
 */
- (void)startAcceptOnPort:(uint16_t) prot;
@end
