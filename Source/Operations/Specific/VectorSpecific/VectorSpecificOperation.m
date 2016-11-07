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

#import "VectorSpecificOperation.h"

// Components
#import "OperationBuffer.h"

// Dependencies
#import "OperationBufferFactory.h"

// Default implementations
#import "OperationBufferFactoryImplementation.h"

// Categories
#import "NSOperationQueue+CustomQueue.h"

@interface VectorSpecificOperation () <ChainableOperationDelegate>

// Dependencies
@property (nonatomic, strong) ChainableOperationBase *usedOperation;
@property (nonatomic, strong) NSOperationQueue *queue;
@property (nonatomic, strong) id<OperationBufferFactory> bufferFactory;

@end

@implementation VectorSpecificOperation

#pragma mark - Constructor

+ (instancetype _Nonnull)vectorSpecificOperationWithChainableOperation:(ChainableOperationBase * _Nonnull)operation {
    
    NSOperationQueue *queue = [NSOperationQueue coo_operationQueueWithMaximumConcurentOperations];
    id<OperationBufferFactory> bufferFactory = [OperationBufferFactoryImplementation new];
    
    return [[self alloc] initWithChainableOperation:operation
                                     operationQueue:queue
                                      bufferFactory:bufferFactory];
}

- (instancetype _Nonnull)initWithChainableOperation:(ChainableOperationBase * _Nonnull)operation
                                     operationQueue:(NSOperationQueue *)operationQueue
                                      bufferFactory:(id<OperationBufferFactory>)bufferFactory {
    
    self = [super init];
    if (self) {
        _usedOperation = operation;
        _queue = operationQueue;
        _bufferFactory = bufferFactory;
    }
    return self;
}


#pragma mark - Execution

- (Class _Nullable)inputDataClass {
    return [NSArray class];
}

- (void)processInputData:(NSArray  * _Nullable)inputData
         completionBlock:(ChainableOperationBaseOutputDataBlock _Nonnull)completionBlock; {
    
    NSMutableArray<ChainableOperationBase *> *concurentOperations = [NSMutableArray new];
    
    for (id inputDataObject in inputData) {
        ChainableOperationBase *currentOperation = [self.usedOperation copy];
        
        id<OperationBuffer> buffer = [self.bufferFactory createChainableOperationsBuffer];
        [buffer setOperationQueueInputData:inputDataObject];
        
        currentOperation.input = buffer;
        currentOperation.delegate = self;
        
        [concurentOperations addObject:currentOperation];
    }
    
    [self.queue addOperations:concurentOperations waitUntilFinished:YES];
    
    if (completionBlock) {
        completionBlock(nil, nil);
    }
}


#pragma mark - <ChainableOperationDelegate>

- (void)didCompleteChainableOperationWithError:(NSError * _Nullable)error {
    if (error != nil) {
        [self.queue cancelAllOperations];
        [self complete];
        
        [self.delegate didCompleteChainableOperationWithError:error];
    }
}

@end
