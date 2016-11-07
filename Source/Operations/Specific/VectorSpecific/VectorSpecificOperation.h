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

#import "ChainableOperationBase.h"

/**
 @author Novik Gleb
 
 This operation expects an array of data as the input.
 All objects must be of the same type.
 
 The operation will produce several concurent chainable operations to process each object.
 */
@interface VectorSpecificOperation : ChainableOperationBase

/**
 @author Novik Gleb
 
 Designated initializer.
 
 @param operation Chainable operation that will handle each of the objects form input array
 
 @return Instance of VectorSpecificOperation
 */
+ (instancetype _Nonnull)vectorSpecificOperationWithChainableOperation:(ChainableOperationBase * _Nonnull)operation;

@end
