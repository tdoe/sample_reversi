//
//  OseroFactory.h
//  sample
//
//  Created by tdoe on 2013/05/13.
//  Copyright (c) 2013年 tdoe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "StoneLabel.h"

@interface OseroFactory : NSObject

+(StoneLabel *) createStoneLabel:(NSString *)text :(int)tag :(int)x :(int)y;

@end
