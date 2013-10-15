//
//  KSURLComponents.m
//  KSFileUtilities
//
//  Created by Mike Abdullah on 06/07/2013.
//  Copyright © 2013 Karelia Software
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

#import "KSURLComponents.h"


@interface KSURLComponents ()
@property (nonatomic, copy, readwrite) NSString *percentEncodedUser;
@property (nonatomic, copy, readwrite) NSString *percentEncodedPassword;
@property (nonatomic, copy, readwrite) NSString *percentEncodedHost;
@property (nonatomic, copy, readwrite) NSString *percentEncodedPath;
@property (nonatomic, copy, readwrite) NSString *percentEncodedQuery;
@property (nonatomic, copy, readwrite) NSString *percentEncodedFragment;
@end


@implementation KSURLComponents

#pragma mark Lifecycle

- (id)initWithURL:(NSURL *)url resolvingAgainstBaseURL:(BOOL)resolve;
{
    if (resolve) url = [url absoluteURL];
    CFStringRef urlString = CFURLGetString((CFURLRef)url);
    BOOL fudgedParsing = NO;
    
    self = [self init];
    
    
    // Default to empty path. NSURLComponents seems to basically do that; it's very hard to end up with a nil path
    self.percentEncodedPath = @"";
    
    
    // Avoid CFURLCopyScheme as it resolves relative URLs
    CFRange schemeRange = CFURLGetByteRangeForComponent((CFURLRef)url, kCFURLComponentScheme, NULL);
    if (schemeRange.location != kCFNotFound)
    {
        CFStringRef scheme = CFStringCreateWithSubstring(NULL, urlString, schemeRange);
        self.scheme = (NSString *)scheme;
        CFRelease(scheme);
        
        // For URLs which feature no slashes to indicate the path *before* a
        // ; ? or # mark, we need to coerce them into parsing
        if (schemeRange.location == 0)
        {
            if (!CFStringFindWithOptions(urlString,
                                         CFSTR(":/"),
                                         CFRangeMake(schemeRange.length, CFStringGetLength(urlString) - schemeRange.length),
                                         kCFCompareAnchored,
                                         NULL))
            {
                NSMutableString *fudgedString = [(NSString *)urlString mutableCopy];
                [fudgedString insertString:@"/"
                                   atIndex:(schemeRange.length + 1)];   // after the colon
                
                url = [NSURL URLWithString:fudgedString];
                [fudgedString release];
                urlString = CFURLGetString((CFURLRef)url);
                
                fudgedParsing = YES;
            }
        }
    }
    
    // Avoid CFURLCopyUserName as it removes escapes
    CFRange userRange = CFURLGetByteRangeForComponent((CFURLRef)url, kCFURLComponentUser, NULL);
    if (userRange.location != kCFNotFound)
    {
        CFStringRef user = CFStringCreateWithSubstring(NULL, urlString, userRange);
        self.percentEncodedUser = (NSString *)user;
        CFRelease(user);
    }
    
    // Avoid CFURLCopyPassword as it removes escapes
    CFRange passwordRange = CFURLGetByteRangeForComponent((CFURLRef)url, kCFURLComponentPassword, NULL);
    if (passwordRange.location != kCFNotFound)
    {
        CFStringRef password = CFStringCreateWithSubstring(NULL, urlString, passwordRange);
        self.percentEncodedPassword = (NSString *)password;
        CFRelease(password);
    }
    
    
    // Avoid CFURLCopyHostName as it removes escapes
    CFRange hostRange = CFURLGetByteRangeForComponent((CFURLRef)url, kCFURLComponentHost, NULL);
    if (hostRange.location != kCFNotFound)
    {
        CFStringRef host = CFStringCreateWithSubstring(NULL, urlString, hostRange);
        self.percentEncodedHost = (NSString *)host;
        CFRelease(host);
    }
    
    // Need to represent the presence of a host whenever the URL starts scheme://
    // Manually searching is the best I've found so far
    else if (schemeRange.location == 0)
    {
        if (CFStringFindWithOptions(urlString,
                                    CFSTR("://"),
                                    CFRangeMake(schemeRange.length, CFStringGetLength(urlString) - schemeRange.length),
                                    kCFCompareAnchored,
                                    NULL))
        {
            self.percentEncodedHost = @"";
        }
    }
    
    
    SInt32 port = CFURLGetPortNumber((CFURLRef)url);
    if (port >= 0) self.port = @(port);
    
    
    // Account for parameter. NS/CFURL treat it as distinct, but NSURLComponents rolls it into the path
    CFRange pathRange = CFURLGetByteRangeForComponent((CFURLRef)url, kCFURLComponentPath, NULL);
    
    CFRange parameterRange;
    CFURLGetByteRangeForComponent((CFURLRef)url, kCFURLComponentParameterString, &parameterRange);
    
    if (pathRange.location != kCFNotFound || (parameterRange.location != kCFNotFound && parameterRange.length > 0))
    {
        if (pathRange.location == kCFNotFound)
        {
            pathRange = parameterRange;
        }
        else if (parameterRange.length > 0)
        {
            pathRange.length += parameterRange.length;
        }
        
        if (fudgedParsing)
        {
            pathRange.location++; pathRange.length--;
        }
        
        CFStringRef path = CFStringCreateWithSubstring(NULL, CFURLGetString((CFURLRef)url), pathRange);
        self.percentEncodedPath = (NSString *)path;
        CFRelease(path);
    }
    
    CFStringRef query = CFURLCopyQueryString((CFURLRef)url, NULL);
    if (query)
    {
        self.percentEncodedQuery = (NSString *)query;
        CFRelease(query);
    }
    
    CFStringRef fragment = CFURLCopyFragment((CFURLRef)url, NULL);
    if (fragment)
    {
        self.percentEncodedFragment = (NSString *)fragment;
        CFRelease(fragment);
    }
    
    return self;
}

