//
//  TestKSURLComponents.m
//  KSFileUtilities
//
//  Created by Mike on 06/07/2013.
//  Copyright (c) 2013 Jungle Candy Software. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>

#import "KSURLComponents.h"

@interface TestKSURLComponents : SenTestCase

@end

@implementation TestKSURLComponents

- (void)setUp
{
    [super setUp];
    // Put setup code here; it will be run once, before the first test case.
}

- (void)tearDown
{
    // Put teardown code here; it will be run once, after the last test case.
    [super tearDown];
}

#pragma mark Creating URL Components

- (void)testInit
{
    KSURLComponents *components = [[KSURLComponents alloc] init];
    
    STAssertNil(components.scheme, nil);
    STAssertNil(components.user, nil);
    STAssertNil(components.percentEncodedUser, nil);
    STAssertNil(components.password, nil);
    STAssertNil(components.percentEncodedPassword, nil);
    STAssertNil(components.host, nil);
    STAssertNil(components.percentEncodedHost, nil);
    STAssertNil(components.port, nil);
    STAssertNil(components.path, nil);
    STAssertNil(components.percentEncodedPath, nil);
    STAssertNil(components.query, nil);
    STAssertNil(components.percentEncodedQuery, nil);
    STAssertNil(components.fragment, nil);
    STAssertNil(components.percentEncodedFragment, nil);
    
    [components release];
}

- (void)testInitWithAbsoluteURL;
{
    KSURLComponents *components = [KSURLComponents componentsWithURL:[NSURL URLWithString:@"scheme://user:password@host:0/path?query#fragment"]
                                             resolvingAgainstBaseURL:NO];
    
    STAssertEqualObjects(components.scheme, @"scheme", nil);
    STAssertEqualObjects(components.user, @"user", nil);
    STAssertEqualObjects(components.password, @"password", nil);
    STAssertEqualObjects(components.host, @"host", nil);
    STAssertEqualObjects(components.port, @(0), nil);
    STAssertEqualObjects(components.path, @"/path", nil);
    STAssertEqualObjects(components.query, @"query", nil);
    STAssertEqualObjects(components.fragment, @"fragment", nil);
}

- (void)testInitWithEscapedURL;
{
    KSURLComponents *components = [KSURLComponents componentsWithURL:[NSURL URLWithString:@"scheme://us%C3%A9r:p%C3%A2ssword@h%C3%B4st:0/p%C3%A0th?q%C3%BCery#fragme%C3%B1t"]
                                             resolvingAgainstBaseURL:NO];
    
    STAssertEqualObjects(components.scheme, @"scheme", nil);
    STAssertEqualObjects(components.user, @"usér", nil);
    STAssertEqualObjects(components.percentEncodedUser, @"us%C3%A9r", nil);
    STAssertEqualObjects(components.password, @"pâssword", nil);
    STAssertEqualObjects(components.percentEncodedPassword, @"p%C3%A2ssword", nil);
    STAssertEqualObjects(components.host, @"hôst", nil);
    STAssertEqualObjects(components.percentEncodedHost, @"h%C3%B4st", nil);
    STAssertEqualObjects(components.port, @(0), nil);
    STAssertEqualObjects(components.path, @"/pàth", nil);
    STAssertEqualObjects(components.percentEncodedPath, @"/p%C3%A0th", nil);
    STAssertEqualObjects(components.query, @"qüery", nil);
    STAssertEqualObjects(components.percentEncodedQuery, @"q%C3%BCery", nil);
    STAssertEqualObjects(components.fragment, @"fragmeñt", nil);
    STAssertEqualObjects(components.percentEncodedFragment, @"fragme%C3%B1t", nil);
}

