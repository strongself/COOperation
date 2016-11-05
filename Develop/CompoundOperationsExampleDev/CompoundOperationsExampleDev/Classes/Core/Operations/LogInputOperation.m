//
//  LogInputOperation.m
//  CompoundOperationsExampleDev
//
//  Created by Novik Gleb on 27.04.16.
//  Copyright © 2016 Novik Gleb. All rights reserved.
//

#import "LogInputOperation.h"

@implementation LogInputOperation

- (Class)inputDataClass {
    return [NSNumber class];
}

- (void)processInputData:(NSNumber *)inputData
         completionBlock:(void(^)(id processedData, NSError *error))completionBlock {
    
    NSLog(@"LogInputOp:%@", inputData);
    
    if (completionBlock) {
        completionBlock(nil, nil);
    }    
}

@end
