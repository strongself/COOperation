//
//  ControlFlowOperationChainerTests.m
//  CompoundOperationsExampleDev
//
//  Created by Novik Gleb on 11.05.16.
//  Copyright © 2016 Novik Gleb. All rights reserved.
//

#import <XCTest/XCTest.h>

// Test class
#import "ControlFlowOperationChainer.h"

// Internal
#import "ChainableOperationBase.h"

@interface ControlFlowOperationChainerTests : XCTestCase
@property (nonatomic, strong) ControlFlowOperationChainer *chainer;
@end

@implementation ControlFlowOperationChainerTests

- (void)setUp {
    [super setUp];
    
    self.chainer = [ControlFlowOperationChainer controlFlowOperationChainer];
}

- (void)tearDown {
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

- (void)testThatControlFlowChainerIsCopiable {
    // given
    
    // when
    ControlFlowOperationChainer *copy = [self.chainer copyWithZone:nil];
    
    //then
    XCTAssertTrue([copy isMemberOfClass:[self.chainer class]]);
    XCTAssertNotEqual(self.chainer, copy);
}

@end
