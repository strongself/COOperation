//
//  DoublingOperation.m
//  CompoundOperationsExampleDev
//
//  Created by Novik Gleb on 27.04.16.
//  Copyright © 2016 Novik Gleb. All rights reserved.
//

#import "DoublingOperation.h"

@implementation DoublingOperation

- (Class)inputDataClass {
    return [NSNumber class];
}

- (void)processInputData:(NSNumber *)inputData
         completionBlock:(void(^)(id processedData, NSError *error))completionBlock {
    
    NSNumber *oldNumber = inputData;
    NSNumber *newNumber = @([oldNumber unsignedIntegerValue] * 2);
    if (completionBlock) {
        completionBlock(newNumber, nil);
    }
}
@end
