//
//  main.m
//  RTorrentControl
//
//  Created by Alex Nichol on 10/28/12.
//  Copyright (c) 2012 Alex Nichol. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TestClass.h"

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        
        TestClass * class = [[TestClass alloc] init];
        [class start];
        
        [[NSRunLoop currentRunLoop] run];
        
    }
    return 0;
}

