//
//  ChainableOperationBaseTests.m
//  CompoundOperationsExampleDev
//
//  Created by Novik Gleb on 10.05.16.
//  Copyright © 2016 Novik Gleb. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>

// Test class
#import "ChainableOperationBase.h"

// Constants
static CGFloat const COODefaultTestTimeout = 0.1f;


@interface ChainableOperationBaseTests : XCTestCase
@property (nonatomic, strong) ChainableOperationBase *chainableOperationBase;
@property (nonatomic, strong) id chainableOperationBaseMock;

@property (nonatomic, strong) id mockChainableOperationInput;
@property (nonatomic, strong) id mockChainableOperationOutput;

@property (nonatomic, copy) NSString *data;
@property (nonatomic, copy) void(^outputDataProcessedCompletionBlock)(NSInvocation *invocation);
@end

@implementation ChainableOperationBaseTests

- (void)setUp {
    [super setUp];
    
    self.chainableOperationBase = [ChainableOperationBase new];
    self.chainableOperationBaseMock = OCMPartialMock(self.chainableOperationBase);
    
    
    self.mockChainableOperationInput = OCMProtocolMock(@protocol(ChainableOperationInput));
    self.mockChainableOperationOutput = OCMProtocolMock(@protocol(ChainableOperationOutput));
    self.chainableOperationBase.input = self.mockChainableOperationInput;
    self.chainableOperationBase.output = self.mockChainableOperationOutput;
    
    
    self.data = @"data";
   
    __weak __typeof__(self) weakSelf = self;
    self.outputDataProcessedCompletionBlock = ^(NSInvocation *invocation) {
        ChainableOperationBaseOutputDataBlock outputDataBlock;
        [invocation getArgument:&outputDataBlock atIndex:3];
        
        outputDataBlock(weakSelf.data, nil);
    };
    
    Class concreteDataClass = [self.data class];
    
    OCMStub([self.chainableOperationBaseMock inputDataClass]).andReturn(concreteDataClass);
    OCMStub([self.mockChainableOperationInput obtainInputDataWithTypeValidationBlock:OCMOCK_ANY]).andReturn(self.data);
    OCMStub([self.chainableOperationBaseMock processInputData:OCMOCK_ANY
                                              completionBlock:OCMOCK_ANY]).andDo(self.outputDataProcessedCompletionBlock);
}

- (void)tearDown {
    self.outputDataProcessedCompletionBlock = nil;
    self.data = nil;
    
    [self.mockChainableOperationInput stopMocking];
    self.mockChainableOperationInput = nil;
    
    [self.chainableOperationBaseMock stopMocking];
    self.chainableOperationBaseMock = nil;
    
    self.chainableOperationBase = nil;
    
    [super tearDown];
}

#pragma mark - Creation

- (void)testThatChainableOperationBaseIsASubclassOfAsyncOperation {
    // given
    
    // when
    BOOL isKindOfClassAsyncOperation = [self.chainableOperationBase isKindOfClass:[AsyncOperation class]];
    BOOL isMemberOfClassAsyncOperation = [self.chainableOperationBase isMemberOfClass:[AsyncOperation class]];
    
    //then
    XCTAssertTrue(isKindOfClassAsyncOperation && !isMemberOfClassAsyncOperation);
}

- (void)testThatChainableOperationBaseConformsToChainableOperationProtocol {
    // given
    
    // when
    BOOL conformsToChainableOperationProtocol  = [self.chainableOperationBase conformsToProtocol:@protocol(ChainableOperation)];
    
    //then
    XCTAssertTrue(conformsToChainableOperationProtocol);
}

- (void)testThatChainableOperationBaseConformsToNSCopyingProtocol {
    // given
    
    // when
    BOOL conformsToChainableOperationProtocol  = [self.chainableOperationBase conformsToProtocol:@protocol(NSCopying)];
    
    //then
    XCTAssertTrue(conformsToChainableOperationProtocol);
}


#pragma mark - Template method

- (void)testThatChainaleOperationBaseCallsInputDataClassMethodWhenStarted {
    // given
    XCTestExpectation *expectation = [self expectationWithDescription:@"Operation finished"];
    [self.chainableOperationBase setCompletionBlock:^{
        [expectation fulfill];
    }];
    
    // when
    [self.chainableOperationBaseMock start];
    
    // then
    [self waitForExpectationsWithTimeout:COODefaultTestTimeout handler:^(NSError * _Nullable error) {
        OCMVerify([self.chainableOperationBaseMock inputDataClass]);
    }];
}

- (void)testThatChainaleOperationBaseCallsProcessDataMethodWhenStarted {
    // given
    XCTestExpectation *expectation = [self expectationWithDescription:@"Operation finished"];
    [self.chainableOperationBase setCompletionBlock:^{
        [expectation fulfill];
    }];
    
    // when
    [self.chainableOperationBaseMock start];
    
    // then
    [self waitForExpectationsWithTimeout:COODefaultTestTimeout handler:^(NSError * _Nullable error) {
        OCMVerify([self.chainableOperationBaseMock processInputData:OCMOCK_ANY
                                                    completionBlock:OCMOCK_ANY]);
    }];
}

- (void)testThatChainaleOperationBaseCallsProcessDataMethodWithCorrectParametersWhenStarted {
    // given
    XCTestExpectation *expectation = [self expectationWithDescription:@"Operation finished"];
    [self.chainableOperationBase setCompletionBlock:^{
        [expectation fulfill];
    }];
    
    // when
    [self.chainableOperationBaseMock start];
    
    // then
    __weak __typeof__(self) weakSelf = self;
    [self waitForExpectationsWithTimeout:COODefaultTestTimeout handler:^(NSError * _Nullable error) {
        OCMVerify([weakSelf.chainableOperationBaseMock processInputData:[OCMArg checkWithBlock:^BOOL(id obj) {
                                                                        return [obj isEqual:weakSelf.data];
                                                                    }]
                                                    completionBlock:OCMOCK_ANY]);
    }];
}

- (void)testThatChainaleOperationBaseMakeCorrectOutputAfterDataProcessing {
    // given
    XCTestExpectation *expectation = [self expectationWithDescription:@"Operation finished"];
    [self.chainableOperationBase setCompletionBlock:^{
        [expectation fulfill];
    }];
    
    // when
    [self.chainableOperationBaseMock start];
    
    // then
    __weak __typeof__(self) weakSelf = self;
    [self waitForExpectationsWithTimeout:COODefaultTestTimeout handler:^(NSError * _Nullable error) {
        OCMVerify([weakSelf.mockChainableOperationOutput didCompleteChainableOperationWithOutputData:weakSelf.data]);
    }];
}

@end