- (void)testInitWithNoHost;
{
    KSURLComponents *components = [KSURLComponents componentsWithURL:[NSURL URLWithString:@"scheme:/path/example.txt"]
                                             resolvingAgainstBaseURL:NO];
    
    STAssertEqualObjects(components.scheme, @"scheme", nil);
    STAssertNil(components.user, nil);
    STAssertNil(components.percentEncodedUser, nil);
    STAssertNil(components.password, nil);
    STAssertNil(components.percentEncodedPassword, nil);
    STAssertNil(components.host, nil);
    STAssertNil(components.percentEncodedHost, nil);
    STAssertNil(components.port, nil);
    STAssertEqualObjects(components.path, @"/path/example.txt", nil);
    STAssertEqualObjects(components.percentEncodedPath, @"/path/example.txt", nil);
    STAssertNil(components.query, nil);
    STAssertNil(components.percentEncodedQuery, nil);
    STAssertNil(components.fragment, nil);
    STAssertNil(components.percentEncodedFragment, nil);
}

- (void)testInitWithEmptyHost;
{
    KSURLComponents *components = [KSURLComponents componentsWithURL:[NSURL URLWithString:@"file:///path/example.txt"]
                                             resolvingAgainstBaseURL:NO];
    
    STAssertEqualObjects(components.scheme, @"file", nil);
    STAssertNil(components.user, nil);
    STAssertNil(components.percentEncodedUser, nil);
    STAssertNil(components.password, nil);
    STAssertNil(components.percentEncodedPassword, nil);
    STAssertNil(components.host, nil);
    STAssertEqualObjects(components.percentEncodedHost, @"", nil);
    STAssertNil(components.port, nil);
    STAssertEqualObjects(components.path, @"/path/example.txt", nil);
    STAssertEqualObjects(components.percentEncodedPath, @"/path/example.txt", nil);
    STAssertNil(components.query, nil);
    STAssertNil(components.percentEncodedQuery, nil);
    STAssertNil(components.fragment, nil);
    STAssertNil(components.percentEncodedFragment, nil);
}

- (void)testInitWithUserButEmptyHost;
{
    KSURLComponents *components = [KSURLComponents componentsWithURL:[NSURL URLWithString:@"scheme://user@/path/example.txt"]
                                             resolvingAgainstBaseURL:NO];
    
    STAssertEqualObjects(components.scheme, @"scheme", nil);
    STAssertEqualObjects(components.user, @"user", nil);
    STAssertEqualObjects(components.percentEncodedUser, @"user", nil);
    STAssertNil(components.password, nil);
    STAssertNil(components.percentEncodedPassword, nil);
    STAssertNil(components.host, nil);
    STAssertEqualObjects(components.percentEncodedHost, @"", nil);
    STAssertNil(components.port, nil);
    STAssertEqualObjects(components.path, @"/path/example.txt", nil);
    STAssertEqualObjects(components.percentEncodedPath, @"/path/example.txt", nil);
    STAssertNil(components.query, nil);
    STAssertNil(components.percentEncodedQuery, nil);
    STAssertNil(components.fragment, nil);
    STAssertNil(components.percentEncodedFragment, nil);
}

- (void)testInitWithRelativeFragment;
{
    KSURLComponents *components = [KSURLComponents componentsWithURL:[NSURL URLWithString:@"#fragment"
                                                                            relativeToURL:[NSURL URLWithString:@"http://example.com/path#wrong"]]
                                             resolvingAgainstBaseURL:NO];
    
    STAssertNil(components.scheme, nil);
    STAssertNil(components.user, nil);
    STAssertNil(components.password, nil);
    STAssertNil(components.host, nil);
    STAssertNil(components.port, nil);
    STAssertNil(components.path, nil);
    STAssertNil(components.query, nil);
    STAssertEqualObjects(components.fragment, @"fragment", nil);
}

- (void)testInitWithRelativeQuery;
{
    KSURLComponents *components = [KSURLComponents componentsWithURL:[NSURL URLWithString:@"?query"
                                                                            relativeToURL:[NSURL URLWithString:@"http://example.com/path?wrong#fragment"]]
                                             resolvingAgainstBaseURL:NO];
    
    STAssertNil(components.scheme, nil);
    STAssertNil(components.user, nil);
    STAssertNil(components.password, nil);
    STAssertNil(components.host, nil);
    STAssertNil(components.port, nil);
    STAssertNil(components.path, nil);
    STAssertEqualObjects(components.query, @"query", nil);
    STAssertNil(components.fragment, nil);
}

