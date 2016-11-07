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

#import "CompoundOperation.h"

// Dependencies
#import "OperationChainConfigurator.h"

// Internal components
#import "OperationBuffer.h"
#import "ChainableOperation.h"

// Default dependencies' implementation
#import "OperationChainConfiguratorImplementation.h"

// Categories
#import "NSOperationQueue+CustomQueue.h"

@interface CompoundOperation ()

// Dependencies
@property (nonatomic, strong) NSOperationQueue *queue;
@property (nonatomic, strong) id<OperationChainConfigurator> configurator;

// Configuration
@property (nonatomic, strong) id inputData;
@property (nonatomic, copy) NSArray<AsyncOperation<ChainableOperation> *> *chainableOperationsPrototype;
@property (nonatomic, copy) CompoundOperationResultBlock resultBlock;

// Internal components and data
@property (nonatomic, assign) BOOL isConfigured;
@property (nonatomic, strong) id<OperationBuffer> outputBuffer;

@end

@implementation CompoundOperation

#pragma mark - Constructor

+ (instancetype)defaultCompoundOperation {
    NSOperationQueue *queue = [NSOperationQueue coo_suspendedOperationQueueWithMaximumConcurentOperations];
    id<OperationChainConfigurator> configurator = [OperationChainConfiguratorImplementation defaultOperationChainConfigurator];
    
    return [self compoundOperationWithOperationQueue:queue
                                        configurator:configurator];
}

+ (instancetype _Nonnull)compoundOperationWithOperationQueue:(NSOperationQueue * _Nonnull)queue
                                                configurator:(id<OperationChainConfigurator> _Nonnull)configurator {
   
    return [[self alloc] initWithOperationQueue:queue
                                   configurator:configurator];
}

- (instancetype)initWithOperationQueue:(NSOperationQueue * _Nonnull)queue
                          configurator:(id<OperationChainConfigurator> _Nonnull)configurator {
    
    self = [super init];
    if (self) {
        // Dependencies
        _queue = queue;
        _configurator = configurator;
        
        // Internal preparation
        _isConfigured = NO;
    }
    return self;
}

- (void)setChainableOperations:(NSArray<AsyncOperation<ChainableOperation> *> *)chainableOperationsPrototype {
    if (_chainableOperationsPrototype == chainableOperationsPrototype) {
        return;
    }
    
    _chainableOperationsPrototype = [[NSArray alloc] initWithArray:chainableOperationsPrototype copyItems:YES];
}

#pragma mark - Configurator

- (void)configureWithChainableOperations:(NSArray<AsyncOperation<ChainableOperation> *> * _Nonnull)chainableOperations {
    
    [self configureWithChainableOperations:chainableOperations
                                 inputData:nil];
}

- (void)configureWithChainableOperations:(NSArray<AsyncOperation<ChainableOperation> *> * _Nonnull)chainableOperations
                               inputData:(id _Nullable)inputData {
    
    [self configureWithChainableOperations:chainableOperations
                                 inputData:inputData
                               resultBlock:nil];
}

- (void)configureWithChainableOperations:(NSArray<AsyncOperation<ChainableOperation> *> * _Nonnull)chainableOperations
                             resultBlock:(CompoundOperationResultBlock _Nullable)resultBlock {
    
    [self configureWithChainableOperations:chainableOperations
                                 inputData:nil
                               resultBlock:resultBlock];
}

- (void)configureWithChainableOperations:(NSArray<AsyncOperation<ChainableOperation> *> * _Nonnull)chainableOperations
                               inputData:(id _Nullable)inputData
                             resultBlock:(CompoundOperationResultBlock _Nullable)resultBlock {
    
    // Checking parameters
    NSAssert(chainableOperations != nil, @"Array of suboperations must not be nil");
    
    // Configuration
    self.chainableOperationsPrototype = chainableOperations;
    self.resultBlock = resultBlock;
    self.inputData = inputData;
    
    self.outputBuffer = [self.configurator configureOperationsChain:chainableOperations
                                                      withInputData:inputData];
    
    [self addSuboperationsToQueue:chainableOperations];

    // Finally
    self.isConfigured = YES;
}

- (void)addSuboperationsToQueue:(NSArray<id<ChainableOperation>> *)operations {
    for (AsyncOperation<ChainableOperation> *operation in operations) {
        [self.queue addOperation:operation];
        operation.delegate = self;
    }
}


#pragma mark - Execution

- (void)main {
    NSAssert(self.isConfigured == YES, @"Compound operation must be configured before execution.");
    
    [self.queue setSuspended:NO];
}

- (void)cancel {
    // We should cancel the operation only if it's executing
    if (![self isFinished] && ![self isCancelled]) {
        [super cancel];
        
        if ([self isExecuting]) {
            [self finishCompoundOperationExecution];
        }
    }
}


#pragma mark - <ChainableOperationDelegate>

- (void)didCompleteChainableOperationWithError:(NSError *)error {
    id data = [self.outputBuffer obtainOperationQueueOutputData];
    
    /**
     @author Egor Tolstoy
     
     We should finish the operation in two cases:
     - If an error occures,
     - When the queue is finished (queueOutput is not nil)
     */
    if (error || data) {
        [self completeOperationWithData:data
                                  error:error];
    }
}


#pragma mark - Private methods

- (void)completeOperationWithData:(id)data error:(NSError *)error {
    [self finishCompoundOperationExecution];
    
    if (self.resultBlock) {
        self.resultBlock(data, error);
    }
}

- (void)finishCompoundOperationExecution {
    [self.queue setSuspended:YES];
    [self.queue cancelAllOperations];
    
    [self complete];
}


#pragma mark - <NSCopying>

- (instancetype)copyWithZone:(NSZone *)zone {
    NSOperationQueue *queue = [NSOperationQueue coo_suspendedOperationQueueWithMaximumConcurentOperations];
    id<OperationChainConfigurator> configurator = [self.configurator copyWithZone:nil];
    
    CompoundOperation *copy = [[[self class] allocWithZone:zone] initWithOperationQueue:queue
                                                                           configurator:configurator];
    
    NSArray<AsyncOperation<ChainableOperation> *> *chainableOperationsCopy =
        [[NSArray alloc] initWithArray:self.chainableOperationsPrototype copyItems:YES];
    
    [copy configureWithChainableOperations:chainableOperationsCopy
                                 inputData:self.inputData
                               resultBlock:self.resultBlock];

    
    return copy;
}


@end
