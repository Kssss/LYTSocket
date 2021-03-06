//
//  LYTSocket.m
//  AsynsocketTest
//
//  Created by 谭建中 on 2017/4/12.
//  Copyright © 2017年 谭建中. All rights reserved.
//

#import "LYTSocket.h"
#import "LYTGCDAsyncSocket.h"
@interface LYTSocket ()<LYTGCDAsyncSocketDelegate>

@property (nonatomic, strong) LYTGCDAsyncSocket *asyncSocket;
@property (nonatomic, strong) NSMutableArray *clientSockets;// 客户端socket


@end

@implementation LYTSocket
+ (instancetype)sharedSocket {
    static LYTSocket *scoket;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        scoket = [[self alloc] init];
    });
    return scoket;
}
- (instancetype)init {
    if (self = [super init]) {
        _asyncSocket = [[LYTGCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
    }
    return self;
}
- (NSMutableArray *)clientSockets{
    if (_clientSockets == nil) {
        _clientSockets = @[].mutableCopy;
    }
    return _clientSockets;
}
- (void)startConnectSocket:(uint16_t)port host:(NSString *)host {
    NSError *error = nil;
    _socketHost = host;
    _port = port;
   bool result =  [_asyncSocket connectToHost:self.socketHost onPort:self.port error:&error];

    if (!error && result) {
        NSLog(@"连接服务开启成功");
    } else {
        NSLog(@"连接服务开启失败 %@", error);
    }
}
- (void)startAcceptOnPort:(uint16_t) prot{
    NSError *error = nil;
    self.port = prot;
    BOOL result =  [_asyncSocket acceptOnPort:self.port error:&error];
    
    if (!error && result) {
        NSLog(@"服务器服务开启成功");
    } else {
        NSLog(@"服务器服务开启失败 %@", error);
    }

}
- (void)reconect{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_global_queue(0, 0), ^{
       [self startConnectSocket:self.port host:self.socketHost];
    });
}
#pragma mark - LYTGCDAsyncSocketDelegate
/**
 * This method is called immediately prior to socket:didAcceptNewSocket:.
 * It optionally allows a listening socket to specify the socketQueue for a new accepted socket.
 * If this method is not implemented, or returns NULL, the new accepted socket will create its own default queue.
 *
 * Since you cannot autorelease a dispatch_queue,
 * this method uses the "new" prefix in its name to specify that the returned queue has been retained.
 *
 * Thus you could do something like this in the implementation:
 * return dispatch_queue_create("MyQueue", NULL);
 *
 * If you are placing multiple sockets on the same queue,
 * then care should be taken to increment the retain count each time this method is invoked.
 *
 * For example, your implementation might look something like this:
 * dispatch_retain(myExistingQueue);
 * return myExistingQueue;
 **/
//- (nullable dispatch_queue_t)newSocketQueueForConnectionFromAddress:(NSData *)address onSocket:(LYTGCDAsyncSocket *)sock{
//    
//}

/**
 * Called when a socket accepts a connection.
 * Another socket is automatically spawned to handle it.
 *
 * You must retain the newSocket if you wish to handle the connection.
 * Otherwise the newSocket instance will be released and the spawned connection will be closed.
 *
 * By default the new socket will have the same delegate and delegateQueue.
 * You may, of course, change this at any time.
 **/
- (void)socket:(LYTGCDAsyncSocket *)sock didAcceptNewSocket:(LYTGCDAsyncSocket *)newSocket{
    NSLog(@"服务端  %@", sock);
    NSLog(@"客户端  %@", newSocket);
    [self.clientSockets addObject:newSocket];
    
    //监听客户端 写入消息
    [newSocket readDataWithTimeout:-1 tag:0];
    
    //写入欢迎语
    NSData *data = [@"欢迎来到 LYTSocketServer！！！！\n" dataUsingEncoding:NSUTF8StringEncoding];
    
    [newSocket writeData:data withTimeout:-1 tag:0];
    
    
    
}

/**
 * Called when a socket has completed reading the requested data into memory.
 * Not called if there is an error.
 **/
- (void)socket:(LYTGCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag{
    NSLog(@"客户端  %@", sock);
    NSString *dataStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"data --- %@", dataStr);
    [sock readDataWithTimeout:-1 tag:0];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_global_queue(0, 0), ^{
        [sock writeData:data withTimeout:-1 tag:0];
    });
}

/**
 * Called when a socket has completed writing the requested data. Not called if there is an error.
 **/
- (void)socket:(LYTGCDAsyncSocket *)sock didWriteDataWithTag:(long)tag{
    NSLog(@"didWriteDataWithTag - %@",sock);
}
- (void)socketDidCloseReadStream:(LYTGCDAsyncSocket *)sock{
    
}

- (void)socketDidDisconnect:(LYTGCDAsyncSocket *)sock withError:(nullable NSError *)err{
    NSLog(@"socketDidDisconnect%@",sock);
    [self reconect];
}

/**
 * Called after the socket has successfully completed SSL/TLS negotiation.
 * This method is not called unless you use the provided startTLS method.
 *
 * If a SSL/TLS negotiation fails (invalid certificate, etc) then the socket will immediately close,
 * and the socketDidDisconnect:withError: delegate method will be called with the specific SSL error code.
 **/
- (void)socketDidSecure:(LYTGCDAsyncSocket *)sock{
    
}

/**
 * Allows a socket delegate to hook into the TLS handshake and manually validate the peer it's connecting to.
 *
 * This is only called if startTLS is invoked with options that include:
 * - LYTGCDAsyncSocketManuallyEvaluateTrust == YES
 *
 * Typically the delegate will use SecTrustEvaluate (and related functions) to properly validate the peer.
 *
 * Note from Apple's documentation:
 *   Because [SecTrustEvaluate] might look on the network for certificates in the certificate chain,
 *   [it] might block while attempting network access. You should never call it from your main thread;
 *   call it only from within a function running on a dispatch queue or on a separate thread.
 *
 * Thus this method uses a completionHandler block rather than a normal return value.
 * The completionHandler block is thread-safe, and may be invoked from a background queue/thread.
 * It is safe to invoke the completionHandler block even if the socket has been closed.
 **/
- (void)socket:(LYTGCDAsyncSocket *)sock didReceiveTrust:(SecTrustRef)trust
completionHandler:(void (^)(BOOL shouldTrustPeer))completionHandler{
    
}

@end
