//
//  LogStringOperation.m
//  CompoundOperationsExampleDev
//
//  Created by Novik Gleb on 28.04.16.
//  Copyright © 2016 Novik Gleb. All rights reserved.
//

#import "LogStringOperation.h"

@interface LogStringOperation ()
@property (nonatomic, strong) NSString *string;
@end

@implementation LogStringOperation

- (instancetype)initWithString:(NSString *)string
{
    self = [super init];
    if (self) {
        _string = string;
    }
    return self;
}


#pragma mark - Execution

- (Class)inputDataClass {
    return Nil;
}

- (void)processInputData:(id)inputData
         completionBlock:(void(^)(id processedData, NSError *error))completionBlock {
    
    NSLog(@"%@", self.string);
    
    if (completionBlock) {
        completionBlock(nil, nil);
    }
}


#pragma mark - <NSCopying>

- (instancetype)copyWithZone:(NSZone *)zone {
    LogStringOperation *copy = [super copyWithZone:zone];
    
    copy.string = [self.string copy];
    
    return copy;
}

@end
