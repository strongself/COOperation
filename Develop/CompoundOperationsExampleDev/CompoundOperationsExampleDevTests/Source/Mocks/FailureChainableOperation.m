//
//  FailureChainableOperation.m
//  CompoundOperationsExampleDev
//
//  Created by Novik Gleb on 16.05.16.
//  Copyright © 2016 Novik Gleb. All rights reserved.
//

#import "FailureChainableOperation.h"

@implementation FailureChainableOperation

- (Class _Nullable)inputDataClass {
    return [NSObject class];
}

- (void)processInputData:(id _Nullable)inputData
         completionBlock:(ChainableOperationBaseOutputDataBlock _Nonnull)completionBlock {
    
    if (completionBlock != nil) {
        completionBlock(nil, [NSError errorWithDomain:@"Sample error" code:0 userInfo:nil]);
    }
}

@end
