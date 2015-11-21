//
//  NSArray+Extension.m
//  My15
//
//  Created by 贺剑峰 on 15/11/20.
//  Copyright © 2015年 hjfrun. All rights reserved.
//

#import "NSArray+Extension.h"

@implementation NSArray (Extension)

- (NSArray *) randomizedArray {
    NSMutableArray *results = [NSMutableArray arrayWithArray:self];
    
    int i = [results count];
    while(--i > 0) {
        int j = rand() % (i+1);
        [results exchangeObjectAtIndex:i withObjectAtIndex:j];
    }
    
    return [NSArray arrayWithArray:results];
}

- (NSArray *)shuffledArray
{
    NSMutableArray *shuffledArray = [self mutableCopy];
    NSUInteger arrayCount = [shuffledArray count];
    
    for (NSUInteger i = arrayCount - 1; i > 0; i--) {
        NSUInteger n = arc4random_uniform(i + 1);
        [shuffledArray exchangeObjectAtIndex:i withObjectAtIndex:n];
    }
    return [shuffledArray copy];
}

- (NSArray *)shuffledArrayWithItemLimit:(NSUInteger)itemLimit
{
    if (!itemLimit) return [self shuffledArray];
    
    NSMutableArray *shuffledArray = [self mutableCopy];
    NSUInteger arrayCount = [shuffledArray count];
    
    NSUInteger loopCounter = 0;
    for (NSUInteger i = arrayCount - 1; i > 0 && loopCounter < itemLimit; i--) {
        NSUInteger n = arc4random_uniform(i + 1);
        [shuffledArray exchangeObjectAtIndex:i withObjectAtIndex:n];
        loopCounter++;
    }
    
    NSArray *arrayWithLimit;
    if (arrayCount > itemLimit) {
        NSRange arraySlice = NSMakeRange(arrayCount - loopCounter, loopCounter);
        arrayWithLimit = [shuffledArray subarrayWithRange:arraySlice];
    } else
        arrayWithLimit = [shuffledArray copy];
    
    return arrayWithLimit;
}

@end
