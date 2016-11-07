//
//  SuccessChainableOperation.m
//  CompoundOperationsExampleDev
//
//  Created by Novik Gleb on 11.05.16.
//  Copyright © 2016 Novik Gleb. All rights reserved.
//

#import "SuccessChainableOperation.h"

@implementation SuccessChainableOperation

- (Class _Nullable)inputDataClass {
    return [NSObject class];
}

- (void)processInputData:(id _Nullable)inputData
         completionBlock:(ChainableOperationBaseOutputDataBlock _Nonnull)completionBlock {
    
    if (completionBlock != nil) {
        completionBlock(inputData, nil);
    }
}


@end
