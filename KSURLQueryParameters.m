//
//  KSURLQueryParameters.m
//  KSFileUtilities
//
//  Created by Mike on 14/10/2013.
//  Copyright (c) 2013 Karelia Software. All rights reserved.
//

#import "KSURLQueryParameters.h"


@implementation KSURLQueryParameters

#pragma mark Creating a KSURLQueryParameters object

- init;
{
    if (self = [super init])
    {
        _string = [[NSMutableString alloc] init];
    }
    return self;
}

- initWithPercentEncodedString:(NSString *)query;
{
    NSParameterAssert(query);
    if (self = [self init])
    {
        [_string setString:query];
    }
    return self;
}

+ (instancetype)queryParametersWithPercentEncodedString:(NSString *)query;
{
    if (!query) return nil;
    return [[[self alloc] initWithPercentEncodedString:query] autorelease];
}

- initWithDictionary:(NSDictionary *)dictionary
{
    NSParameterAssert(dictionary);
    self = [self init];
    [self addParametersFromDictionary:dictionary];
    return self;
}

+ (instancetype)queryParametersWithDictionary:(NSDictionary *)dictionary;
{
    return [[[self alloc] initWithDictionary:dictionary] autorelease];
}

#pragma mark Retrieving Query and Parameters

- (NSString *)percentEncodedQuery;
{
    return [[_string copy] autorelease];
}

- (NSDictionary *)dictionaryRepresentation;
{
    __block NSMutableDictionary *result = [NSMutableDictionary dictionary];
    
    [self enumerateParametersUsingBlock:^(NSString *key, NSString *value, BOOL *stop) {
        
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

- (void)enumerateParametersUsingBlock:(void (^)(NSString *, NSString *, BOOL *))block;
{
    BOOL stop = NO;
    
    NSString *query = self.percentEncodedQuery; // we'll do our own decoding after separating components
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
        
        block([key stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
              [value stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
              &stop);
    }
}

#pragma mark Adding and Removing Parameters

- (void)addParameter:(NSString *)key value:(NSString *)value;
{
    NSParameterAssert(key);
    
    
    if (_string.length) [_string appendString:@"&"];
    
    CFStringRef escapedKey = CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)key, NULL, CFSTR("+=&#"), kCFStringEncodingUTF8);
    // Escape + for safety as some backends interpret it as a space
    // = indicates the start of value, so must be escaped
    // & indicates the start of next parameter, so must be escaped
    // # indicates the start of fragment, so must be escaped
    
    [_string appendString:(NSString *)escapedKey];
    CFRelease(escapedKey);
    
    
    if (value)
    {
        [_string appendString:@"="];
        
        CFStringRef escapedValue = CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)value, NULL, CFSTR("+&#"), kCFStringEncodingUTF8);
        // Escape + for safety as some backends interpret it as a space
        // = is allowed in values, as there's no further value to indicate
        // & indicates the start of next parameter, so must be escaped
        // # indicates the start of fragment, so must be escaped
        
        [_string appendString:(NSString *)escapedValue];
        CFRelease(escapedValue);
    }
}

- (void)addParametersFromDictionary:(NSDictionary *)dictionary;
{
    [dictionary enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [self addParameter:key value:obj];
    }];
}

- (void)removeAllParameters;
{
    [_string deleteCharactersInRange:NSMakeRange(0, _string.length)];
}

#pragma mark NSCopying

- (id)copyWithZone:(NSZone *)zone;
{
    return [[KSURLQueryParameters alloc] initWithPercentEncodedString:self.percentEncodedQuery];
}

#pragma mark Debugging

- (NSString *)description;
{
    return [[super description] stringByAppendingFormat:@" ?%@", self.percentEncodedQuery];
}

@end