- (void)testInitWithRelativeAbsolutePath;
{
    KSURLComponents *components = [KSURLComponents componentsWithURL:[NSURL URLWithString:@"/path"
                                                                            relativeToURL:[NSURL URLWithString:@"http://example.com/wrong?query#fragment"]]
                                             resolvingAgainstBaseURL:NO];
    
    STAssertNil(components.scheme, nil);
    STAssertNil(components.user, nil);
    STAssertNil(components.password, nil);
    STAssertNil(components.host, nil);
    STAssertNil(components.port, nil);
    STAssertEqualObjects(components.path, @"/path", nil);
    STAssertNil(components.query, nil);
    STAssertNil(components.fragment, nil);
}

- (void)testInitWithRelativeRelativePath;
{
    KSURLComponents *components = [KSURLComponents componentsWithURL:[NSURL URLWithString:@"path"
                                                                            relativeToURL:[NSURL URLWithString:@"http://example.com/wrong?query#fragment"]]
                                             resolvingAgainstBaseURL:NO];
    
    STAssertNil(components.scheme, nil);
    STAssertNil(components.user, nil);
    STAssertNil(components.password, nil);
    STAssertNil(components.host, nil);
    STAssertNil(components.port, nil);
    STAssertEqualObjects(components.path, @"path", nil);
    STAssertNil(components.query, nil);
    STAssertNil(components.fragment, nil);
}

- (void)testInitWithParameter;
{
    KSURLComponents *components = [KSURLComponents componentsWithURL:[NSURL URLWithString:@";parameter"
                                                                            relativeToURL:[NSURL URLWithString:@"http://example.com/wrong?query#fragment"]]
                                             resolvingAgainstBaseURL:NO];
    
    STAssertNil(components.scheme, nil);
    STAssertNil(components.user, nil);
    STAssertNil(components.password, nil);
    STAssertNil(components.host, nil);
    STAssertNil(components.port, nil);
    STAssertEqualObjects(components.path, @";parameter", nil);
    STAssertNil(components.query, nil);
    STAssertNil(components.fragment, nil);
}

- (void)testInitWithPathAndParameter;
{
    KSURLComponents *components = [KSURLComponents componentsWithURL:[NSURL URLWithString:@"path;parameter"
                                                                            relativeToURL:[NSURL URLWithString:@"http://example.com/wrong?query#fragment"]]
                                             resolvingAgainstBaseURL:NO];
    
    STAssertNil(components.scheme, nil);
    STAssertNil(components.user, nil);
    STAssertNil(components.password, nil);
    STAssertNil(components.host, nil);
    STAssertNil(components.port, nil);
    STAssertEqualObjects(components.path, @"path;parameter", nil);
    STAssertNil(components.query, nil);
    STAssertNil(components.fragment, nil);
}

- (void)testInitWithProtocolRelativeURL;
{
    KSURLComponents *components = [KSURLComponents componentsWithURL:[NSURL URLWithString:@"//host/path"
                                                                            relativeToURL:[NSURL URLWithString:@"http://example.com/wrong?query#fragment"]]
                                             resolvingAgainstBaseURL:NO];
    
    STAssertNil(components.scheme, nil);
    STAssertNil(components.user, nil);
    STAssertNil(components.password, nil);
    STAssertEqualObjects(components.host, @"host", nil);
    STAssertNil(components.port, nil);
    STAssertEqualObjects(components.path, @"/path", nil);
    STAssertNil(components.query, nil);
    STAssertNil(components.fragment, nil);
}

- (void)testInitWithSchemeOnlyNoSlashes;
{
    KSURLComponents *components = [KSURLComponents componentsWithURL:[NSURL URLWithString:@"scheme:"]
                                             resolvingAgainstBaseURL:NO];
    
    STAssertEqualObjects(components.scheme, @"scheme", nil);
    STAssertNil(components.user, nil);
    STAssertNil(components.password, nil);
    STAssertNil(components.host, nil);
    STAssertNil(components.port, nil);
    STAssertEqualObjects(components.percentEncodedPath, @"", nil);
    STAssertNil(components.path, nil);
    STAssertNil(components.query, nil);
    STAssertNil(components.fragment, nil);
}

