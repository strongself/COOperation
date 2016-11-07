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

#import "DataFlowOperationChainer.h"

// Used classes
#import "AsyncOperation.h"

// Used protocols
#import "ChainableOperation.h"
#import "OperationBuffer.h"
#import "OperationBufferFactory.h"

// Default implementations
#import "OperationBufferFactoryImplementation.h"

@interface DataFlowOperationChainer ()
@property (nonatomic, strong) id<OperationBufferFactory> bufferFactory;
@end

@implementation DataFlowOperationChainer

#pragma mark - Constructor

+ (instancetype)defaultDataFlowOperationChainer {
    id<OperationBufferFactory> bufferFactory = [OperationBufferFactoryImplementation new];
    return [self dataFlowOperationChainerWithBufferFactory:bufferFactory];
}

+ (instancetype)dataFlowOperationChainerWithBufferFactory:(id<OperationBufferFactory>)bufferFactory {
    return [[self alloc] initWithBufferFactory:bufferFactory];
}

- (instancetype)initWithBufferFactory:(id<OperationBufferFactory>)bufferFactory {
    self = [super init];
    if (self) {
        _bufferFactory = bufferFactory;
    }
    return self;
}

#pragma mark - <OperationChainer>

- (void)chainOperation:(__kindof AsyncOperation<ChainableOperation> * _Nonnull)firstOperation
         withOperation:(__kindof AsyncOperation<ChainableOperation> * _Nonnull)secondOperation {
    
    // Connect the control flow
    [secondOperation addDependency:firstOperation];
    
    // Connect the data flow
    id<OperationBuffer> buffer = [self.bufferFactory createChainableOperationsBuffer];
    firstOperation.output = buffer;
    secondOperation.input = buffer;
}


#pragma - <NSCopying>

- (instancetype)copyWithZone:(NSZone *)zone {
    id<OperationBufferFactory> bufferFactory = [self.bufferFactory copyWithZone:nil];
    DataFlowOperationChainer *copy = [[[self class] allocWithZone:zone] initWithBufferFactory:bufferFactory];
    
    return copy;
}
@end
