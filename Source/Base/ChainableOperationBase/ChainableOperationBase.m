// Copyright (c) 2016 RAMBLER&Co
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "ChainableOperationBase.h"

@implementation ChainableOperationBase

#pragma mark - Constructor

@synthesize input = _input;
@synthesize output = _output;
@synthesize delegate = _delegate;


#pragma mark - Template method

- (void)main {
    // Step 1: Obtain expected input data class.
    Class inputDataClass = [self inputDataClass];
    
    // Step 2: Validate input data and obtain it if can.
    id inputData = [self obtainInputDataWithClassValidation:inputDataClass];
    
    // Step 3: Process input data and return the new one with completion block.
    [self processInputData:inputData
           completionBlock:^(id processedData, NSError *error) {
               
               // Step 4: Complete operation and output new data.
               [self completeWithData:processedData
                                error:error];
           }];
}

#pragma mark - Step 1

- (Class _Nullable)inputDataClass {
    [NSException raise:NSInternalInconsistencyException
                format:@"You should override the method %@ in a subclass", NSStringFromSelector(_cmd)];
    return Nil;
}


#pragma mark - Step 2

- (id _Nullable)obtainInputDataWithClassValidation:(Class _Nullable)inputDataClass {
    if (inputDataClass == Nil) {
        return nil;
    }
    
    id inputData = [self.input obtainInputDataWithTypeValidationBlock:^BOOL(id _Nullable data) {
        return [data isKindOfClass:inputDataClass];
    }];
    return inputData;
}


#pragma mark - Step 3

- (void)processInputData:(id _Nullable)inputData
         completionBlock:(ChainableOperationBaseOutputDataBlock _Nonnull)completionBlock {
    
    [NSException raise:NSInternalInconsistencyException
                format:@"You should override the method %@ in a subclass", NSStringFromSelector(_cmd)];
}


#pragma mark - Step 4

- (void)completeWithData:(id _Nullable)data
                   error:(NSError * _Nullable)error {
    
    id outputData = (data != nil) ? data : [NSNull null];
    [self.output didCompleteChainableOperationWithOutputData:outputData];
    
    [self.delegate didCompleteChainableOperationWithError:error];
    [self complete];
}


#pragma mark - <NSCopying>

- (instancetype)copyWithZone:(NSZone *)zone {
    id copy = [[[self class] alloc] init];
    return copy;
}

@end
