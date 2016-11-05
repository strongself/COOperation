//
//  SecondViewController.m
//  CompoundOperationsExampleDev
//
//  Created by Novik Gleb on 11.04.16.
//  Copyright © 2016 Novik Gleb. All rights reserved.
//

#import "SecondViewController.h"

#import "LogInputOperation.h"
#import "LogStringOperation.h"

#import "VectorSpecificOperation.h"

#import "CompoundOperation.h"

@interface SecondViewController ()
@property (nonatomic, strong) NSOperationQueue *queue;
@end

@implementation SecondViewController

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
    LogInputOperation *logInputOperation = [LogInputOperation new];
    VectorSpecificOperation *vectorLogInputOperation =
    [VectorSpecificOperation vectorSpecificOperationWithChainableOperation:logInputOperation];
    
    LogStringOperation *logStringOperation = [[LogStringOperation alloc] initWithString:@"Hey"];
    
    CompoundOperation *compoundOperation = [CompoundOperation defaultCompoundOperation];
    [compoundOperation configureWithChainableOperations:@[vectorLogInputOperation, logStringOperation]
                                              inputData:@[@1, @2, @3]];
    
    [self.queue addOperation:compoundOperation];
}

@end