+ (id)componentsWithURL:(NSURL *)url resolvingAgainstBaseURL:(BOOL)resolve;
{
    return [[[self alloc] initWithURL:url resolvingAgainstBaseURL:resolve] autorelease];
}

- (id)initWithString:(NSString *)URLString;
{
    NSURL *url = [[NSURL alloc] initWithString:URLString];
    if (!url)
    {
        [self release]; return nil;
    }
    
    self = [self initWithURL:url
     resolvingAgainstBaseURL:NO];   // already absolute
    
    [url release];
    return self;
}

+ (id)componentsWithString:(NSString *)URLString;
{
    return [[[self alloc] initWithString:URLString] autorelease];
}

- (void)dealloc;
{
    [_schemeComponent release];
    [_userComponent release];
    [_passwordComponent release];
    [_hostComponent release];
    [_portComponent release];
    [_pathComponent release];
    [_queryComponent release];
    [_fragmentComponent release];
    
    [super dealloc];
}

#pragma mark Generating a URL

- (NSURL *)URL;
{
    return [self URLRelativeToURL:nil];
}

- (NSURL *)URLRelativeToURL:(NSURL *)baseURL;
{
    NSString *user = self.percentEncodedUser;
    NSString *password = self.percentEncodedPassword;
    NSString *host = self.percentEncodedHost;
    NSNumber *port = self.port;
    NSString *path = self.percentEncodedPath;
    
    BOOL hasAuthorityComponent = (user || password || host || port);
    
    // If the KSURLComponents has an authority component (user, password, host or port) and a path component, then the path must either begin with "/" or be an empty string.
    if (hasAuthorityComponent &&
        !(path.length == 0 || [path isAbsolutePath]))
    {
        return nil;
    }
    
    // If the KSURLComponents does not have an authority component (user, password, host or port) and has a path component, the path component must not start with "//".
    if (!hasAuthorityComponent && [path hasPrefix:@"//"])
    {
        return nil;
    }
    
    NSMutableString *string = [[NSMutableString alloc] init];
    
    
    NSString *scheme = self.scheme;
    if (scheme)
    {
        [string appendString:scheme];
        [string appendString:@":"];
    }
    
    if (hasAuthorityComponent) [string appendString:@"//"];
    
    if (user) [string appendString:user];
    
    if (password)
    {
        [string appendString:@":"];
        [string appendString:password];
    }
    
    if (user || password) [string appendString:@"@"];
    
    if (host)
    {
        [string appendString:host];
    }
    
    if (port)
    {
        [string appendFormat:@":%u", port.unsignedIntValue];
    }
    
    if (path)
    {
        [string appendString:path];
    }
    
    NSString *query = self.percentEncodedQuery;
    if (query)
    {
        [string appendString:@"?"];
        [string appendString:query];
    }
    
    NSString *fragment = self.percentEncodedFragment;
    if (fragment)
    {
        [string appendString:@"#"];
        [string appendString:fragment];
    }
    
    NSURL *result = [NSURL URLWithString:string relativeToURL:baseURL];
    [string release];
    return result;
}

#pragma mark Components

@synthesize scheme = _schemeComponent;
- (void)setScheme:(NSString *)scheme;
{
    if (scheme)
    {
        NSCharacterSet *legalCharacters = [NSCharacterSet characterSetWithCharactersInString:@"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-."];
        
        if ([scheme rangeOfCharacterFromSet:legalCharacters.invertedSet].location != NSNotFound)
        {
            [NSException raise:NSInvalidArgumentException format:@"invalid characters in scheme"];
        }
    }
    
    scheme = [scheme copy];
    [_schemeComponent release]; _schemeComponent = scheme;
}