- (void)testInitWithSchemeOnlyOneSlash;
{
    KSURLComponents *components = [KSURLComponents componentsWithURL:[NSURL URLWithString:@"scheme:/"]
                                             resolvingAgainstBaseURL:NO];
    
    STAssertEqualObjects(components.scheme, @"scheme", nil);
    STAssertNil(components.user, nil);
    STAssertNil(components.password, nil);
    STAssertNil(components.host, nil);
    STAssertNil(components.port, nil);
    STAssertEqualObjects(components.percentEncodedPath, @"/", nil);
    STAssertEqualObjects(components.path, @"/", nil);
    STAssertNil(components.query, nil);
    STAssertNil(components.fragment, nil);
}

- (void)testInitWithSchemeOnlyTwoSlashes;
{
    KSURLComponents *components = [KSURLComponents componentsWithURL:[NSURL URLWithString:@"scheme://"]
                                             resolvingAgainstBaseURL:NO];
    
    STAssertEqualObjects(components.scheme, @"scheme", nil);
    STAssertNil(components.user, nil);
    STAssertNil(components.password, nil);
    STAssertEqualObjects(components.percentEncodedHost, @"", nil);
    STAssertNil(components.host, nil);
    STAssertNil(components.port, nil);
    STAssertEqualObjects(components.percentEncodedPath, @"", nil);
    STAssertNil(components.path, nil);
    STAssertNil(components.query, nil);
    STAssertNil(components.fragment, nil);
}

- (void)testInitWithSchemeOnlyThreeSlashes;
{
    KSURLComponents *components = [KSURLComponents componentsWithURL:[NSURL URLWithString:@"scheme:///"]
                                             resolvingAgainstBaseURL:NO];
    
    STAssertEqualObjects(components.scheme, @"scheme", nil);
    STAssertNil(components.user, nil);
    STAssertNil(components.password, nil);
    STAssertEqualObjects(components.percentEncodedHost, @"", nil);
    STAssertNil(components.host, nil);
    STAssertNil(components.port, nil);
    STAssertEqualObjects(components.percentEncodedPath, @"/", nil);
    STAssertEqualObjects(components.path, @"/", nil);
    STAssertNil(components.query, nil);
    STAssertNil(components.fragment, nil);
}

- (void)testInitWithSchemeAndHostOnly;
{
    KSURLComponents *components = [KSURLComponents componentsWithURL:[NSURL URLWithString:@"scheme://host"]
                                             resolvingAgainstBaseURL:NO];
    
    STAssertEqualObjects(components.scheme, @"scheme", nil);
    STAssertNil(components.user, nil);
    STAssertNil(components.password, nil);
    STAssertEqualObjects(components.percentEncodedHost, @"host", nil);
    STAssertEqualObjects(components.host, @"host", nil);
    STAssertNil(components.port, nil);
    STAssertEqualObjects(components.percentEncodedPath, @"", nil);
    STAssertNil(components.path, nil);
    STAssertNil(components.query, nil);
    STAssertNil(components.fragment, nil);
}

- (void)testInitWithSchemeAndQueryOnlyNoSlashes;
{
    KSURLComponents *components = [KSURLComponents componentsWithURL:[NSURL URLWithString:@"scheme:?query"]
                                             resolvingAgainstBaseURL:NO];
    
    STAssertEqualObjects(components.scheme, @"scheme", nil);
    STAssertNil(components.user, nil);
    STAssertNil(components.password, nil);
    STAssertNil(components.percentEncodedHost, nil);
    STAssertNil(components.host, nil);
    STAssertNil(components.port, nil);
    STAssertEqualObjects(components.percentEncodedPath, @"", nil);
    STAssertNil(components.path, nil);
    STAssertEqualObjects(components.query, @"query", nil);
    STAssertNil(components.fragment, nil);
}

