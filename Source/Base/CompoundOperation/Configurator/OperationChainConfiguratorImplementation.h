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

// Base protocol
#import "OperationChainConfigurator.h"

// Dependencies
@protocol OperationChainer;
@protocol OperationBufferFactory;

/**
 @author Novik Gleb
 
 Configurator of the operations chain.
 */
@interface OperationChainConfiguratorImplementation : NSObject <OperationChainConfigurator>

/**
 @author Novik Gleb
 
 Designated initializer with default dependencies.
 
 @return OperationChainConfiguratorImplementation instance
 */
+ (instancetype _Nonnull)defaultOperationChainConfigurator;

/**
 @author Novik Gleb
 
 Designated initializer.
 
 @param chainer       Operation chainer
 @param bufferFactory Factory of operation buffers
 
 @return OperationChainConfiguratorImplementation instance
 */
+ (instancetype _Nonnull)operationChainConfiguratorWithOperationChainer:(id<OperationChainer> _Nonnull)chainer
                                                 operationBufferFactory:(id<OperationBufferFactory> _Nonnull)bufferFactory;

- (instancetype _Nonnull)init __attribute__((unavailable("Use designated initializer instead")));
@end
