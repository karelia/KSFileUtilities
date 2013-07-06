//
//  KSURLComponents.m
//  KSFileUtilities
//
//  Created by Mike on 06/07/2013.
//  Copyright (c) 2013 Karelia Software. All rights reserved.
//

#import "KSURLComponents.h"

@implementation KSURLComponents

- (id)initWithURL:(NSURL *)url resolvingAgainstBaseURL:(BOOL)resolve;
{
    if (resolve) url = [url absoluteURL];
    
    self = [self init];
    
    // Avoid CFURLCopyScheme as it resolves relative URLs
    CFRange schemeRange = CFURLGetByteRangeForComponent((CFURLRef)url, kCFURLComponentScheme, NULL);
    if (schemeRange.location != kCFNotFound)
    {
        CFStringRef scheme = CFStringCreateWithSubstring(NULL, CFURLGetString((CFURLRef)url), schemeRange);
        self.scheme = (NSString *)scheme;
        CFRelease(scheme);
    }
    
    // Avoid CFURLCopyUserName as it removes escapes
    CFRange userRange = CFURLGetByteRangeForComponent((CFURLRef)url, kCFURLComponentUser, NULL);
    if (userRange.location != kCFNotFound)
    {
        CFStringRef user = CFStringCreateWithSubstring(NULL, CFURLGetString((CFURLRef)url), userRange);
        self.percentEncodedUser = (NSString *)user;
        CFRelease(user);
    }
    
    // Avoid CFURLCopyPassword as it removes escapes
    CFRange passwordRange = CFURLGetByteRangeForComponent((CFURLRef)url, kCFURLComponentPassword, NULL);
    if (passwordRange.location != kCFNotFound)
    {
        CFStringRef password = CFStringCreateWithSubstring(NULL, CFURLGetString((CFURLRef)url), passwordRange);
        self.percentEncodedPassword = (NSString *)password;
        CFRelease(password);
    }
    
    // Avoid CFURLCopyHostName as it removes escapes
    CFRange hostRange = CFURLGetByteRangeForComponent((CFURLRef)url, kCFURLComponentHost, NULL);
    if (hostRange.location != kCFNotFound)
    {
        CFStringRef host = CFStringCreateWithSubstring(NULL, CFURLGetString((CFURLRef)url), hostRange);
        self.percentEncodedHost = (NSString *)host;
        CFRelease(host);
    }
    
    SInt32 port = CFURLGetPortNumber((CFURLRef)url);
    if (port >= 0) self.port = @(port);
    
    CFStringRef path = CFURLCopyPath((CFURLRef)url);
    if (path)
    {
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
    
    if (user)
    {
        [string appendString:user];
        
        if (password)
        {
            [string appendString:@":"];
            [string appendString:password];
        }
        
        [string appendString:@"@"];
    }
    
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

@synthesize scheme = _schemeComponent;

@synthesize percentEncodedUser = _userComponent;
- (NSString *)user;
{
    return [self.percentEncodedUser stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}
- (void)setUser:(NSString *)user;
{
    CFStringRef escaped = CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)user, NULL, NULL, kCFStringEncodingUTF8);
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
    CFStringRef escaped = CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)password, NULL, NULL, kCFStringEncodingUTF8);
    self.percentEncodedPassword = (NSString *)escaped;
    CFRelease(escaped);
}

@synthesize percentEncodedHost = _hostComponent;
- (NSString *)host;
{
    return [self.percentEncodedHost stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}
- (void)setHost:(NSString *)host;
{
    CFStringRef escaped = CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)host, NULL, NULL, kCFStringEncodingUTF8);
    self.percentEncodedHost = (NSString *)escaped;
    CFRelease(escaped);
}

- (NSNumber *)port;
{
    @synchronized (self)
    {
        return [[_portComponent retain] autorelease];
    }
}
- (void)setPort:(NSNumber *)port;
{
    if (port.integerValue < 0) [NSException raise:NSInvalidArgumentException format:@"Invalid port: %@; can't be negative", port];
    
    port = [port copy];
    @synchronized (self)
    {
        [_portComponent release]; _portComponent = port;
    }
}

@synthesize percentEncodedPath = _pathComponent;
- (NSString *)path;
{
    return [self.percentEncodedPath stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}
- (void)setPath:(NSString *)path;
{
    CFStringRef escaped = CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)path, NULL, NULL, kCFStringEncodingUTF8);
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
    CFStringRef escaped = CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)fragment, NULL, NULL, kCFStringEncodingUTF8);
    self.percentEncodedFragment = (NSString *)escaped;
    CFRelease(escaped);
}

@end