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

#import "NSOperationQueue+CustomQueue.h"

@implementation NSOperationQueue (CustomQueue)

+ (instancetype)coo_suspendedOperationQueueWithMaximumConcurentOperations {
    
    return [self coo_operationQueueWithMaximumConcurentOperationsAndSuspendedState:YES];
}

+ (instancetype)coo_operationQueueWithMaximumConcurentOperations {
    
    return [self coo_operationQueueWithMaximumConcurentOperationsAndSuspendedState:NO];
}

#pragma mark - Private methods

+ (instancetype)coo_operationQueueWithMaximumConcurentOperationsAndSuspendedState:(BOOL)suspended {
    NSOperationQueue *queue = [NSOperationQueue new];
    
    [queue setUniqueQueueName];
    queue.maxConcurrentOperationCount = NSOperationQueueDefaultMaxConcurrentOperationCount;
    [queue setSuspended:suspended];
    
    return queue;
}

#pragma mark - Helpers

static NSString * const coo_uniqueQueueNameFormat = @"%@.%@-%@.queue <%@>";

- (void)setUniqueQueueName {
    NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
    NSString *className = NSStringFromClass([self class]);
    NSString *uuid = [[NSUUID UUID] UUIDString];
    NSString *objectAddress = [NSString stringWithFormat:@"%p", self];
    
    self.name = [NSString stringWithFormat:coo_uniqueQueueNameFormat,
                 bundleIdentifier, className, uuid, objectAddress];
}

@end