- (void)testInitWithSchemeAndQueryOnlyOneSlash;
{
    KSURLComponents *components = [KSURLComponents componentsWithURL:[NSURL URLWithString:@"scheme:/?query"]
                                             resolvingAgainstBaseURL:NO];
    
    STAssertEqualObjects(components.scheme, @"scheme", nil);
    STAssertNil(components.user, nil);
    STAssertNil(components.password, nil);
    STAssertNil(components.percentEncodedHost, nil);
    STAssertNil(components.host, nil);
    STAssertNil(components.port, nil);
    STAssertEqualObjects(components.percentEncodedPath, @"/", nil);
    STAssertEqualObjects(components.path, @"/", nil);
    STAssertEqualObjects(components.query, @"query", nil);
    STAssertNil(components.fragment, nil);
}

- (void)testInitWithSchemeAndQueryOnlyTwoSlashes;
{
    KSURLComponents *components = [KSURLComponents componentsWithURL:[NSURL URLWithString:@"scheme://?query"]
                                             resolvingAgainstBaseURL:NO];
    
    STAssertEqualObjects(components.scheme, @"scheme", nil);
    STAssertNil(components.user, nil);
    STAssertNil(components.password, nil);
    STAssertEqualObjects(components.percentEncodedHost, @"", nil);
    STAssertNil(components.host, nil);
    STAssertNil(components.port, nil);
    STAssertEqualObjects(components.percentEncodedPath, @"", nil);
    STAssertNil(components.path, nil);
    STAssertEqualObjects(components.query, @"query", nil);
    STAssertNil(components.fragment, nil);
}

#pragma mark Escaping

- (void)testSchemeValidation;
{
    KSURLComponents *components = [[KSURLComponents alloc] init];
    STAssertThrowsSpecificNamed(components.scheme = @"!*'();:@&=+$,/?#[]", NSException, NSInvalidArgumentException, nil);
    [components release];
}

- (void)testUserEscaping;
{
    KSURLComponents *components = [[KSURLComponents alloc] init];
    
    components.user = @"!*'();:@&=+$,/?#[]";
    STAssertEqualObjects(components.percentEncodedUser, @"!*'();%3A%40&=+$,%2F%3F%23%5B%5D", nil);
    
    [components release];
}

- (void)testPasswordEscaping;
{
    KSURLComponents *components = [[KSURLComponents alloc] init];
    
    components.password = @"!*'();:@&=+$,/?#[]";
    STAssertEqualObjects(components.percentEncodedPassword, @"!*'();%3A%40&=+$,%2F%3F%23%5B%5D", nil);
    
    [components release];
}

- (void)testHostEscaping;
{
    KSURLComponents *components = [[KSURLComponents alloc] init];
    
    components.host = @"!*'();:@&=+$,/?#[]";
    STAssertEqualObjects(components.percentEncodedHost, @"!*'();%3A%40&=+$,%2F%3F%23%5B%5D", nil);
    
    [components release];
}

- (void)testLiteralHostEscaping;
{
    KSURLComponents *components = [[KSURLComponents alloc] init];
    
    components.host = @"[!*'();:@&=+$,/?#[]]";
    STAssertEqualObjects(components.percentEncodedHost, @"[!*'();:%40&=+$,%2F%3F%23%5B%5D]", @"Bracketing in [ ] indicates a literal host, which is allowed to contain : characters, e.g. for IPv6 addresses");
    
    [components release];
}

- (void)testPathEscaping;
{
    KSURLComponents *components = [[KSURLComponents alloc] init];
    
    components.path = @"!*'();:@&=+$,/?#[]";
    STAssertEqualObjects(components.percentEncodedPath, @"!*'()%3B%3A@&=+$,/%3F%23%5B%5D", nil);
    
    [components release];
}

- (void)testQueryEscaping;
{
    KSURLComponents *components = [[KSURLComponents alloc] init];
    
    components.query = @"!*'();:@&=+$,/?#[]";
    STAssertEqualObjects(components.percentEncodedQuery, @"!*'();:@&=+$,/?%23%5B%5D", nil);
    
    [components release];
}

- (void)testFragmentEscaping;
{
    KSURLComponents *components = [[KSURLComponents alloc] init];
    
    components.fragment = @"!*'();:@&=+$,/?#[]";
    STAssertEqualObjects(components.percentEncodedFragment, @"!*'();:@&=+$,/?%23%5B%5D", nil);
    
    [components release];
}

