//
//  KSMailToURLs.m
//  Sandvox
//
//  Created by Mike Abdullah on 26/07/2012.
//  Copyright © 2012 Karelia Software
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import "KSMailtoURLs.h"

#import "KSURLQueryUtilities.h"


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
