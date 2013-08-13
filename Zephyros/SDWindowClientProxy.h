//
//  SDWindowClientProxy.h
//  Zephyros
//
//  Created by Steven Degutis on 8/12/13.
//  Copyright (c) 2013 Giant Robot Software. All rights reserved.
//

#import "SDClientProxy.h"

#import "SDWindowProxy.h"

@interface SDWindowClientProxy : SDClientProxy

@property SDWindowProxy* receiver;

@end
