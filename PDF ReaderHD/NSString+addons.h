//
//  NSString+addons.h
//  Wallpapers
//
//  Created by Alejando M on 7/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (addons)
+ (NSString *)getMD5FromString:(NSString *)source;
+ (NSString*)getMd5:(NSString*)source;
@end
