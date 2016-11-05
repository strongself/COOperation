//
//  OperationBufferFactoryImplementationTests.m
//  CompoundOperationsExampleDev
//
//  Created by Novik Gleb on 16.05.16.
//  Copyright © 2016 Novik Gleb. All rights reserved.
//

#import <XCTest/XCTest.h>

// Test class
#import "OperationBufferFactoryImplementation.h"

// Internal
#import "OperationBufferImplementation.h"

@interface OperationBufferFactoryImplementationTests : XCTestCase
@property (nonatomic, strong) OperationBufferFactoryImplementation *bufferFactory;
@end

@implementation OperationBufferFactoryImplementationTests

- (void)setUp {
    [super setUp];
    
    self.bufferFactory = [OperationBufferFactoryImplementation new];
}

- (void)tearDown {
    self.bufferFactory = nil;
    
    [super tearDown];
}

- (void)testThatFactoryCreatesBufferSuccessfully {
    // given
    Class expectedClass = [OperationBufferImplementation class];
    
    // when
    id buffer = [self.bufferFactory createChainableOperationsBuffer];
    
    //then
    XCTAssertTrue([buffer isMemberOfClass:expectedClass]);
}

- (void)testThatFactoryCreatedBuffersAreDifferent {
    // given

    // when
    id buffer1 = [self.bufferFactory createChainableOperationsBuffer];
    id buffer2 = [self.bufferFactory createChainableOperationsBuffer];
    
    //then
    XCTAssertNotEqual(buffer1, buffer2);
}

- (void)testThatOperationBufferFactoryIsCopiable {
    // given
    
    // when
    OperationBufferFactoryImplementation *copy = [self.bufferFactory copyWithZone:nil];
    
    //then
    XCTAssertTrue([copy isMemberOfClass:[self.bufferFactory class]]);
    XCTAssertNotEqual(self.bufferFactory, copy);
}

@end
