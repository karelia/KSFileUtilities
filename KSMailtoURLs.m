//
//  KSMailToURLs.m
//  Sandvox
//
//  Created by Mike on 26/07/2012.
//  Copyright (c) 2012 Karelia Software. All rights reserved.
//

#import "KSMailtoURLs.h"

#import "KSURLUtilities.h"


NSString *KSURLMailtoScheme = @"mailto";
NSString *KSURLMailtoHeaderSubject = @"subject";
NSString *KSURLMailtoHeaderBody = @"body";


@implementation NSURL (KSMailToURLs)

+ (NSURL *)ks_mailtoURLWithEmailAddress:(NSString *)address headerLines:(NSDictionary *)headers;
{
    NSScanner *s = [NSScanner scannerWithString:address];
    if ([s scanUpToString:@"(" intoString:&address])
    {
        address = [address stringByTrimmingCharactersInSet:
                   [NSCharacterSet whitespaceAndNewlineCharacterSet]];	// take out whitespace
    }
    
    NSString *string = [NSString stringWithFormat:
                        @"%@:%@",
                        KSURLMailtoScheme,
                        [address stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    if (headers)
    {
        NSString *query = [self ks_queryWithParameters:headers];
        if ([query length])
        {
            string = [string stringByAppendingFormat:@"?%@", query];
        }
    }
    
	return [self URLWithString:string];
}

- (NSDictionary *)ks_mailHeaderLines;
{
    if (![[self scheme] isEqualToString:KSURLMailtoScheme]) return nil;
    
    NSString *urlString = [self absoluteString];
    NSRange queryIndicatorRange = [urlString rangeOfString:@"?"];
    
    if (queryIndicatorRange.location != NSNotFound)
    {
        NSString *query = [urlString substringFromIndex:NSMaxRange(queryIndicatorRange)];
        return [NSURL ks_parametersOfQuery:query];
    }
    
    return nil;
}

@end