@synthesize percentEncodedUser = _userComponent;
- (NSString *)user;
{
    return [self.percentEncodedUser stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}
- (void)setUser:(NSString *)user;
{
    if (!user)
    {
        self.percentEncodedUser = user;
        return;
    }
    
    CFStringRef escaped = CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)user, NULL, CFSTR(":@/?#"), kCFStringEncodingUTF8);
    // : signifies the start of the password, so must be escaped
    // @ signifies the end of the user/password, so must be escaped
    // / ? # I reckon technically should be fine since they're before the @ symbol, but NSURLComponents seems to be cautious here, and understandably so
    
    self.percentEncodedUser = (NSString *)escaped;
    CFRelease(escaped);
}

@synthesize percentEncodedPassword = _passwordComponent;
- (NSString *)password;
{
    return [self.percentEncodedPassword stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}
- (void)setPassword:(NSString *)password;
{
    if (!password)
    {
        self.percentEncodedPassword = password;
        return;
    }
    
    CFStringRef escaped = CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)password, NULL, CFSTR("@:/?#"), kCFStringEncodingUTF8);
    // @ signifies the end of the user/password, so must be escaped
    // : / ? # I reckon technically should be fine since they're before the @ symbol, but NSURLComponents seems to be cautious here, and understandably so
    
    self.percentEncodedPassword = (NSString *)escaped;
    CFRelease(escaped);
}

@synthesize percentEncodedHost = _hostComponent;
- (NSString *)host;
{
    // Treat empty host specially. It signifies the host in URLs like file:///path
    // nil for practical usage from -host, but a marker internally to differentiate
    // from file:/path
    NSString *host = self.percentEncodedHost;
    if (host.length == 0) return nil;
    
    return [host stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}
- (void)setHost:(NSString *)host;
{
    if (!host)
    {
        self.percentEncodedHost = host;
        return;
    }
    
    NSRange startBracket = [host rangeOfString:@"[" options:NSAnchoredSearch];
    if (startBracket.location != NSNotFound)
    {
        NSRange endBracket = [host rangeOfString:@"]" options:NSAnchoredSearch|NSBackwardsSearch];
        if (endBracket.location != NSNotFound)
        {
            host = [host substringWithRange:NSMakeRange(startBracket.length, host.length - endBracket.length - startBracket.length)];
            
            CFStringRef escaped = CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)host, NULL, CFSTR("@/?#"), kCFStringEncodingUTF8);
            // @ must be escaped so as not to confuse as a username
            // Don't escape : as it's within a host literal, and likely part of an IPv6 address
            // / ? and # must be escaped so as not to indicate start of path, query or fragment
            
            NSString *encoded = [NSString stringWithFormat:@"[%@]", escaped];
            
            self.percentEncodedHost = encoded;
            CFRelease(escaped);
            return;
        }
    }
    
    CFStringRef escaped = CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)host, NULL, CFSTR("@:/?#"), kCFStringEncodingUTF8);
    // @ must be escaped so as not to confuse as a username
    // : must be escaped too to avoid confusion with port
    // / ? and # must be escaped so as not to indicate start of path, query or fragment
    
    self.percentEncodedHost = (NSString *)escaped;
    CFRelease(escaped);
}

@synthesize port = _portComponent;
- (void)setPort:(NSNumber *)port;
{
    if (port.integerValue < 0) [NSException raise:NSInvalidArgumentException format:@"Invalid port: %@; can't be negative", port];
    
    port = [port copy];
    [_portComponent release]; _portComponent = port;
}

@synthesize percentEncodedPath = _pathComponent;
- (NSString *)path;
{
    // Same treatment as -host
    NSString *path = self.percentEncodedPath;
    if (path.length == 0) return nil;
    
    return [path stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}
- (void)setPath:(NSString *)path;
{
    if (!path)
    {
        self.percentEncodedPath = path;
        return;
    }
    
    CFStringRef escaped = CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)path, NULL, CFSTR(":;?#"), kCFStringEncodingUTF8);
    // : doesn't *need* to be escaped if the path is part of a complete URL, but it does if the generated URL is scheme-less. Seems safest to always escape it, and NSURLComponents does so too
    // ; ? and # all need to be escape to avoid confusion with parameter, query and fragment
    
    self.percentEncodedPath = (NSString *)escaped;
    CFRelease(escaped);
}

@synthesize percentEncodedQuery = _queryComponent;
- (NSString *)query;
{
    return [self.percentEncodedQuery stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}
- (void)setQuery:(NSString *)query;
{
    if (!query)
    {
        self.percentEncodedQuery = query;
        return;
    }
    
    CFStringRef escaped = CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)query, NULL, NULL, kCFStringEncodingUTF8);
    self.percentEncodedQuery = (NSString *)escaped;
    CFRelease(escaped);
}

