//
//  OseroFactory.m
//  sample
//
//  Created by tdoe on 2013/05/13.
//  Copyright (c) 2013年 tdoe. All rights reserved.
//

#import "OseroFactory.h"

#define STONE_BASE_SIZE 30

@implementation OseroFactory

+(StoneLabel *) createStoneLabel:(NSString *)text :(int)tag :(int)x :(int)y
{
    StoneLabel *stoneLabel = [[StoneLabel alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    stoneLabel.text = text;
    stoneLabel.tag = tag;
    stoneLabel.frame = CGRectMake(x * STONE_BASE_SIZE + 10, y * STONE_BASE_SIZE + 40, STONE_BASE_SIZE, STONE_BASE_SIZE);
    stoneLabel.userInteractionEnabled = YES;
    stoneLabel.backgroundColor = [UIColor greenColor];
    
    if(tag == 44 || tag == 55){
        stoneLabel.backgroundColor = [UIColor blackColor];
    }else if(tag == 45 || tag == 54){
        stoneLabel.backgroundColor = [UIColor whiteColor];
    }
    
    return stoneLabel;
}

@end
