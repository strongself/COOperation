//
//  SleepFailureChainableOperation.m
//  CompoundOperationsExampleDev
//
//  Created by Novik Gleb on 11.05.16.
//  Copyright © 2016 Novik Gleb. All rights reserved.
//

#import "SleepFailureChainableOperation.h"

static UInt32 lastWorkTime = 1;

@implementation SleepFailureChainableOperation

- (Class _Nullable)inputDataClass {
    return [NSObject class];
}

- (void)processInputData:(id _Nullable)inputData
         completionBlock:(ChainableOperationBaseOutputDataBlock _Nonnull)completionBlock {
    
    NSLog(@"Data processing started in operation: %@", self);
    sleep(self.workTime);
    NSLog(@"Data processing is finished in operation: %@", self);
    
    if (completionBlock != nil) {
        completionBlock(nil, [NSError errorWithDomain:@"Sample error" code:0 userInfo:nil]);
    }
}

- (instancetype)copyWithZone:(NSZone *)zone {
    SleepFailureChainableOperation *copy = [[[self class] alloc] init];
    
    lastWorkTime += 1;
    copy.workTime = lastWorkTime;
    
    return copy;
}

@end
