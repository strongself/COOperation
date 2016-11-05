//
//  OperationBufferImplementationTests.m
//  CompoundOperationsExampleDev
//
//  Created by Novik Gleb on 11.05.16.
//  Copyright © 2016 Novik Gleb. All rights reserved.
//

#import <XCTest/XCTest.h>

// Test class
#import "OperationBufferImplementation.h"

@interface OperationBufferImplementationTests : XCTestCase
@property (nonatomic, strong) OperationBufferImplementation *buffer;
@end

@implementation OperationBufferImplementationTests

- (void)setUp {
    [super setUp];
    
    self.buffer = [OperationBufferImplementation new];
}

- (void)tearDown {
    self.buffer = nil;
    
    [super tearDown];
}


- (void)testThatBufferPassOutputDataToNextInput {
    // given
    NSData *outputData = [NSData new];
    
    // when
    [self.buffer didCompleteChainableOperationWithOutputData:outputData];
    id inputData = [self.buffer obtainInputDataWithTypeValidationBlock:nil];
    
    //then
    XCTAssertEqualObjects(outputData, inputData);
}

- (void)testThatBufferPassQueueInputDataToNextInput {
    // given
    NSData *queueInputData = [NSData new];
    
    // when
    [self.buffer setOperationQueueInputData:queueInputData];
    id inputData = [self.buffer obtainInputDataWithTypeValidationBlock:nil];
    
    //then
    XCTAssertEqualObjects(queueInputData, inputData);
}

- (void)testThatBufferPassLastOutputDataToQueueOutput {
    // given
    NSData *outputData = [NSData new];
    
    // when
    [self.buffer didCompleteChainableOperationWithOutputData:outputData];
    id queueOutputData = [self.buffer obtainOperationQueueOutputData];
    
    //then
    XCTAssertEqualObjects(outputData, queueOutputData);
}

- (void)testThatCorrectDataPassesValidation {
    // given
    NSData *outputData = [NSData new];
    
    // when
    [self.buffer didCompleteChainableOperationWithOutputData:outputData];
    
    //then
    [self.buffer obtainInputDataWithTypeValidationBlock:^BOOL(id  _Nullable data) {
        return YES;
    }];
}
@end