#pragma mark Creating a URL

- (void)testURL;
{
    KSURLComponents *components = [[KSURLComponents alloc] init];
    components.scheme = @"scheme";
    components.user = @"user";
    components.password = @"password";
    components.host = @"host";
    components.port = @(0);
    components.path = @"/path";
    components.query = @"query";
    components.fragment = @"fragment";
    
    NSURL *url = [components URL];
    STAssertEqualObjects(url.relativeString, @"scheme://user:password@host:0/path?query#fragment", nil);
    
    [components release];
}

- (void)testURLFromScheme;
{
    KSURLComponents *components = [[KSURLComponents alloc] init];
    components.scheme = @"scheme";
    
    NSURL *url = [components URL];
    STAssertEqualObjects(url.relativeString, @"scheme:", nil);
}

- (void)testURLFromUser;
{
    KSURLComponents *components = [[KSURLComponents alloc] init];
    components.user = @"user";
    
    NSURL *url = [components URL];
    STAssertEqualObjects(url.relativeString, @"//user@", nil);
}

- (void)testURLFromPassword;
{
    KSURLComponents *components = [[KSURLComponents alloc] init];
    components.password = @"password";
    
    NSURL *url = [components URL];
    STAssertEqualObjects(url.relativeString, @"//:password@", nil);
}

- (void)testURLFromHost;
{
    KSURLComponents *components = [[KSURLComponents alloc] init];
    components.host = @"host";
    
    NSURL *url = [components URL];
    STAssertEqualObjects(url.relativeString, @"//host", nil);
}

- (void)testURLFromPort;
{
    KSURLComponents *components = [[KSURLComponents alloc] init];
    components.port = @(0);
    
    NSURL *url = [components URL];
    STAssertEqualObjects(url.relativeString, @"//:0", nil);
}

- (void)testURLFromAbsolutePath;
{
    KSURLComponents *components = [[KSURLComponents alloc] init];
    components.path = @"/path";
    
    NSURL *url = [components URL];
    STAssertEqualObjects(url.relativeString, @"/path", nil);
}

- (void)testURLFromRelativePath;
{
    KSURLComponents *components = [[KSURLComponents alloc] init];
    components.path = @"path";
    
    NSURL *url = [components URL];
    STAssertEqualObjects(url.relativeString, @"path", nil);
}

- (void)testURLFromQuery;
{
    KSURLComponents *components = [[KSURLComponents alloc] init];
    components.query = @"query";
    
    NSURL *url = [components URL];
    STAssertEqualObjects(url.relativeString, @"?query", nil);
}

- (void)testURLFromFragment;
{
    KSURLComponents *components = [[KSURLComponents alloc] init];
    components.fragment = @"fragment";
    
    NSURL *url = [components URL];
    STAssertEqualObjects(url.relativeString, @"#fragment", nil);
}

- (void)testURLWithoutSchemeOrHost;
{
    KSURLComponents *components = [[KSURLComponents alloc] init];
    components.user = @"user";
    components.password = @"password";
    components.port = @(0);
    components.path = @"/path";
    
    NSURL *url = [components URL];
    STAssertEqualObjects(url.relativeString, @"//user:password@:0/path", nil);
}

- (void)testURLWithNoAuthorityComponentButAbsolutePath;
{
    KSURLComponents *components = [[KSURLComponents alloc] init];
    components.scheme = @"scheme";
    components.path = @"/path";
    
    NSURL *url = [components URL];
    STAssertEqualObjects(url.relativeString, @"scheme:/path", nil);
}

- (void)testURLWithEmptyAuthorityComponentButAbsolutePath;
{
    KSURLComponents *components = [[KSURLComponents alloc] init];
    components.scheme = @"scheme";
    components.host = @"";
    components.path = @"/path";
    
    NSURL *url = [components URL];
    STAssertEqualObjects(url.relativeString, @"scheme:///path", nil);
}

