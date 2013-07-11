//
//  KSURLComponents.m
//  KSFileUtilities
//
//  Created by Mike on 06/07/2013.
//  Copyright (c) 2013 Karelia Software. All rights reserved.
//

#import "KSURLComponents.h"


@interface KSURLComponents ()
@property (copy, readwrite) NSString *percentEncodedUser;
@property (copy, readwrite) NSString *percentEncodedPassword;
@property (copy, readwrite) NSString *percentEncodedHost;
@property (copy, readwrite) NSString *percentEncodedPath;
@property (copy, readwrite) NSString *percentEncodedQuery;
@property (copy, readwrite) NSString *percentEncodedFragment;
@end


@implementation KSURLComponents

#pragma mark Lifecycle

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

- (NSString *)scheme;
{
    @synchronized (self)
    {
        return [[_schemeComponent retain] autorelease];
    }
}
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
    
    @synchronized (self)
    {
        scheme = [scheme copy];
        [_schemeComponent release]; _schemeComponent = scheme;
    }
}

@synthesize percentEncodedUser = _userComponent;
- (NSString *)user;
{
    return [self.percentEncodedUser stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}
- (void)setUser:(NSString *)user;
{
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
    CFStringRef escaped = CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)password, NULL, CFSTR("@:/?#"), kCFStringEncodingUTF8);
    // @ signifies the end of the user/password, so must be escaped
    // : / ? # I reckon technically should be fine since they're before the @ symbol, but NSURLComponents seems to be cautious here, and understandably so
    
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
    CFStringRef escaped = CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)host, NULL, CFSTR("@:/?#"), kCFStringEncodingUTF8);
    // @ must be escaped so as not to confuse as a username
    // Escaping : too to avoid confusion with port. NSURLComponents doesn't do so at present rdar://14387977
    // / ? and # must be escaped so as not to indicate start of path, query or fragment
    
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

@end
