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
    
    CFStringRef scheme = CFURLCopyScheme((CFURLRef)url);
    if (scheme)
    {
        self.scheme = (NSString *)scheme;
        CFRelease(scheme);
    }
    
    CFStringRef user = CFURLCopyUserName((CFURLRef)url);
    if (user)
    {
        self.percentEncodedUser = (NSString *)user;
        CFRelease(user);
    }
    
    CFStringRef password = CFURLCopyPassword((CFURLRef)url);
    if (password)
    {
        self.percentEncodedPassword = (NSString *)password;
        CFRelease(password);
    }
    
    CFStringRef host = CFURLCopyHostName((CFURLRef)url);
    if (host)
    {
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
    NSMutableString *string = [[NSMutableString alloc] init];
    
    NSString *scheme = self.scheme;
    if (scheme)
    {
        [string appendString:scheme];
        [string appendString:@":"];
    }
    
    NSString *user = self.percentEncodedUser;
    if (user)
    {
        [string appendString:user];
        
        NSString *password = self.percentEncodedPassword;
        if (password)
        {
            [string appendString:@":"];
            [string appendString:password];
        }
        
        [string appendString:@"@"];
    }
    
    NSString *host = self.percentEncodedHost;
    if (host)
    {
        [string appendString:host];
    }
    
    NSNumber *port = self.port;
    if (port)
    {
        [string appendFormat:@":%u", port.unsignedIntValue];
    }
    
    NSString *path = self.percentEncodedPath;
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
    return [self.percentEncodedUser stringByRemovingPercentEncoding];
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
    return [self.percentEncodedPassword stringByRemovingPercentEncoding];
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
    return [self.percentEncodedHost stringByRemovingPercentEncoding];
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
    return [self.percentEncodedPath stringByRemovingPercentEncoding];
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
    return [self.percentEncodedQuery stringByRemovingPercentEncoding];
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
    return [self.percentEncodedFragment stringByRemovingPercentEncoding];
}
- (void)setFragment:(NSString *)fragment;
{
    CFStringRef escaped = CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)fragment, NULL, NULL, kCFStringEncodingUTF8);
    self.percentEncodedFragment = (NSString *)escaped;
    CFRelease(escaped);
}

@end
