//
//  NSDictionary+NSDDiffPatch.h
//  NSDictionaryDiffPatch
//
//  Created by Joerg Simon on 4/30/13.
//  Copyright (c) 2013 Know-Center GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (NSDDiffPatch)

- (NSDictionary *)diffWithOldDictionary:(NSDictionary *)oldDictionary;

@end
