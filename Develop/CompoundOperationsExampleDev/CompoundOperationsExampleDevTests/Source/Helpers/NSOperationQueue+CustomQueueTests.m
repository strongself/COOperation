//
//  NSOperationQueue+CustomQueueTests.m
//  CompoundOperationsExampleDev
//
//  Created by Novik Gleb on 10.05.16.
//  Copyright © 2016 Novik Gleb. All rights reserved.
//

#import <XCTest/XCTest.h>

// Test class
#import "NSOperationQueue+CustomQueue.h"

@interface NSOperationQueue_CustomQueueTests : XCTestCase
@end

@implementation NSOperationQueue_CustomQueueTests

#pragma mark - Common (Unique queue names)

- (void)testThatNotSuspendedQueuesHaveUniqueNames {
    // given
    NSUInteger count = 100;
    
    // when
    NSMutableArray<NSOperationQueue *> *queues = [NSMutableArray new];
    NSMutableArray<NSString *> *queueNames = [NSMutableArray new];
    
    for (NSUInteger i = 0; i < count; i++) {
        NSOperationQueue *newQueue = [NSOperationQueue coo_operationQueueWithMaximumConcurentOperations];
        [queues addObject:newQueue];
        [queueNames addObject:newQueue.name];
    }
    
    NSSet<NSString *> *queueNamesSet = [NSSet setWithArray:[queueNames copy]];
    
    // then
    XCTAssertEqual(queueNamesSet.count, queueNames.count);
}

- (void)testThatSuspendedQueuesHaveUniqueNames{
    // given
    NSUInteger count = 100;
    
    // when
    NSMutableArray<NSOperationQueue *> *queues = [NSMutableArray new];
    NSMutableArray<NSString *> *queueNames = [NSMutableArray new];
    
    for (NSUInteger i = 0; i < count; i++) {
        NSOperationQueue *newQueue = [NSOperationQueue coo_suspendedOperationQueueWithMaximumConcurentOperations];
        [queues addObject:newQueue];
        [queueNames addObject:newQueue.name];
    }
    
    NSSet<NSString *> *queueNamesSet = [NSSet setWithArray:[queueNames copy]];
    
    // then
    XCTAssertEqual(queueNamesSet.count, queueNames.count);
}


#pragma mark - Not suspended queue factory method

- (void)testThatNotSuspendedQueueIsCreatedWithCorrectClass {
    // given
    
    // when
    NSOperationQueue *queue = [NSOperationQueue coo_operationQueueWithMaximumConcurentOperations];
    
    // then
    XCTAssertEqual([queue class], [NSOperationQueue class]);
}

- (void)testThatNotSuspendedQueueIsCreatedWithMaximumConcurentOperationCount {
    // given
    
    // when
    NSOperationQueue *queue = [NSOperationQueue coo_operationQueueWithMaximumConcurentOperations];
    
    // then
    XCTAssertEqual(queue.maxConcurrentOperationCount, NSOperationQueueDefaultMaxConcurrentOperationCount);
}

- (void)testThatNotSuspendedQueueIsCreatedWithSuspendedStateSetToNo{
    // given
    
    // when
    NSOperationQueue *queue = [NSOperationQueue coo_operationQueueWithMaximumConcurentOperations];
    
    // then
    XCTAssertFalse(queue.suspended);
}


#pragma mark - Not suspended queue factory method

- (void)testThatSuspendedQueueIsCreatedWithCorrectClass {
    // given
    
    // when
    NSOperationQueue *queue = [NSOperationQueue coo_suspendedOperationQueueWithMaximumConcurentOperations];
    
    // then
    XCTAssertEqual([queue class], [NSOperationQueue class]);
}

- (void)testThatSuspendedQueueIsCreatedWithMaximumConcurentOperationCount {
    // given
    
    // when
    NSOperationQueue *queue = [NSOperationQueue coo_suspendedOperationQueueWithMaximumConcurentOperations];
    
    // then
    XCTAssertEqual(queue.maxConcurrentOperationCount, NSOperationQueueDefaultMaxConcurrentOperationCount);
}

- (void)testThatSuspendedQueueIsCreatedWithSuspendedStateSetToNo{
    // given
    
    // when
    NSOperationQueue *queue = [NSOperationQueue coo_suspendedOperationQueueWithMaximumConcurentOperations];
    
    // then
    XCTAssertTrue(queue.suspended);
}

@end
