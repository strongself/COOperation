// Copyright (c) 2016 RAMBLER&Co
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import <Foundation/Foundation.h>

// Base class and protocol
#import "AsyncOperation.h"
#import "ChainableOperationDelegate.h"

// Dependencies protocols
@protocol ChainableOperation;
@protocol OperationChainConfigurator;

/**
 @author Novik Gleb
 
 Completion block for the sequence of compound operation's suboperations.
 
 @remark One of the parameters is nil. It depends on whether the operation has succeeded or not.
 
 @param data  Output data of compound operation.
 @param error Error of one of the suboperations.
 */
typedef void(^CompoundOperationResultBlock)(id _Nullable data, NSError * _Nullable error);

/**
 @author Novik Gleb
 
 Chainable operation's container that handles errors in operations chain.
 
 @remark To use this component you should initialize, configure and put it into your own OperationQueue.
 */
@interface CompoundOperation : AsyncOperation <ChainableOperationDelegate, NSCopying>

#pragma mark - Constructor

/**
 @author Novik Gleb
 
 Designated initializer for default compound opeartion.
 
 @return An instance of compound operation.
 */
+ (instancetype _Nonnull)defaultCompoundOperation;

/**
 @author Novik Gleb
 
 Designated initializer with custom dependencies injection.
 
 @param queue         Internal operation queue
 @param configurator  Operations chain configurator
 
 @return An instance of compound operation.
 */
+ (instancetype _Nonnull)compoundOperationWithOperationQueue:(NSOperationQueue * _Nonnull)queue
                                                configurator:(id<OperationChainConfigurator> _Nonnull)configurator;

- (instancetype _Nonnull)init __attribute__((unavailable("Use designated initializer instead")));


#pragma mark - Configuration

/**
 @author Novik Gleb
 
 Method for configuration the compound opeartion.
 
 @remark Use this method before sending compound operation to the operation queue.
 
 @param chainableOperations Array of chainable operations (probably, subclasses of ChainableOperationsBase class)
 */
- (void)configureWithChainableOperations:(NSArray<AsyncOperation<ChainableOperation> *> * _Nonnull)chainableOperations;

/**
 @author Novik Gleb
 
 Method for configuration the compound opeartion.
 
 @remark Use this method before sending compound operation to the operation queue.
 
 @param chainableOperations Array of chainable operations (probably, subclasses of ChainableOperationsBase class)
 @param inputData           Data for the first chainable operation
 */
- (void)configureWithChainableOperations:(NSArray<AsyncOperation<ChainableOperation> *> * _Nonnull)chainableOperations
                               inputData:(id _Nullable)inputData;

/**
 @author Novik Gleb
 
 Method for configuration the compound opeartion.
 
 @remark Use this method before sending compound operation to the operation queue.
 
 @param chainableOperations Array of chainable operations (probably, subclasses of ChainableOperationsBase class)
 @param resultBlock         Completion block that is called after the completion of last chainable operation with its output data
 */
- (void)configureWithChainableOperations:(NSArray<AsyncOperation<ChainableOperation> *> * _Nonnull)chainableOperations
                             resultBlock:(CompoundOperationResultBlock _Nullable)resultBlock;

/**
 @author Novik Gleb
 
 Method for configuration the compound opeartion.
 
 @remark Use this method before sending compound operation to the operation queue.
 
 @param chainableOperations Array of chainable operations (probably, subclasses of ChainableOperationsBase class)
 @param inputData           Data for the first chainable operation
 @param resultBlock         Completion block that is called after the completion of last chainable operation with its output data
 */
- (void)configureWithChainableOperations:(NSArray<AsyncOperation<ChainableOperation> *> * _Nonnull)chainableOperations
                               inputData:(id _Nullable)inputData
                             resultBlock:(CompoundOperationResultBlock _Nullable)resultBlock;

@end