- (void)testURLWithNoAuthorityComponentButRelativePath;
{
    KSURLComponents *components = [[KSURLComponents alloc] init];
    components.scheme = @"scheme";
    components.path = @"path";
    
    NSURL *url = [components URL];
    STAssertEqualObjects(url.relativeString, @"scheme:path", nil);
}

- (void)testURLWithEmptyAuthorityComponentButRelativePath;
{
    KSURLComponents *components = [[KSURLComponents alloc] init];
    components.scheme = @"scheme";
    components.host = @"";
    components.path = @"path";
    
    NSURL *url = [components URL];
    STAssertNil(url, nil);
}

- (void)testURLFromAuthorityComponentAndRelativePath
{
    KSURLComponents *components = [KSURLComponents componentsWithString:@"http://example.com"];
    components.path = @"relative";
    
    NSURL *url = [components URL];
    STAssertNil(url, @"If the KSURLComponents has an authority component (user, password, host or port) and a path component, then the path must either begin with \"/\" or be an empty string");
}

- (void)testURLFromNoAuthorityComponentAndProtocolRelativePath
{
    KSURLComponents *components = [[KSURLComponents alloc] init];
    components.scheme = @"scheme";
    components.path = @"//protocol/relative";
    
    NSURL *url = [components URL];
    STAssertNil(url, @"If the KSURLComponents does not have an authority component (user, password, host or port) and has a path component, the path component must not start with \"//\"");
    
    [components release];
}

#pragma mark NSCopying

- (void)testCopying;
{
    KSURLComponents *components = [KSURLComponents componentsWithURL:[NSURL URLWithString:@"scheme://user:password@host:0/path?query#fragment"]
                                             resolvingAgainstBaseURL:NO];
    
    KSURLComponents *components2 = [components copy];
    
    STAssertEqualObjects(components, components2, nil);
    [components2 release];
}

#pragma mark Query Parameters

- (void)testNilQuery;
{
    KSURLComponents *components = [[KSURLComponents alloc] init];
    NSDictionary *parameters = [components queryParametersWithOptions:0];
    
    STAssertNil(parameters, nil);
}

- (void)testEmptyQuery;
{
    KSURLComponents *components = [[KSURLComponents alloc] initWithString:@"scheme://host?"];
    
    NSDictionary *parameters = [components queryParametersWithOptions:0];
    STAssertNil(parameters, nil);
    
    __block BOOL blockCalled = NO;
    [components enumerateQueryParametersWithOptions:0 usingBlock:^(NSString *key, NSString *value, BOOL *stop) {
        STAssertEqualObjects(key, @"", nil);
        STAssertNil(value, nil);
        blockCalled = YES;
    }];
    STAssertTrue(blockCalled, nil);
}

- (void)testNonParameterisedQuery;
{
    KSURLComponents *components = [[KSURLComponents alloc] initWithString:@"scheme://host?query"];
    
    NSDictionary *parameters = [components queryParametersWithOptions:0];
    STAssertNil(parameters, nil);
    
    __block BOOL blockCalled = NO;
    [components enumerateQueryParametersWithOptions:0 usingBlock:^(NSString *key, NSString *value, BOOL *stop) {
        STAssertEqualObjects(key, @"query", nil);
        STAssertNil(value, nil);
        blockCalled = YES;
    }];
    STAssertTrue(blockCalled, nil);
}

- (void)testSingleQueryParameter;
{
    KSURLComponents *components = [[KSURLComponents alloc] initWithString:@"scheme://host?key=value"];
    
    NSDictionary *parameters = [components queryParametersWithOptions:0];
    STAssertEqualObjects(parameters, @{ @"key" : @"value" }, nil);
}

- (void)testQueryParameters;
{
    KSURLComponents *components = [[KSURLComponents alloc] initWithString:@"scheme://host?key=value&foo=bar"];
    
    NSDictionary *parameters = [components queryParametersWithOptions:0];
    NSDictionary *expected = @{ @"key" : @"value", @"foo" : @"bar" };
    STAssertEqualObjects(parameters, expected, nil);
}

