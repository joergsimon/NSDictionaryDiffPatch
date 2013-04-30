//
//  NSArray+NSDDiffPatch.h
//  NSDictionaryDiffPatch
//
//  Created by Joerg Simon on 4/30/13.
//  Copyright (c) 2013 Know-Center GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray (NSDDiffPatch)

- (NSDictionary *)diffWithOldArray:(NSArray *)oldArray error:(NSError **)error;

@end
