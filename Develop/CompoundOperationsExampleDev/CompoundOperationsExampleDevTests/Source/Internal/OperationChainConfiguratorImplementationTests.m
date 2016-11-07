//
//  OperationChainConfiguratorImplementationTests.m
//  CompoundOperationsExampleDev
//
//  Created by Novik Gleb on 11.05.16.
//  Copyright © 2016 Novik Gleb. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock.h>

// Test class
#import "OperationChainConfiguratorImplementation.h"

// Internal
#import "OperationChainer.h"
#import "OperationBufferFactory.h"

#import "ChainableOperationBase.h"

@interface OperationChainConfiguratorImplementationTests : XCTestCase
@property (nonatomic, strong) OperationChainConfiguratorImplementation *configurator;

@property (nonatomic, strong) id mockOperationChainer;
@property (nonatomic, strong) id mockBufferFactory;
@end

@implementation OperationChainConfiguratorImplementationTests

- (void)setUp {
    [super setUp];
    
    self.mockOperationChainer = OCMProtocolMock(@protocol(OperationChainer));
    self.mockBufferFactory = OCMProtocolMock(@protocol(OperationBufferFactory));
    
    self.configurator =
        [OperationChainConfiguratorImplementation operationChainConfiguratorWithOperationChainer:self.mockOperationChainer
                                                                          operationBufferFactory:self.mockBufferFactory];
}

- (void)tearDown {
    self.mockOperationChainer = nil;
    self.mockBufferFactory = nil;
    
    self.configurator = nil;
    
    [super tearDown];
}

#pragma mark - Unit tests

- (void)testThatConfiguratorUsesChainer {
    // given
    NSData *inputData = [NSData new];
    
    ChainableOperationBase *firstOperation = [ChainableOperationBase new];
    ChainableOperationBase *secondOperation = [ChainableOperationBase new];
    ChainableOperationBase *thirdOperation = [ChainableOperationBase new];
    
    NSArray<ChainableOperationBase *> *chainableOperations = @[firstOperation, secondOperation, thirdOperation];
    
    __block NSUInteger chainCalls = 0;
    void(^incrementBlock)(NSInvocation *invocation) = ^(NSInvocation *invocation) {
        chainCalls++;
    };
    
    OCMStub([self.mockOperationChainer chainOperation:OCMOCK_ANY withOperation:OCMOCK_ANY]).andDo(incrementBlock);
    
    // when
    [self.configurator configureOperationsChain:chainableOperations
                                  withInputData:inputData];
    
    //then
    XCTAssertEqual(chainCalls, [chainableOperations count]-1);
}

- (void)testThatConfiguratorUsesBufferFactory{
    // given
    NSData *inputData = [NSData new];
    
    ChainableOperationBase *firstOperation = [ChainableOperationBase new];
    ChainableOperationBase *secondOperation = [ChainableOperationBase new];
    ChainableOperationBase *thirdOperation = [ChainableOperationBase new];
    
    NSArray<ChainableOperationBase *> *chainableOperations = @[firstOperation, secondOperation, thirdOperation];
    
    __block NSUInteger chainCalls = 0;
    void(^incrementBlock)(NSInvocation *invocation) = ^(NSInvocation *invocation) {
        chainCalls++;
    };
    
    OCMStub([self.mockBufferFactory createChainableOperationsBuffer]).andDo(incrementBlock);
    
    // when
    [self.configurator configureOperationsChain:chainableOperations
                                  withInputData:inputData];
    
    //then
    XCTAssertEqual(chainCalls, [chainableOperations count]-1);
}


#pragma mark - Integration tests

- (void)testThatConfiguratorChainsQueueInput {
    // given
    self.configurator = [OperationChainConfiguratorImplementation defaultOperationChainConfigurator];
    NSData *inputData = [NSData new];
    
    ChainableOperationBase *firstOperation = [ChainableOperationBase new];
    ChainableOperationBase *secondOperation = [ChainableOperationBase new];
    ChainableOperationBase *thirdOperation = [ChainableOperationBase new];
    
    // when
    NSArray<ChainableOperationBase *> *chainableOperations = @[firstOperation, secondOperation, thirdOperation];
    [self.configurator configureOperationsChain:chainableOperations
                                  withInputData:inputData];
    
    //then
    id queueInputData = [firstOperation.input obtainInputDataWithTypeValidationBlock:nil];
    XCTAssertEqualObjects(queueInputData, inputData);
}

- (void)testThatConfiguratorChainsQueueOutput {
    // given
    self.configurator = [OperationChainConfiguratorImplementation defaultOperationChainConfigurator];
    NSData *inputData = [NSData new];
    
    ChainableOperationBase *firstOperation = [ChainableOperationBase new];
    ChainableOperationBase *secondOperation = [ChainableOperationBase new];
    ChainableOperationBase *thirdOperation = [ChainableOperationBase new];
    
    // when
    NSArray<ChainableOperationBase *> *chainableOperations = @[firstOperation, secondOperation, thirdOperation];
    id<OperationBuffer> outputBuffer =
        [self.configurator configureOperationsChain:chainableOperations
                                      withInputData:inputData];
    
    //then
    XCTAssertEqualObjects(outputBuffer, thirdOperation.output);
}

- (void)testThatConfiguratorChainsSequence{
    // given
    self.configurator = [OperationChainConfiguratorImplementation defaultOperationChainConfigurator];
    NSData *inputData = [NSData new];
    
    ChainableOperationBase *firstOperation = [ChainableOperationBase new];
    ChainableOperationBase *secondOperation = [ChainableOperationBase new];
    ChainableOperationBase *thirdOperation = [ChainableOperationBase new];
    
    // when
    NSArray<ChainableOperationBase *> *chainableOperations = @[firstOperation, secondOperation, thirdOperation];
    [self.configurator configureOperationsChain:chainableOperations
                                  withInputData:inputData];
    
    //then
    for (NSUInteger i = 0 ; i < [chainableOperations count] - 1; i++) {
        XCTAssertEqualObjects(chainableOperations[i].output, chainableOperations[i+1].input);
    }
}

- (void)testThatOperationChainConfiguratorIsCopiable {
    // given
    
    // when
    OperationChainConfiguratorImplementation *copy = [self.configurator copyWithZone:nil];
    
    //then
    XCTAssertTrue([copy isMemberOfClass:[self.configurator class]]);
    XCTAssertNotEqual(self.configurator, copy);
}

- (void)testThatOperationChainConfiguratorCopiesDependenciesWhenCopied {
    // given
    
    // when
    [self.configurator copyWithZone:nil];
    
    //then
    OCMVerify([self.mockBufferFactory copyWithZone:[OCMArg anyPointer]]);
    OCMVerify([self.mockOperationChainer copyWithZone:[OCMArg anyPointer]]);
}

@end
