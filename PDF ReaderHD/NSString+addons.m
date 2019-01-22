//
//  NSString+addons.m
//  Wallpapers
//
//  Created by Alejando M on 7/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NSString+addons.h"
#import <CommonCrypto/CommonDigest.h>



@implementation NSString (addons)

+ (NSString *)getMD5FromString:(NSString *)source{
   
    NSString *str1 = [NSString stringWithFormat:@"aG8TMeJU6ThSNLET"];
    NSString *str2 =[self getMd5:source];
    NSString *rez = [self getMd5:[NSString stringWithFormat:@"%@%@",str2,str1]];
    
    return rez;
}
+ (NSString*)getMd5:(NSString*)source;{
    const char *src = [source UTF8String];
	unsigned char result[CC_MD5_DIGEST_LENGTH];
	CC_MD5(src, strlen(src), result);
    NSString *ret = [[[NSString alloc] initWithFormat:@"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X", 
					  result[0], result[1], result[2], result[3],
					  result[4], result[5], result[6], result[7],
					  result[8], result[9], result[10], result[11],
					  result[12], result[13], result[14], result[15]
					  ] autorelease];
    return [ret lowercaseString];


}

@end
