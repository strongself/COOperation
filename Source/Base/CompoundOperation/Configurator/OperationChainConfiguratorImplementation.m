//
//  OperationChainConfiguratorImplementation.m
//  CompoundOperationsExampleDev
//
//  Created by Novik Gleb on 10.05.16.
//  Copyright © 2016 Novik Gleb. All rights reserved.
//

#import "OperationChainConfiguratorImplementation.h"

// Dependencies
#import "OperationChainer.h"
#import "OperationBufferFactory.h"

// Internal components
#import "ChainableOperation.h"
#import "OperationBuffer.h"

// Default implementations
#import "OperationChainerFactoryImplementation.h"
#import "OperationBufferFactoryImplementation.h"

@interface OperationChainConfiguratorImplementation ()
@property (nonatomic, strong) id<OperationBufferFactory> bufferFactory;
@property (nonatomic, strong) id<OperationChainer> chainer;
@end

@implementation OperationChainConfiguratorImplementation

#pragma mark - Constructor

+ (instancetype _Nonnull)defaultOperationChainConfigurator {
    id<OperationBufferFactory> defaultBufferFactory = [OperationBufferFactoryImplementation new];
    
    id<OperationChainerFactory> defaultChainerFactory = [OperationChainerFactoryImplementation new];
    id<OperationChainer> defaultChainer = [defaultChainerFactory createDataFlowOperationChainer];
    
    return [self operationChainConfiguratorWithOperationChainer:defaultChainer
                                         operationBufferFactory:defaultBufferFactory];
}

+ (instancetype _Nonnull)operationChainConfiguratorWithOperationChainer:(id<OperationChainer> _Nonnull)chainer
                                                 operationBufferFactory:(id<OperationBufferFactory> _Nonnull)bufferFactory {
    return [[self alloc] initWithOperationChainer:chainer operationBufferFactory:bufferFactory];
}

- (instancetype)initWithOperationChainer:(id<OperationChainer>)chainer
                  operationBufferFactory:(id<OperationBufferFactory>)bufferFactory {
    self = [super init];
    if (self) {
        _bufferFactory = bufferFactory;
        _chainer = chainer;
    }
    return self;
}


#pragma mark - <OperationChainConfigurator>

- (id<OperationBuffer> _Nonnull)configureOperationsChain:(NSArray<AsyncOperation<ChainableOperation> *> * _Nonnull)chainableOperations
                                           withInputData:(id _Nullable)inputData {
    
    [self configureInputWithData:inputData
               forFirstOperation:[chainableOperations firstObject]];
    
    [self configureChainWithOperations:chainableOperations];
    
    id<OperationBuffer> outputBuffer = [self configureOutputForLastOperation:[chainableOperations lastObject]];
    return outputBuffer;
}


#pragma mark - Internal

- (void)configureInputWithData:(id)inputData forFirstOperation:(id<ChainableOperation>)firstOperation {
    id<OperationBuffer> inputBuffer = [self.bufferFactory createChainableOperationsBuffer];
    [inputBuffer setOperationQueueInputData:inputData];
    firstOperation.input = inputBuffer;
}

- (void)configureChainWithOperations:(NSArray<AsyncOperation<ChainableOperation> *> *)operations {
    for (NSUInteger index = 0; index < [operations count] - 1; index++) {
        AsyncOperation<ChainableOperation> *currentOperation = operations[index];
        AsyncOperation<ChainableOperation> *nextOperation = operations[index+1];
        
        [self.chainer chainOperation:currentOperation
                       withOperation:nextOperation];
    }
}

- (id<OperationBuffer>)configureOutputForLastOperation:(id<ChainableOperation>)lastOperation {
    id<OperationBuffer> outputBuffer = [self.bufferFactory createChainableOperationsBuffer];
    lastOperation.output = outputBuffer;
    
    return outputBuffer;
}


#pragma mark - <NSCopying>

- (instancetype)copyWithZone:(NSZone *)zone {
    id<OperationBufferFactory> bufferFactory = [self.bufferFactory copyWithZone:nil];
    id<OperationChainer> chainer = [self.chainer copyWithZone:nil];
    
    OperationChainConfiguratorImplementation *copy = [[[self class] allocWithZone:zone] initWithOperationChainer:chainer
                                                                                          operationBufferFactory:bufferFactory];
    
    return copy;
}

@end
