//
//  main.m
//  CIST-Sheduler-Server
//
//  Created by Dmitry Utenkov on 6/9/13.
//  Copyright (c) 2013 Coderivium. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CISTGateway.h"

int main(int argc, const char * argv[])
{

    @autoreleasepool {
        
        CISTGateway *gateway = [[CISTGateway alloc] init];
        
        [gateway getCSV];
        
        [gateway release];
        
    }
    return 0;
}

