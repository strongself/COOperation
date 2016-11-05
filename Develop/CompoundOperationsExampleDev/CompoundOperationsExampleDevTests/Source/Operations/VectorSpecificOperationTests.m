//
//  VectorSpecificOperationTests.m
//  CompoundOperationsExampleDev
//
//  Created by Novik Gleb on 12.05.16.
//  Copyright © 2016 Novik Gleb. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock.h>

// Test class
#import "VectorSpecificOperation.h"

// Internal
#import "ChainableOperationBase.h"
#import "SuccessChainableOperation.h"
#import "SleepFailureChainableOperation.h"

#import "ChainableOperation.h"

@interface VectorSpecificOperationTests : XCTestCase

// Test object
@property (nonatomic, strong) VectorSpecificOperation *vectorOperation;
@property (nonatomic, strong) id partialMockVectorOperation;

// Mocks
@property (nonatomic, strong) NSArray<NSObject *> *inputDataArray;
@property (nonatomic, strong) id<ChainableOperationInput> mockChainableOperationInput;

@property (nonatomic, strong) id<ChainableOperationOutput> mockChainableOperationOutput;

@property (nonatomic, strong) id<ChainableOperationDelegate> mockChainableOperationDelegate;

@end

@implementation VectorSpecificOperationTests

- (void)setUp {
    [super setUp];
    
    // Creating mocks
    self.inputDataArray = @[[NSObject new], [NSObject new], [NSObject new]];
    self.mockChainableOperationInput = OCMProtocolMock(@protocol(ChainableOperationInput));
    OCMStub([self.mockChainableOperationInput obtainInputDataWithTypeValidationBlock:OCMOCK_ANY]).andReturn(self.inputDataArray);
    
    self.mockChainableOperationOutput = OCMProtocolMock(@protocol(ChainableOperationOutput));
    
    self.mockChainableOperationDelegate = OCMProtocolMock(@protocol(ChainableOperationDelegate));

    
    // Instantiating test object
    SuccessChainableOperation *successOperation = [SuccessChainableOperation new];
    self.vectorOperation = [VectorSpecificOperation vectorSpecificOperationWithChainableOperation:successOperation];
    self.vectorOperation.input = self.mockChainableOperationInput;
    self.vectorOperation.output = self.mockChainableOperationOutput;
    self.vectorOperation.delegate = self.mockChainableOperationDelegate;
    
    self.partialMockVectorOperation = OCMPartialMock(self.vectorOperation);
}

- (void)tearDown {
    if (self.partialMockVectorOperation != nil) {
        [self.partialMockVectorOperation stopMocking];
        self.partialMockVectorOperation = nil;
    }
    
    self.vectorOperation = nil;
    
    self.mockChainableOperationDelegate = nil;
    
    self.mockChainableOperationOutput = nil;
    
    self.mockChainableOperationInput = nil;
    self.inputDataArray = nil;
    
    [super tearDown];
}

- (void)testThatVectorOperationCompletesSeveralUsedOperationsWhenSeveralParametersPassedInInputArray {
    // given
    __block NSUInteger delegateCalls = 0;
    void(^incrementBlock)(NSInvocation *invocation) = ^(NSInvocation *invocation) {
        delegateCalls++;
    };
    OCMStub([self.partialMockVectorOperation didCompleteChainableOperationWithError:OCMOCK_ANY]).andForwardToRealObject().andDo(incrementBlock);
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"Default timeout period passed"];
    [expectation performSelector:@selector(fulfill) withObject:nil afterDelay:0.1];
    
    // when
    [self.vectorOperation start];
    
    //then
    
    [self waitForExpectationsWithTimeout:0.2
                                 handler:^(NSError * _Nullable error) {
                                     
                                     XCTAssertEqual(delegateCalls, [self.inputDataArray count]);
                                 }];
}

- (void)testThatVectorOperationCompletesSuccessfullyWhenAllSuboperationsCompleteToo {
    // given
    XCTestExpectation *expectation = [self expectationWithDescription:@"Default timeout period passed"];
    [expectation performSelector:@selector(fulfill) withObject:nil afterDelay:0.1];
    
    // when
    [self.vectorOperation start];
    
    //then
    [self waitForExpectationsWithTimeout:0.2
                                 handler:^(NSError * _Nullable error) {
                                     
                                     OCMVerify([self.mockChainableOperationDelegate didCompleteChainableOperationWithError:[OCMArg checkWithBlock:^BOOL(id obj) {
                                         return obj == nil;
                                     }]]);
                                     
                                 }];
}

- (void)testThatVectorOperationCompletesWithErrorWhenOneOrMoreSuboperationsFailed {
    // prepare
    [self.partialMockVectorOperation stopMocking];
    self.partialMockVectorOperation = nil;
    
    self.vectorOperation = nil;
    
    // given
    SleepFailureChainableOperation *failureOperation = [SleepFailureChainableOperation new];
    failureOperation.workTime = 0;
    
    self.vectorOperation = [VectorSpecificOperation vectorSpecificOperationWithChainableOperation:failureOperation];
    self.vectorOperation.input = self.mockChainableOperationInput;
    self.vectorOperation.output = self.mockChainableOperationOutput;
    self.vectorOperation.delegate = self.mockChainableOperationDelegate;
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"Default timeout period passed"];
    [expectation performSelector:@selector(fulfill) withObject:nil afterDelay:3.5];
    
    // when
    [self.vectorOperation start];
    
    //then
    [[(OCMockObject *)self.mockChainableOperationDelegate expect] didCompleteChainableOperationWithError:[OCMArg checkWithBlock:^BOOL(id obj) {
        NSLog(@"Vector:%@",obj);
        return obj != nil;
    }]];
    
    [self waitForExpectationsWithTimeout:4.0
                                 handler:^(NSError * _Nullable error) {
                                     
                                     OCMVerifyAll((OCMockObject *)self.mockChainableOperationDelegate);
                                 }];
}


@end
