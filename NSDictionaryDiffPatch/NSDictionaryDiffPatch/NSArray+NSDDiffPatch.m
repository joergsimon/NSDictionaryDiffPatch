//
//  NSArray+NSDDiffPatch.m
//  NSDictionaryDiffPatch
//
//  Created by Joerg Simon on 4/30/13.
//
//  Copyright (C) 2013  Know-Center GmbH
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <http://www.gnu.org/licenses/>.

#import "NSArray+NSDDiffPatch.h"

BOOL isJSONPrimitive(id obj)
{
    return (
            [obj isKindOfClass:[NSString class]] ||
            [obj isKindOfClass:[NSNumber class]] ||
            [obj isKindOfClass:[NSDate class]]
            );
}

BOOL isJSONComplex(id obj)
{
    return (
            [obj isKindOfClass:[NSDictionary class]] ||
            [obj isKindOfClass:[NSArray class]]
            );
}

BOOL isAnyJSONObject(id obj) {
    if (obj == nil || [obj isEqual:[NSNull null]]) {
        return YES; // empty values are allowed in JSON...
    }
    return (
            isJSONPrimitive(obj) ||
            isJSONComplex(obj)
            );
}

BOOL areObjectsNull(id obj1, id obj2) {
    if ((obj1 == obj2) && (obj1 == nil)) {
        return YES;
    }
    
    if ((obj1 == obj2) && ([obj1 isEqual:[NSNull null]])) {
        return YES;
    }
    return NO;
}

NSString *removalKeyForIndex(int index)
{
    return [NSString stringWithFormat:@"_%d", index];
}

NSString *additionKeyForIndex(int index)
{
    return [NSString stringWithFormat:@"%d", index];
}

Class classOfObject(id obj)
{
    // These candiates are wonderfully mututally exclusive, so we can make it easy:
    NSArray *candidates = @[[NSString class], [NSNumber class], [NSDate class], [NSDictionary class], [NSArray class]];
    if (obj == nil || [obj isEqual:[NSNull null]]) {
        return [NSNull class];
    }
    __block Class class = nil;
    [candidates enumerateObjectsUsingBlock:^(Class candidateClass, NSUInteger idx, BOOL *stop) {
        if ([obj isKindOfClass:candidateClass]) {
            class = candidateClass;
            *stop = YES;
        }
    }];
    return class;
}

#define kNSDDebugLogs YES

#define kNSDErrorDomainWrongType @"at.know-center.nsd.error.wrongtype"
#define kNSDErrorCodeWrongType -198300001
#define kNSDErrorInfoKeyWrongTypeTypeOfObje @"typeofobj"

#define kNSDErrorDomainTypeMissmatch @"at.know-center.nsd.error.typemissmatch"
#define kNSDErrorCodeTypeMissmatch -198300002
#define kNSDErrorInfoKeyTypeMissmatchTypeOfNewObj @"typeofNewObj"
#define kNSDErrorInfoKeyTypeMissmatchTypeOfOldObj @"typeofOldObj"

@implementation NSArray (NSDDiffPatch)

- (NSDictionary *)diffWithOldArray:(NSArray *)oldArray error:(NSError **)error
{
    NSMutableDictionary *changedIndexDictionary = [[NSMutableDictionary alloc] init];
    
    // @TODO: create diff
    for (int i = 0; i < MAX(self.count, oldArray.count); i++) {
        id newValue = nil;
        id oldValue = nil;
        if (i < self.count) {
            newValue = [self objectAtIndex:i];
        }
        if (i < oldArray.count) {
            oldValue = [oldArray objectAtIndex:i];
        }
        
        if (newValue == oldValue) {
            continue;
        }
        
        if ([newValue isEqual:oldValue]) {
            continue;
        }
        
        Class newClass = classOfObject(newValue);
        Class oldClass = classOfObject(oldValue);
        
        if (newClass == [NSNull class]) {
            // removed something from array
            [changedIndexDictionary setValue:@[oldValue,@(0),@(0)] forKey:removalKeyForIndex(i)];
            continue;
        }
        
        if (oldClass == [NSNull class]) {
            // we added something :)
            [changedIndexDictionary setValue:@[newValue] forKey:additionKeyForIndex(i)];
            continue;
        }
        
        if (newClass != oldClass) {
            if (kNSDDebugLogs) {
                NSLog(@"ERROR, type missmatch between new object: %@ and old object: %@ ", newClass, oldClass);
            }
            *error = [NSError errorWithDomain:kNSDErrorDomainTypeMissmatch
                                         code:kNSDErrorCodeTypeMissmatch
                                     userInfo:
                      @{kNSDErrorInfoKeyTypeMissmatchTypeOfNewObj : [newClass description],kNSDErrorInfoKeyTypeMissmatchTypeOfOldObj : [oldClass description]}];
            return nil;
        }
        
        // now the objects musst be different, for small strings, for numbers or for dates, we just exchange the objects:
        if (newClass != [NSString class]) {
            if (isJSONPrimitive(newValue)) {
                [changedIndexDictionary setValue:@[newValue,oldValue] forKey:additionKeyForIndex(i)];
            } else {
            }
            continue;
        }
        // so, we have a string here:
        NSString *newString = (NSString *)newValue;
        NSString *oldString = (NSString *)oldValue;
        
        if (newString.length > 60 || oldString.length > 60) {
            // TODO: use google diff patch
        } else {
            [changedIndexDictionary setValue:@[newValue,oldValue] forKey:additionKeyForIndex(i)];
        }
    }
    
    return changedIndexDictionary;
}

@end
