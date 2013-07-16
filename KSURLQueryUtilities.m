//
//  KSURLQueryUtilities.m
//  Sandvox
//
//  Created by Mike on 27/07/2012.
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

#import "KSURLQueryUtilities.h"


@implementation NSURL (KSURLQueryUtilities)

- (NSDictionary *)ks_queryParameters;
{
	NSDictionary *result = [[self class] ks_parametersOfQuery:[self query]];
    return result;
}

- (NSURL *)ks_URLWithQueryParameters:(NSDictionary *)parameters;
{
	NSString *query = [NSURL ks_queryWithParameters:parameters];
	return [NSURL URLWithString:[@"?" stringByAppendingString:query] relativeToURL:self];
}

+ (NSURL *)ks_URLWithScheme:(NSString *)scheme
                       host:(NSString *)host
                       path:(NSString *)path
            queryParameters:(NSDictionary *)parameters;
{
    NSURL *baseURL = [[NSURL alloc] initWithScheme:scheme host:host path:path];
    NSURL *result = [baseURL ks_URLWithQueryParameters:parameters];
    [baseURL release];
    return result;
}

/*  These 2 methods form the main backbone for URL query operations
 */

+ (NSString *)ks_queryWithParameters:(NSDictionary *)parameters;
{
	// Build the list of parameters as a string
	NSMutableString *parametersString = [NSMutableString string];
	
	if (nil != parameters)
	{
		NSEnumerator *enumerator = [parameters keyEnumerator];
		NSString *key;
		BOOL thisIsTheFirstParameter = YES;
		
		while (nil != (key = [enumerator nextObject]))
		{
			id rawParameter = [parameters objectForKey: key];
			NSString *parameter = nil;
			
			// Treat arrays specially, otherwise just get the object description
			if ([rawParameter isKindOfClass:[NSArray class]]) {
				parameter = [rawParameter componentsJoinedByString:@","];
			}
			else {
				parameter = [rawParameter description];
			}
			
			// Append the parameter and its key to the full query string
			if (!thisIsTheFirstParameter)
			{
				[parametersString appendString:@"&"];
			}
			else
			{
				thisIsTheFirstParameter = NO;
			}
			[parametersString appendFormat:
             @"%@=%@",
             [key ks_stringByAddingQueryComponentPercentEscapes],
             [parameter ks_stringByAddingQueryComponentPercentEscapes]];
		}
	}
	return parametersString;
}

+ (NSDictionary *)ks_parametersOfQuery:(NSString *)queryString;
{
	NSMutableDictionary *result = [NSMutableDictionary dictionary];
    
    // Handle & or ; as separators, as per W3C recommendation
    NSCharacterSet *seperatorChars = [NSCharacterSet characterSetWithCharactersInString:@"&;"];
	NSArray *keyValues = [queryString componentsSeparatedByCharactersInSet:seperatorChars];
	NSEnumerator *theEnum = [keyValues objectEnumerator];
	NSString *keyValuePair;
	
	while (nil != (keyValuePair = [theEnum nextObject]) )
	{
		NSRange whereEquals = [keyValuePair rangeOfString:@"="];
		if (NSNotFound != whereEquals.location)
		{
			NSString *key = [keyValuePair substringToIndex:whereEquals.location];
			NSString *value = [[keyValuePair substringFromIndex:whereEquals.location+1] ks_stringByReplacingQueryComponentPercentEscapes];
			[result setValue:value forKey:key];
		}
	}
	return result;
}

@end


@implementation NSString (KSURLQueryUtilities)

/*
 
 By default, with null:
 
 encoded:		#%<>[\]^`{|}"  space
 
 Not encoded:	!$&'()*+,-./:;=?@_~
 
 
 exclamation!number%23dollar$percent%25ampersand&tick'lparen(rparen)aster*plus+space%20comma,dash-dot.slash/colon:semicolon;lessthan%3Cequals=greaterthan%3Equestion?at@lbracket%5Bbackslashl%0Dbracket%5Dcaret%5Eunderscore_backtick%60lbrace%7Bvbar%7Crbrace%7Dtilde~doublequote%22
 
 RFC2396:  Within a query component, the characters ";", "/", "?", ":", "@", "&", "=", "+", ",", and "$" are reserved.
 
 Changed to NOT convert space into + ... while this is fine for web parameters, it doesn't work on mail clients reliably (e.g. mailto:foo@bar.com?subject=Hi+There+Mom)
 
 */

- (NSString *)ks_stringByAddingQueryComponentPercentEscapes;
{
    CFStringRef converted = CFURLCreateStringByAddingPercentEscapes(NULL,
                                                                    (CFStringRef)self,
                                                                    NULL,
                                                                    CFSTR(";/?:@&=+,$%"),
                                                                    kCFStringEncodingUTF8);
    NSString *result = NSMakeCollectable(converted);
    return [result autorelease];
}

/*!	Decode a URL's query-style string, taking out the + and %XX stuff
 */
- (NSString *)ks_stringByReplacingQueryComponentPercentEscapes
{
	NSString *ish = [self stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSMutableString *result = [ish mutableCopy];
    [result replaceOccurrencesOfString:@"+"
                            withString:@" "
                               options:NSLiteralSearch
                                 range:NSMakeRange(0, [result length])]; // fix + signs too!
    
	return [result autorelease];
}

@end