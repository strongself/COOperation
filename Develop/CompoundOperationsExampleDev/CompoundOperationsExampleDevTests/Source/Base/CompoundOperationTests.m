//
//  CompoundOperationTests.m
//  CompoundOperationsExampleDev
//
//  Created by Novik Gleb on 11.05.16.
//  Copyright © 2016 Novik Gleb. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock.h>

// Test class
#import "CompoundOperation.h"

// Dependencies
#import "OperationChainConfigurator.h"

// Internal
#import "ChainableOperationBase.h"
#import "SuccessChainableOperation.h"
#import "FailureChainableOperation.h"

#import "OperationChainConfiguratorImplementation.h"
#import "NSOperationQueue+CustomQueue.h"

@interface CompoundOperationTests : XCTestCase

// Test object
@property (nonatomic, strong) CompoundOperation *compoundOperation;

//Mocks
@property (nonatomic, strong) id mockOperationQueue;
@property (nonatomic, strong) id mockChainConfigurator;

// Internal
@property (nonatomic, strong) NSArray<ChainableOperationBase *> *chainableOperations;

@end

@implementation CompoundOperationTests

- (void)setUp {
    [super setUp];
    
    self.mockOperationQueue = OCMClassMock([NSOperationQueue class]);
    self.mockChainConfigurator = OCMProtocolMock(@protocol(OperationChainConfigurator));
    
    self.compoundOperation = [CompoundOperation compoundOperationWithOperationQueue:self.mockOperationQueue
                                                                       configurator:self.mockChainConfigurator];
    
    ChainableOperationBase *firstOperation = [SuccessChainableOperation new];
    ChainableOperationBase *secondOperation = [FailureChainableOperation new];
    ChainableOperationBase *thirdOperation = [SuccessChainableOperation new];
    self.chainableOperations = @[firstOperation, secondOperation, thirdOperation];
}

- (void)tearDown {
    self.chainableOperations = nil;
    
    [self.mockOperationQueue stopMocking];
    self.mockOperationQueue = nil;
    
    self.mockChainConfigurator = nil;
    
    self.compoundOperation = nil;
    
    [super tearDown];
}

#pragma mark - Unit test

- (void)testThatCompoundOperationUsesConfiguratorWhenConfigurated {
    // given
    NSData *inputData = [NSData new];

    // when
    [self.compoundOperation configureWithChainableOperations:self.chainableOperations inputData:inputData];
    
    //then
    OCMVerify([self.mockChainConfigurator configureOperationsChain:self.chainableOperations withInputData:inputData]);
}

- (void)testThatCompoundOperationAddOperationsToQueueWhenConfigurated {
    // given

    // when
    [self.compoundOperation configureWithChainableOperations:self.chainableOperations];
    
    //then
    for (ChainableOperationBase *operation in self.chainableOperations) {
        OCMVerify([self.mockOperationQueue addOperation:operation]);
    }
}

- (void)testThatCompoundOperationIsDelegateOfAllOperationsWhenConfigurated {
    // given

    // when
    [self.compoundOperation configureWithChainableOperations:self.chainableOperations];
    
    //then
    for (ChainableOperationBase *operation in self.chainableOperations) {
        XCTAssertEqualObjects(operation.delegate, self.compoundOperation);
    }
}

- (void)testThatCompoundOperationCancellsCorrectly {
    // given
    NSData *inputData = [NSData new];
    
    // when
    [self.compoundOperation configureWithChainableOperations:self.chainableOperations inputData:inputData];
    [self.compoundOperation cancel];
    
    // then
    OCMVerify([self.mockOperationQueue setSuspended:YES]);
    OCMVerify([self.mockOperationQueue cancelAllOperations]);
}


#pragma mark - Integration tests

- (void)testThatCompoundOperationUseResultBlockWhenPassed {
    // given
    self.compoundOperation = [CompoundOperation defaultCompoundOperation];
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"Compound operation finished."];
    
    // when
    __block BOOL result = NO;
    [self.compoundOperation configureWithChainableOperations:self.chainableOperations
                                                   inputData:[NSData new]
                                                 resultBlock:^(id  _Nullable data, NSError * _Nullable error) {
                                                     
                                                     result = YES;
                                                     [expectation fulfill];
                                                 }];
    [self.compoundOperation start];
    
    //then
    [self waitForExpectationsWithTimeout:0.1 handler:^(NSError * _Nullable error) {
        XCTAssertTrue(result);
    }];
}

- (void)testThatCompoundOperationCallsResultBlockWithErrorWhenOneOfTheSuboperationsHasFailured {
    // given
    self.compoundOperation = [CompoundOperation defaultCompoundOperation];
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"Compound operation finished."];
    
    // when
    __block NSError *outputError;
    [self.compoundOperation configureWithChainableOperations:self.chainableOperations
                                                   inputData:[NSData new]
                                                 resultBlock:^(id  _Nullable data, NSError * _Nullable error) {
                                                     
                                                     outputError = error;
                                                     [expectation fulfill];
                                                 }];
    [self.compoundOperation start];
    
    //then
    [self waitForExpectationsWithTimeout:0.1 handler:^(NSError * _Nullable error) {
        XCTAssertNotNil(outputError);
    }];
}

- (void)testThatCompoundOperationCancelOtherSuboperationsWhenOneOfTheSuboperationsHasFailured {
    // given
    id partialMockQueue = OCMPartialMock([NSOperationQueue coo_suspendedOperationQueueWithMaximumConcurentOperations]);
    OCMStub([partialMockQueue cancelAllOperations]).andForwardToRealObject();
    
    self.compoundOperation =
        [CompoundOperation compoundOperationWithOperationQueue:partialMockQueue
                                                  configurator:[OperationChainConfiguratorImplementation defaultOperationChainConfigurator]];
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"Compound operation finished."];
    
    // when
    [self.compoundOperation configureWithChainableOperations:self.chainableOperations
                                                   inputData:[NSData new]
                                                 resultBlock:^(id  _Nullable data, NSError * _Nullable error) {
                                                     
                                                     [expectation fulfill];
                                                 }];
    [self.compoundOperation start];
    
    //then
    [self waitForExpectationsWithTimeout:0.1 handler:^(NSError * _Nullable error) {
        OCMVerify([partialMockQueue cancelAllOperations]);
    }];
    
    [partialMockQueue stopMocking];
}

- (void)testThatCompoundOperationIsCopiable {
    // given
    
    // when
    [self.compoundOperation configureWithChainableOperations:self.chainableOperations
                                                   inputData:nil];
    CompoundOperation *copy = [self.compoundOperation copy];
    
    //then
    XCTAssertTrue([copy isMemberOfClass:[self.compoundOperation class]]);
    XCTAssertNotEqual(self.compoundOperation, copy);
}

- (void)testThatCompoundOperationCopiesDependenciesWhenCopied {
    // given
    NSData *inputData = [NSData new];
    
    id mockCopiedConfigurator = OCMProtocolMock(@protocol(OperationChainConfigurator));
    OCMStub([self.mockChainConfigurator copyWithZone:[OCMArg anyPointer]]).andReturn(mockCopiedConfigurator);
    
    // when
    [self.compoundOperation configureWithChainableOperations:self.chainableOperations
                                                   inputData:inputData];
    [self.compoundOperation copy];
    
    //then
    OCMVerify([self.mockChainConfigurator copyWithZone:[OCMArg anyPointer]]);
    OCMVerify([mockCopiedConfigurator configureOperationsChain:OCMOCK_ANY withInputData:inputData]);
}

@end
