//
//  FirstViewController.m
//  CompoundOperationsExampleDev
//
//  Created by Novik Gleb on 11.04.16.
//  Copyright © 2016 Novik Gleb. All rights reserved.
//

#import "FirstViewController.h"

#import "CompoundOperation.h"

#import "IncrementOperation.h"
#import "DecrementOperation.h"

@interface FirstViewController ()

@property (nonatomic, strong) NSOperationQueue *queue;

@end

@implementation FirstViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.queue = [NSOperationQueue new];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self execution];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Execution

- (void)execution {
    NSLog(@"100");
    NSArray<IncrementOperation *> *incrementOperations = [self severalIncrementOperations];
    NSArray<DecrementOperation *> *decrementOperations = [self severalDecrementOperations];
    NSLog(@"=");
    
    CompoundOperation *randomCalculating = [CompoundOperation defaultCompoundOperation];
    NSMutableArray<id<ChainableOperation>> *calculationOperations = [NSMutableArray new];
    [calculationOperations addObjectsFromArray:incrementOperations];
    [calculationOperations addObjectsFromArray:decrementOperations];
    
    [randomCalculating configureWithChainableOperations:calculationOperations
                                              inputData:@(100)
                                            resultBlock:^(id data, NSError *error) {
                                                
                                                NSLog(@"%@", data);
                                            }];
    
    
    CompoundOperation *randomCalculatingCopy = [randomCalculating copy];
    [self.queue addOperation:randomCalculating];
    [self.queue addOperation:randomCalculatingCopy];
    [self.queue addOperation:[randomCalculatingCopy copy]];
    [self.queue addOperation:[randomCalculatingCopy copy]];
    [self.queue addOperation:[randomCalculatingCopy copy]];

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.05 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        [self.queue setSuspended:YES];
        [self.queue cancelAllOperations];
        
        [self.queue addOperation:[randomCalculatingCopy copy]];
        [self.queue addOperation:[randomCalculatingCopy copy]];
        
        [self.queue setSuspended:NO];

    });
}


#pragma mark - Factory

- (NSArray<IncrementOperation *> *)severalIncrementOperations {
    IncrementOperation *incrementOperation = [IncrementOperation new];
    
    NSUInteger randCount = arc4random_uniform(10) + 500;
    NSLog(@"+%@",@(randCount));
    NSMutableArray<IncrementOperation *> *incrementOperations = [@[] mutableCopy];
    for (NSUInteger i = 0; i < randCount; i++) {
        [incrementOperations addObject:[incrementOperation copy]];
    }
    return incrementOperations;
}

- (NSArray<DecrementOperation *> *)severalDecrementOperations {
    DecrementOperation *decrementOperation = [DecrementOperation new];
    
    NSUInteger randCount = arc4random_uniform(10) + 400;
    NSLog(@"-%@",@(randCount));
    NSMutableArray<DecrementOperation *> *decrementOperations = [@[] mutableCopy];
    for (NSUInteger i = 0; i < randCount; i++) {
        [decrementOperations addObject:[decrementOperation copy]];
    }
    return decrementOperations;
}

@end
