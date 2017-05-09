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

@interface AsyncOperation ()

@property (strong, nonatomic) NSRecursiveLock *recursiveLock;

@end

@implementation AsyncOperation {
    BOOL        executing;
    BOOL        finished;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        executing = NO;
        finished = NO;
        _recursiveLock = [[NSRecursiveLock alloc] init];
        _recursiveLock.name = [NSString stringWithFormat:@"com.strongself.%@-lock", [self class]];
    }
    return self;
}

#pragma mark - Getters

- (BOOL)isAsynchronous {
    return YES;
}

- (BOOL)isExecuting {
    [self.recursiveLock lock];
    BOOL result = executing;
    [self.recursiveLock unlock];
    
    return result;
}

- (BOOL)isFinished {
    [self.recursiveLock lock];
    BOOL result = finished;
    [self.recursiveLock unlock];
    
    return result;
}

#pragma mark - NSOperation overrides

- (void)start {
    /**
     @author Egor Tolstoy
     
     Always check, if the operation was cancelled before the start
     */
    if ([self isCancelled]) {
        /**
         @author Egor Tolstoy
         
         If it was cancelled, we are switching it to finished state
         */
        [self complete];
        return;
    } else if ([self isReady]) {
        /**
         @author Egor Tolstoy
         
         If it wasn't cancelled and wasn't started manually, we're beginning the task
         */
        [self lockedMarkStarted];
        [NSThread detachNewThreadSelector:@selector(main) toTarget:self withObject:nil];
    }
}

- (void)main {
    [NSException raise:NSInternalInconsistencyException
                format:@"You should override the method %@ in a subclass", NSStringFromSelector(_cmd)];
}

#pragma mark - Utils

- (void)changeValueForKey:(NSString *)key inBlock:(void(^)())block {
    [self willChangeValueForKey:key];
    block();
    [self didChangeValueForKey:key];
}

- (void)lock:(void(^)())block {
    [self.recursiveLock lock];
    block();
    [self.recursiveLock unlock];
}

#pragma mark - State management

- (void)markFinished {
    [self changeValueForKey:NSStringFromSelector(@selector(isFinished)) inBlock:^{
        finished = YES;
    }];
}

- (void)markStarted {
    [self changeValueForKey:NSStringFromSelector(@selector(isExecuting)) inBlock:^{
        executing = YES;
    }];
}

- (void)lockedMarkStarted {
    [self lock:^{
        [self markStarted];
    }];
}

- (void)markComplete {
    [self changeValueForKey:NSStringFromSelector(@selector(isExecuting)) inBlock:^{
        executing = NO;
    }];
}

- (void)complete {
    /**
     @author Egor Tolstoy
     
     We should always manually setup finished and executing flags after the operation is complete or cancelled
     */
    [self lock:^{
        [self markComplete];
        [self markFinished];
    }];
}

@end
