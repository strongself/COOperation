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

#import "AsyncOperation.h"
#import "ChainableOperation.h"

/**
 @author Novik Gleb
 
 Block that is called after operation has processed input data.
 
 @param processedData Output data
 @param error         Error id needed
 */
typedef void(^ChainableOperationBaseOutputDataBlock)(id _Nullable processedData, NSError * _Nullable error);

/**
 @author Novik Gleb
 
 The base class for chainable operation.
 
 The "main" method is implemented as a "Template method" software design pattern. 
 You should not override it in subclasses.
 Besides, you must override some of steps that are skeleton of this template method (you can find the interface below).
 
 
 Here are the chainable operation's data processing steps. You must override Step 1 and 3 to use this class.
 
 Step 1 (overridable): obtain input data class
 Step 2 (not overridable): validate input data
 Step 3 (overridable): proccess input data and send new data or error with completion block
 Step 4 (not overridable): complete the operation
 */
@interface ChainableOperationBase : AsyncOperation <ChainableOperation, NSCopying>

#pragma mark - Execution

/**
 @author Novik Gleb
 
 The returned Class of object is needed information to validate data between chained operations.
 Please, return Nil if your chainable operation does not use input data.
 
 @remark This method must be overriden. (Step 1)
 
 
 @return Class of expected input data.
 */
- (Class _Nullable)inputDataClass;

/**
 @author Novik Gleb
 
 @remark This method must be overriden. (Step 3)
 
 @param inputData       Data to process
 @param completionBlock Block must be called to complete the operation with processed data and error respectively.
 */
- (void)processInputData:(id _Nullable)inputData
         completionBlock:(ChainableOperationBaseOutputDataBlock _Nonnull)completionBlock;

@end
