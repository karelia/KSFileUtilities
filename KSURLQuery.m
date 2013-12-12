//
//  KSURLQuery.m
//  KSFileUtilities
//
//  Created by Mike on 12/12/2013.
//  Copyright (c) 2013 Karelia Software. All rights reserved.
//

#import "KSURLQuery.h"


@interface KSURLQuery ()
@property(nonatomic, readwrite, copy) NSString *percentEncodedString;
@end


@implementation KSURLQuery

+ (instancetype)queryWithURL:(NSURL *)url;
{
    // Always resolve, since unlike paths there's no way for two queries to be in some way concatenated
    CFURLRef cfURL = CFURLCopyAbsoluteURL((CFURLRef)url);
    
    NSString *string = (NSString *)CFURLCopyQueryString(cfURL,
                                                        NULL);  // leave unescaped
    
    KSURLQuery *result = [self queryWithPercentEncodedString:string];
    [string release];
    CFRelease(cfURL);
    return result;
}

+ (instancetype)queryWithPercentEncodedString:(NSString *)percentEncodedQuery;
{
    return [[[self alloc] initWithPercentEncodedString:percentEncodedQuery] autorelease];
}

- initWithPercentEncodedString:(NSString *)string;
{
    if (self = [self init])
    {
        _percentEncodedString = [string copy];
    }
    return self;
}

- (void)dealloc
{
    [_percentEncodedString release];
    [super dealloc];
}

@synthesize percentEncodedString = _percentEncodedString;

- (NSDictionary *)parametersWithOptions:(KSURLQueryParameterDecodingOptions)options;
{
    __block NSMutableDictionary *result = [NSMutableDictionary dictionary];
    
    [self enumerateParametersWithOptions:options usingBlock:^(NSString *key, NSString *value, BOOL *stop) {
        
        // Bail if doesn't fit dictionary paradigm
        if (!value || [result objectForKey:key])
        {
            *stop = YES;
            result = nil;
            return;
        }
        
        [result setObject:value forKey:key];
    }];
    
    return result;
}

- (void)enumerateParametersWithOptions:(KSURLQueryParameterDecodingOptions)options usingBlock:(void (^)(NSString *, NSString *, BOOL *))block;
{
    BOOL stop = NO;
    
    NSString *query = self.percentEncodedString; // we'll do our own decoding after separating components
    NSRange searchRange = NSMakeRange(0, query.length);
    
    while (!stop)
    {
        NSRange keySeparatorRange = [query rangeOfString:@"=" options:NSLiteralSearch range:searchRange];
        if (keySeparatorRange.location == NSNotFound) keySeparatorRange = NSMakeRange(NSMaxRange(searchRange), 0);
        
        NSRange keyRange = NSMakeRange(searchRange.location, keySeparatorRange.location - searchRange.location);
        NSString *key = [query substringWithRange:keyRange];
        
        NSString *value = nil;
        if (keySeparatorRange.length)   // there might be no value, so report as nil
        {
            searchRange = NSMakeRange(NSMaxRange(keySeparatorRange), query.length - NSMaxRange(keySeparatorRange));
            
            NSRange valueSeparatorRange = [query rangeOfString:@"&" options:NSLiteralSearch range:searchRange];
            if (valueSeparatorRange.location == NSNotFound)
            {
                valueSeparatorRange.location = NSMaxRange(searchRange);
                stop = YES;
            }
            
            NSRange valueRange = NSMakeRange(searchRange.location, valueSeparatorRange.location - searchRange.location);
            value = [query substringWithRange:valueRange];
            
            searchRange = NSMakeRange(NSMaxRange(valueSeparatorRange), query.length - NSMaxRange(valueSeparatorRange));
        }
        else
        {
            stop = YES;
        }
        
        if (options & KSURLQueryParameterDecodingPlusAsSpace)
        {
            key = [key stringByReplacingOccurrencesOfString:@"+" withString:@" "];
            value = [value stringByReplacingOccurrencesOfString:@"+" withString:@" "];
        }
        
        block([key stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
              [value stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
              &stop);
    }
}

- (void)setParameters:(NSDictionary *)parameters;
{
    if (!parameters)
    {
        self.percentEncodedString = nil;
        return;
    }
    
    // Build the list of parameters as a string
	NSMutableString *query = [NSMutableString string];
	
    NSEnumerator *enumerator = [parameters keyEnumerator];
    BOOL thisIsTheFirstParameter = YES;
    
    NSString *key;
    while ((key = [enumerator nextObject]))
    {
        CFStringRef escapedKey = CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)key, NULL, CFSTR("+=&#"), kCFStringEncodingUTF8);
        // Escape + for safety as some backends interpret it as a space
        // = indicates the start of value, so must be escaped
        // & indicates the start of next parameter, so must be escaped
        // # indicates the start of fragment, so must be escaped
        
        NSString *parameter = [parameters objectForKey:key];
        
        // Append the parameter and its key to the full query string
        if (!thisIsTheFirstParameter)
        {
            [query appendString:@"&"];
        }
        else
        {
            thisIsTheFirstParameter = NO;
        }
        
        CFStringRef escapedValue = CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)parameter, NULL, CFSTR("+&#"), kCFStringEncodingUTF8);
        // Escape + for safety as some backends interpret it as a space
        // = is allowed in values, as there's no further value to indicate
        // & indicates the start of next parameter, so must be escaped
        // # indicates the start of fragment, so must be escaped
        
        [query appendFormat:@"%@=%@", escapedKey, escapedValue];
        
        CFRelease(escapedKey);
        CFRelease(escapedValue);
    }
    
    self.percentEncodedString = query;
}

@end
