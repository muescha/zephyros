//
//  SDScreenClientProxy.h
//  Zephyros
//
//  Created by Steven Degutis on 8/12/13.
//  Copyright (c) 2013 Giant Robot Software. All rights reserved.
//

#import "SDClientProxy.h"

#import "SDScreenProxy.h"

@interface SDScreenClientProxy : SDClientProxy

@property SDScreenProxy* receiver;

@end
