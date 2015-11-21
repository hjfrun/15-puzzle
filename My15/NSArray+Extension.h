//
//  NSArray+Extension.h
//  My15
//
//  Created by 贺剑峰 on 15/11/20.
//  Copyright © 2015年 hjfrun. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray (Extension)

- (NSArray *) randomizedArray;

// Returns an array where all elements are shuffled into random order.
- (NSArray *)shuffledArray;

// Returns an array with a limited number of random elements.
// This will improve performance if you only need a few elements out of a large dataset.
- (NSArray *)shuffledArrayWithItemLimit:(NSUInteger)itemLimit;

@end
