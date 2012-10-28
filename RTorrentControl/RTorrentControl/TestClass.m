//
//  TestClass.m
//  RTorrentControl
//
//  Created by Alex Nichol on 10/28/12.
//  Copyright (c) 2012 Alex Nichol. All rights reserved.
//

#import "TestClass.h"

@implementation TestClass

- (void)start {
    theSession = [[ANRPCSession alloc] initWithHost:@"107.22.194.29" port:9082 username:@"root" password:@"rtorrenthacks"];
    theSession.delegate = self;
    ANRTorrentInfoList * list = [[ANRTorrentInfoList alloc] init];
    ANRTorrentLoad * load = [[ANRTorrentLoad alloc] initWithURL:[NSURL URLWithString:@"http://torrents.thepiratebay.se/5659318/American_Poop_(The_Connecticut_Poop_Movie).5659318.TPB.torrent"]];
    [theSession pushCall:load];
    [theSession pushCall:list];
}

- (void)rpcSession:(ANRPCSession *)session call:(id<ANRPCCall>)call gotResponse:(id)response {
    NSLog(@"response: %@", response);
}

- (void)rpcSession:(ANRPCSession *)session call:(id<ANRPCCall>)call failedWithError:(NSError *)error {
    NSLog(@"error: %@", error);
}

@end
