//
//  LogStringOperation.h
//  CompoundOperationsExampleDev
//
//  Created by Novik Gleb on 28.04.16.
//  Copyright © 2016 Novik Gleb. All rights reserved.
//

#import "ChainableOperationBase.h"

@interface LogStringOperation : ChainableOperationBase

- (instancetype)initWithString:(NSString *)string;

@end