- (void)testEmptyQueryParameterKey;
{
    KSURLComponents *components = [[KSURLComponents alloc] initWithString:@"scheme://host?=value"];
    
    NSDictionary *parameters = [components queryParametersWithOptions:0];
    STAssertEqualObjects(parameters, @{ @"" : @"value" }, nil);
}

- (void)testEmptyQueryParameterValue;
{
    KSURLComponents *components = [[KSURLComponents alloc] initWithString:@"scheme://host?key="];
    
    NSDictionary *parameters = [components queryParametersWithOptions:0];
    STAssertEqualObjects(parameters, @{ @"key" : @"" }, nil);
}

- (void)testRepeatedKeys;
{
    KSURLComponents *components = [[KSURLComponents alloc] initWithString:@"scheme://host?key=value&key=value2"];
    
    NSDictionary *parameters = [components queryParametersWithOptions:0];
    STAssertNil(parameters, nil);
    
    __block int blockCalled = 0;
    [components enumerateQueryParametersWithOptions:0 usingBlock:^(NSString *key, NSString *value, BOOL *stop) {
        STAssertEqualObjects(key, @"key", nil);
        STAssertEqualObjects(value, (blockCalled ? @"value2" : @"value"), nil);
        ++blockCalled;
    }];
    STAssertEquals(blockCalled, 2, nil);
}

- (void)testEqualsSignInQueryParameterValue;
{
    KSURLComponents *components = [[KSURLComponents alloc] initWithString:@"scheme://host?key=val=ue"];
    
    NSDictionary *parameters = [components queryParametersWithOptions:0];
    STAssertEqualObjects(parameters, @{ @"key" : @"val=ue" }, nil);
}

- (void)testQueryParameterUnescaping;
{
    KSURLComponents *components = [[KSURLComponents alloc] initWithString:@"scheme://host?k%2Fy=va%2Fue"];
    
    NSDictionary *parameters = [components queryParametersWithOptions:0];
    STAssertEqualObjects(parameters, @{ @"k/y" : @"va/ue" }, nil);
}

- (void)testPlusSymbolInQueryParameters;
{
    KSURLComponents *components = [KSURLComponents componentsWithString:@"?size=%7B64%2C+64%7D"];
    
    NSDictionary *parameters = [components queryParametersWithOptions:0];
    STAssertEqualObjects(parameters, @{ @"size" : @"{64,+64}" }, nil);
    
    parameters = [components queryParametersWithOptions:KSURLComponentsQueryParameterDecodingPlusAsSpace];
    STAssertEqualObjects(parameters, @{ @"size" : @"{64, 64}" }, nil);
}

- (void)testEncodeNilQueryParameters;
{
    KSURLComponents *components = [[KSURLComponents alloc] init];
    [components setQueryParameters:nil];
    STAssertNil(components.percentEncodedQuery, nil);
}

- (void)testEncodeEmptyQueryParameters;
{
    KSURLComponents *components = [[KSURLComponents alloc] init];
    [components setQueryParameters:@{ }];
    STAssertEqualObjects(components.percentEncodedQuery, @"", nil);
}

- (void)testEncodeQueryParameter;
{
    KSURLComponents *components = [[KSURLComponents alloc] init];
    [components setQueryParameters:@{ @"key" : @"value" }];
    STAssertEqualObjects(components.percentEncodedQuery, @"key=value", nil);
}

- (void)testEncodeQueryParameters;
{
    KSURLComponents *components = [[KSURLComponents alloc] init];
    [components setQueryParameters:@{ @"key" : @"value", @"key2" : @"value2" }];
    STAssertEqualObjects(components.percentEncodedQuery, @"key=value&key2=value2", nil);
}

- (void)testEncodeQueryParameterEscaping;
{
    KSURLComponents *components = [[KSURLComponents alloc] init];
    [components setQueryParameters:@{ @"!*'();:@&=+$,/?#[]" : @"!*'();:@&=+$,/?#[]" }];
    STAssertEqualObjects(components.percentEncodedQuery, @"!*'();:@%26%3D%2B$,/?%23%5B%5D=!*'();:@%26=%2B$,/?%23%5B%5D", nil);
}

@end
