//
//  DataFlowOperationChainerTests.m
//  CompoundOperationsExampleDev
//
//  Created by Novik Gleb on 11.05.16.
//  Copyright © 2016 Novik Gleb. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>

// Test class
#import "DataFlowOperationChainer.h"

// Dependencies
#import "OperationBufferFactory.h"

// Internal
#import "ChainableOperationBase.h"
#import "OperationBufferImplementation.h"


@interface DataFlowOperationChainerTests : XCTestCase
@property (nonatomic, strong) DataFlowOperationChainer *chainer;

@property (nonatomic, strong) id<OperationBufferFactory> mockBufferFactory;
@end

@implementation DataFlowOperationChainerTests

- (void)setUp {
    [super setUp];
    
    self.mockBufferFactory = OCMProtocolMock(@protocol(OperationBufferFactory));
    OCMStub([self.mockBufferFactory createChainableOperationsBuffer]).andReturn([OperationBufferImplementation new]);
    
    self.chainer = [DataFlowOperationChainer dataFlowOperationChainerWithBufferFactory:self.mockBufferFactory];
}

- (void)tearDown {
    self.mockBufferFactory = nil;
    
    self.chainer = nil;
    
    [super tearDown];
}

- (void)testThatDependencyIsAddedWhenOperationsAreChained  {
    // given
    ChainableOperationBase *firstOperation = [ChainableOperationBase new];
    ChainableOperationBase *secondOperation = [ChainableOperationBase new];
    
    // when
    [self.chainer chainOperation:firstOperation withOperation:secondOperation];
    
    //then
    XCTAssertTrue([[secondOperation dependencies] containsObject:firstOperation]);
}

- (void)testThatChainerUsesBufferFactory {
    // given
    ChainableOperationBase *firstOperation = [ChainableOperationBase new];
    ChainableOperationBase *secondOperation = [ChainableOperationBase new];
    
    // when
    [self.chainer chainOperation:firstOperation withOperation:secondOperation];
    
    //then
    OCMVerify([self.mockBufferFactory createChainableOperationsBuffer]);
}

- (void)testThatChainerConnectsOperationsWithSameInputAndOutputBuffer {
    // given
    OCMStub([self.mockBufferFactory createChainableOperationsBuffer]).andReturn([OperationBufferImplementation new]);
    
    ChainableOperationBase *firstOperation = [ChainableOperationBase new];
    ChainableOperationBase *secondOperation = [ChainableOperationBase new];
    
    // when
    [self.chainer chainOperation:firstOperation withOperation:secondOperation];
    
    //then
    XCTAssertEqualObjects(firstOperation.output, secondOperation.input);
}

- (void)testThatDataFlowChainerIsCopiable {
    // given
    
    // when
    DataFlowOperationChainer *copy = [self.chainer copyWithZone:nil];
    
    //then
    XCTAssertTrue([copy isMemberOfClass:[self.chainer class]]);
    XCTAssertNotEqual(self.chainer, copy);
}

- (void)testThatDataFlowChainerCopiesDependenciesWhenCopied {
    // given
    
    // when
    [self.chainer copyWithZone:nil];
    
    //then
    OCMVerify([self.mockBufferFactory copyWithZone:[OCMArg anyPointer]]);
}

@end
