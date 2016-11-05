//
//  FailureChainableOperation.h
//  CompoundOperationsExampleDev
//
//  Created by Novik Gleb on 11.05.16.
//  Copyright © 2016 Novik Gleb. All rights reserved.
//

#import "ChainableOperationBase.h"

@interface SleepFailureChainableOperation : ChainableOperationBase
@property (nonatomic, assign) UInt32 workTime;
@end