@synthesize percentEncodedFragment = _fragmentComponent;
- (NSString *)fragment;
{
    return [self.percentEncodedFragment stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}
- (void)setFragment:(NSString *)fragment;
{
    if (!fragment)
    {
        self.percentEncodedFragment = fragment;
        return;
    }
    
    CFStringRef escaped = CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)fragment, NULL, NULL, kCFStringEncodingUTF8);
    self.percentEncodedFragment = (NSString *)escaped;
    CFRelease(escaped);
}

#pragma mark Query Parameters

- (NSDictionary *)queryParametersWithOptions:(KSURLComponentsQueryParameterDecodingOptions)options;
{
    __block NSMutableDictionary *result = [NSMutableDictionary dictionary];
    
    [self enumerateQueryParametersWithOptions:options usingBlock:^(NSString *key, NSString *value, BOOL *stop) {
        
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

- (void)setQueryParameters:(NSDictionary *)parameters;
{
    if (!parameters)
    {
        self.query = nil;
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
    
    self.percentEncodedQuery = query;
}

- (void)enumerateQueryParametersWithOptions:(KSURLComponentsQueryParameterDecodingOptions)options usingBlock:(void (^)(NSString *key, NSString *value, BOOL *stop))block;
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
        
        if (options & KSURLComponentsQueryParameterDecodingPlusAsSpace)
        {
            key = [key stringByReplacingOccurrencesOfString:@"+" withString:@" "];
            value = [value stringByReplacingOccurrencesOfString:@"+" withString:@" "];
        }
        
        block([key stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
              [value stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
              &stop);
    }
}

#pragma mark Equality Testing

- (BOOL)isEqual:(id)object;
{
    if (![object isKindOfClass:[KSURLComponents class]]) return NO;
    
    NSString *myScheme = self.scheme;
    NSString *otherScheme = [object scheme];
    if (myScheme != otherScheme && ![myScheme isEqualToString:otherScheme]) return NO;
    
    NSString *myUser = self.percentEncodedUser;
    NSString *otherUser = [object percentEncodedUser];
    if (myUser != otherUser && ![myUser isEqualToString:otherUser]) return NO;
    
    NSString *myPassword = self.percentEncodedPassword;
    NSString *otherPassword = [object percentEncodedPassword];
    if (myPassword != otherPassword && ![myPassword isEqualToString:otherPassword]) return NO;
    
    NSString *myHost = self.percentEncodedHost;
    NSString *otherHost = [object percentEncodedHost];
    if (myHost != otherHost && ![myHost isEqualToString:otherHost]) return NO;
    
    NSNumber *myPort = self.port;
    NSNumber *otherPort = [(KSURLComponents *)object port];
    if (myPort != otherPort && ![myPort isEqualToNumber:otherPort]) return NO;
    
    NSString *myPath = self.percentEncodedPath;
    NSString *otherPath = [object percentEncodedPath];
    if (myPath != otherPath && ![myPath isEqualToString:otherPath]) return NO;
    
    NSString *myQuery = self.percentEncodedQuery;
    NSString *otherQuery = [object percentEncodedQuery];
    if (myQuery != otherQuery && ![myQuery isEqualToString:otherQuery]) return NO;
    
    NSString *myFragment = self.percentEncodedFragment;
    NSString *otherFragment = [object percentEncodedFragment];
    if (myFragment != otherFragment && ![myFragment isEqualToString:otherFragment]) return NO;
    
    return YES;
}

- (NSUInteger)hash;
{
    // This could definitely be a better algorithm!
    return self.scheme.hash + self.percentEncodedUser.hash + self.percentEncodedPassword.hash + self.percentEncodedPassword.hash + self.percentEncodedHost.hash + self.port.hash + self.percentEncodedPath.hash + self.percentEncodedQuery.hash + self.percentEncodedFragment.hash;
}

#pragma mark NSCopying

- (id)copyWithZone:(NSZone *)zone;
{
    KSURLComponents *result = [[KSURLComponents alloc] init];
    
    result.scheme = self.scheme;
    result.percentEncodedUser = self.percentEncodedUser;
    result.percentEncodedPassword = self.percentEncodedPassword;
    result.percentEncodedHost = self.percentEncodedHost;
    result.port = self.port;
    result.percentEncodedPath = self.percentEncodedPath;
    result.percentEncodedQuery = self.percentEncodedQuery;
    result.percentEncodedFragment = self.percentEncodedFragment;
    
    return result;
}

#pragma mark Debugging

- (NSString *)description;
{
    return [[super description] stringByAppendingFormat:
            @" {scheme = %@, user = %@, password = %@, host = %@, port = %@, path = %@, query = %@, fragment = %@}",
            self.scheme,
            self.percentEncodedUser,
            self.percentEncodedPassword,
            self.percentEncodedHost,
            self.port,
            self.percentEncodedPath,
            self.percentEncodedQuery,
            self.percentEncodedFragment];
}

@end
