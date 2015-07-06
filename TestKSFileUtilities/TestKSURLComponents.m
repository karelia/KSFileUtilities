//
//  TestKSURLComponents.m
//  KSFileUtilities
//
//  Created by Mike on 06/07/2013.
//  Copyright (c) 2013 Jungle Candy Software. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "KSURLComponents.h"
#import "KSURLQuery.h"

@interface TestKSURLComponents : XCTestCase

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
    
    XCTAssertNil(components.scheme);
    XCTAssertNil(components.user);
    XCTAssertNil(components.percentEncodedUser);
    XCTAssertNil(components.password);
    XCTAssertNil(components.percentEncodedPassword);
    XCTAssertNil(components.host);
    XCTAssertNil(components.percentEncodedHost);
    XCTAssertNil(components.port);
    XCTAssertNil(components.path);
    XCTAssertNil(components.percentEncodedPath);
    XCTAssertNil(components.query);
    XCTAssertNil(components.percentEncodedQuery);
    XCTAssertNil(components.fragment);
    XCTAssertNil(components.percentEncodedFragment);
    
    [components release];
}

- (void)testInitWithAbsoluteURL;
{
    KSURLComponents *components = [KSURLComponents componentsWithURL:[NSURL URLWithString:@"scheme://user:password@host:0/path?query#fragment"]
                                             resolvingAgainstBaseURL:NO];
    
    XCTAssertEqualObjects(components.scheme, @"scheme");
    XCTAssertEqualObjects(components.user, @"user");
    XCTAssertEqualObjects(components.password, @"password");
    XCTAssertEqualObjects(components.host, @"host");
    XCTAssertEqualObjects(components.port, @(0));
    XCTAssertEqualObjects(components.path, @"/path");
    XCTAssertEqualObjects(components.query, @"query");
    XCTAssertEqualObjects(components.fragment, @"fragment");
}

- (void)testInitWithEscapedURL;
{
    KSURLComponents *components = [KSURLComponents componentsWithURL:[NSURL URLWithString:@"scheme://us%C3%A9r:p%C3%A2ssword@h%C3%B4st:0/p%C3%A0th?q%C3%BCery#fragme%C3%B1t"]
                                             resolvingAgainstBaseURL:NO];
    
    XCTAssertEqualObjects(components.scheme, @"scheme");
    XCTAssertEqualObjects(components.user, @"usér");
    XCTAssertEqualObjects(components.percentEncodedUser, @"us%C3%A9r");
    XCTAssertEqualObjects(components.password, @"pâssword");
    XCTAssertEqualObjects(components.percentEncodedPassword, @"p%C3%A2ssword");
    XCTAssertEqualObjects(components.host, @"hôst");
    XCTAssertEqualObjects(components.percentEncodedHost, @"h%C3%B4st");
    XCTAssertEqualObjects(components.port, @(0));
    XCTAssertEqualObjects(components.path, @"/pàth");
    XCTAssertEqualObjects(components.percentEncodedPath, @"/p%C3%A0th");
    XCTAssertEqualObjects(components.query, @"qüery");
    XCTAssertEqualObjects(components.percentEncodedQuery, @"q%C3%BCery");
    XCTAssertEqualObjects(components.fragment, @"fragmeñt");
    XCTAssertEqualObjects(components.percentEncodedFragment, @"fragme%C3%B1t");
}

- (void)testInitWithNoHost;
{
    KSURLComponents *components = [KSURLComponents componentsWithURL:[NSURL URLWithString:@"scheme:/path/example.txt"]
                                             resolvingAgainstBaseURL:NO];
    
    XCTAssertEqualObjects(components.scheme, @"scheme");
    XCTAssertNil(components.user);
    XCTAssertNil(components.percentEncodedUser);
    XCTAssertNil(components.password);
    XCTAssertNil(components.percentEncodedPassword);
    XCTAssertNil(components.host);
    XCTAssertNil(components.percentEncodedHost);
    XCTAssertNil(components.port);
    XCTAssertEqualObjects(components.path, @"/path/example.txt");
    XCTAssertEqualObjects(components.percentEncodedPath, @"/path/example.txt");
    XCTAssertNil(components.query);
    XCTAssertNil(components.percentEncodedQuery);
    XCTAssertNil(components.fragment);
    XCTAssertNil(components.percentEncodedFragment);
}

- (void)testInitWithEmptyHost;
{
    KSURLComponents *components = [KSURLComponents componentsWithURL:[NSURL URLWithString:@"file:///path/example.txt"]
                                             resolvingAgainstBaseURL:NO];
    
    XCTAssertEqualObjects(components.scheme, @"file");
    XCTAssertNil(components.user);
    XCTAssertNil(components.percentEncodedUser);
    XCTAssertNil(components.password);
    XCTAssertNil(components.percentEncodedPassword);
    XCTAssertNil(components.host);
    XCTAssertEqualObjects(components.percentEncodedHost, @"");
    XCTAssertNil(components.port);
    XCTAssertEqualObjects(components.path, @"/path/example.txt");
    XCTAssertEqualObjects(components.percentEncodedPath, @"/path/example.txt");
    XCTAssertNil(components.query);
    XCTAssertNil(components.percentEncodedQuery);
    XCTAssertNil(components.fragment);
    XCTAssertNil(components.percentEncodedFragment);
}

- (void)testInitWithUserButEmptyHost;
{
    KSURLComponents *components = [KSURLComponents componentsWithURL:[NSURL URLWithString:@"scheme://user@/path/example.txt"]
                                             resolvingAgainstBaseURL:NO];
    
    XCTAssertEqualObjects(components.scheme, @"scheme");
    XCTAssertEqualObjects(components.user, @"user");
    XCTAssertEqualObjects(components.percentEncodedUser, @"user");
    XCTAssertNil(components.password);
    XCTAssertNil(components.percentEncodedPassword);
    XCTAssertNil(components.host);
    XCTAssertEqualObjects(components.percentEncodedHost, @"");
    XCTAssertNil(components.port);
    XCTAssertEqualObjects(components.path, @"/path/example.txt");
    XCTAssertEqualObjects(components.percentEncodedPath, @"/path/example.txt");
    XCTAssertNil(components.query);
    XCTAssertNil(components.percentEncodedQuery);
    XCTAssertNil(components.fragment);
    XCTAssertNil(components.percentEncodedFragment);
}

- (void)testInitWithRelativeFragment;
{
    KSURLComponents *components = [KSURLComponents componentsWithURL:[NSURL URLWithString:@"#fragment"
                                                                            relativeToURL:[NSURL URLWithString:@"http://example.com/path#wrong"]]
                                             resolvingAgainstBaseURL:NO];
    
    XCTAssertNil(components.scheme);
    XCTAssertNil(components.user);
    XCTAssertNil(components.password);
    XCTAssertNil(components.host);
    XCTAssertNil(components.port);
    XCTAssertNil(components.path);
    XCTAssertNil(components.query);
    XCTAssertEqualObjects(components.fragment, @"fragment");
}

- (void)testInitWithRelativeQuery;
{
    KSURLComponents *components = [KSURLComponents componentsWithURL:[NSURL URLWithString:@"?query"
                                                                            relativeToURL:[NSURL URLWithString:@"http://example.com/path?wrong#fragment"]]
                                             resolvingAgainstBaseURL:NO];
    
    XCTAssertNil(components.scheme);
    XCTAssertNil(components.user);
    XCTAssertNil(components.password);
    XCTAssertNil(components.host);
    XCTAssertNil(components.port);
    XCTAssertNil(components.path);
    XCTAssertEqualObjects(components.query, @"query");
    XCTAssertNil(components.fragment);
}

- (void)testInitWithRelativeAbsolutePath;
{
    KSURLComponents *components = [KSURLComponents componentsWithURL:[NSURL URLWithString:@"/path"
                                                                            relativeToURL:[NSURL URLWithString:@"http://example.com/wrong?query#fragment"]]
                                             resolvingAgainstBaseURL:NO];
    
    XCTAssertNil(components.scheme);
    XCTAssertNil(components.user);
    XCTAssertNil(components.password);
    XCTAssertNil(components.host);
    XCTAssertNil(components.port);
    XCTAssertEqualObjects(components.path, @"/path");
    XCTAssertNil(components.query);
    XCTAssertNil(components.fragment);
}

- (void)testInitWithRelativeRelativePath;
{
    KSURLComponents *components = [KSURLComponents componentsWithURL:[NSURL URLWithString:@"path"
                                                                            relativeToURL:[NSURL URLWithString:@"http://example.com/wrong?query#fragment"]]
                                             resolvingAgainstBaseURL:NO];
    
    XCTAssertNil(components.scheme);
    XCTAssertNil(components.user);
    XCTAssertNil(components.password);
    XCTAssertNil(components.host);
    XCTAssertNil(components.port);
    XCTAssertEqualObjects(components.path, @"path");
    XCTAssertNil(components.query);
    XCTAssertNil(components.fragment);
}

- (void)testInitWithParameter;
{
    KSURLComponents *components = [KSURLComponents componentsWithURL:[NSURL URLWithString:@";parameter"
                                                                            relativeToURL:[NSURL URLWithString:@"http://example.com/wrong?query#fragment"]]
                                             resolvingAgainstBaseURL:NO];
    
    XCTAssertNil(components.scheme);
    XCTAssertNil(components.user);
    XCTAssertNil(components.password);
    XCTAssertNil(components.host);
    XCTAssertNil(components.port);
    XCTAssertEqualObjects(components.path, @";parameter");
    XCTAssertNil(components.query);
    XCTAssertNil(components.fragment);
}

- (void)testInitWithPathAndParameter;
{
    KSURLComponents *components = [KSURLComponents componentsWithURL:[NSURL URLWithString:@"path;parameter"
                                                                            relativeToURL:[NSURL URLWithString:@"http://example.com/wrong?query#fragment"]]
                                             resolvingAgainstBaseURL:NO];
    
    XCTAssertNil(components.scheme);
    XCTAssertNil(components.user);
    XCTAssertNil(components.password);
    XCTAssertNil(components.host);
    XCTAssertNil(components.port);
    XCTAssertEqualObjects(components.path, @"path;parameter");
    XCTAssertNil(components.query);
    XCTAssertNil(components.fragment);
}

- (void)testInitWithProtocolRelativeURL;
{
    KSURLComponents *components = [KSURLComponents componentsWithURL:[NSURL URLWithString:@"//host/path"
                                                                            relativeToURL:[NSURL URLWithString:@"http://example.com/wrong?query#fragment"]]
                                             resolvingAgainstBaseURL:NO];
    
    XCTAssertNil(components.scheme);
    XCTAssertNil(components.user);
    XCTAssertNil(components.password);
    XCTAssertEqualObjects(components.host, @"host");
    XCTAssertNil(components.port);
    XCTAssertEqualObjects(components.path, @"/path");
    XCTAssertNil(components.query);
    XCTAssertNil(components.fragment);
}

- (void)testInitWithSchemeOnlyNoSlashes;
{
    KSURLComponents *components = [KSURLComponents componentsWithURL:[NSURL URLWithString:@"scheme:"]
                                             resolvingAgainstBaseURL:NO];
    
    XCTAssertEqualObjects(components.scheme, @"scheme");
    XCTAssertNil(components.user);
    XCTAssertNil(components.password);
    XCTAssertNil(components.host);
    XCTAssertNil(components.port);
    XCTAssertEqualObjects(components.percentEncodedPath, @"");
    XCTAssertNil(components.path);
    XCTAssertNil(components.query);
    XCTAssertNil(components.fragment);
}

- (void)testInitWithSchemeOnlyOneSlash;
{
    KSURLComponents *components = [KSURLComponents componentsWithURL:[NSURL URLWithString:@"scheme:/"]
                                             resolvingAgainstBaseURL:NO];
    
    XCTAssertEqualObjects(components.scheme, @"scheme");
    XCTAssertNil(components.user);
    XCTAssertNil(components.password);
    XCTAssertNil(components.host);
    XCTAssertNil(components.port);
    XCTAssertEqualObjects(components.percentEncodedPath, @"/");
    XCTAssertEqualObjects(components.path, @"/");
    XCTAssertNil(components.query);
    XCTAssertNil(components.fragment);
}

- (void)testInitWithSchemeOnlyTwoSlashes;
{
    KSURLComponents *components = [KSURLComponents componentsWithURL:[NSURL URLWithString:@"scheme://"]
                                             resolvingAgainstBaseURL:NO];
    
    XCTAssertEqualObjects(components.scheme, @"scheme");
    XCTAssertNil(components.user);
    XCTAssertNil(components.password);
    XCTAssertEqualObjects(components.percentEncodedHost, @"");
    XCTAssertNil(components.host);
    XCTAssertNil(components.port);
    XCTAssertEqualObjects(components.percentEncodedPath, @"");
    XCTAssertNil(components.path);
    XCTAssertNil(components.query);
    XCTAssertNil(components.fragment);
}

- (void)testInitWithSchemeOnlyThreeSlashes;
{
    KSURLComponents *components = [KSURLComponents componentsWithURL:[NSURL URLWithString:@"scheme:///"]
                                             resolvingAgainstBaseURL:NO];
    
    XCTAssertEqualObjects(components.scheme, @"scheme");
    XCTAssertNil(components.user);
    XCTAssertNil(components.password);
    XCTAssertEqualObjects(components.percentEncodedHost, @"");
    XCTAssertNil(components.host);
    XCTAssertNil(components.port);
    XCTAssertEqualObjects(components.percentEncodedPath, @"/");
    XCTAssertEqualObjects(components.path, @"/");
    XCTAssertNil(components.query);
    XCTAssertNil(components.fragment);
}

- (void)testInitWithSchemeAndHostOnly;
{
    KSURLComponents *components = [KSURLComponents componentsWithURL:[NSURL URLWithString:@"scheme://host"]
                                             resolvingAgainstBaseURL:NO];
    
    XCTAssertEqualObjects(components.scheme, @"scheme");
    XCTAssertNil(components.user);
    XCTAssertNil(components.password);
    XCTAssertEqualObjects(components.percentEncodedHost, @"host");
    XCTAssertEqualObjects(components.host, @"host");
    XCTAssertNil(components.port);
    XCTAssertEqualObjects(components.percentEncodedPath, @"");
    XCTAssertNil(components.path);
    XCTAssertNil(components.query);
    XCTAssertNil(components.fragment);
}

- (void)testInitWithSchemeAndQueryOnlyNoSlashes;
{
    KSURLComponents *components = [KSURLComponents componentsWithURL:[NSURL URLWithString:@"scheme:?query"]
                                             resolvingAgainstBaseURL:NO];
    
    XCTAssertEqualObjects(components.scheme, @"scheme");
    XCTAssertNil(components.user);
    XCTAssertNil(components.password);
    XCTAssertNil(components.percentEncodedHost);
    XCTAssertNil(components.host);
    XCTAssertNil(components.port);
    XCTAssertEqualObjects(components.percentEncodedPath, @"");
    XCTAssertNil(components.path);
    XCTAssertEqualObjects(components.query, @"query");
    XCTAssertNil(components.fragment);
}

- (void)testInitWithSchemeAndQueryOnlyOneSlash;
{
    KSURLComponents *components = [KSURLComponents componentsWithURL:[NSURL URLWithString:@"scheme:/?query"]
                                             resolvingAgainstBaseURL:NO];
    
    XCTAssertEqualObjects(components.scheme, @"scheme");
    XCTAssertNil(components.user);
    XCTAssertNil(components.password);
    XCTAssertNil(components.percentEncodedHost);
    XCTAssertNil(components.host);
    XCTAssertNil(components.port);
    XCTAssertEqualObjects(components.percentEncodedPath, @"/");
    XCTAssertEqualObjects(components.path, @"/");
    XCTAssertEqualObjects(components.query, @"query");
    XCTAssertNil(components.fragment);
}

- (void)testInitWithSchemeAndQueryOnlyTwoSlashes;
{
    KSURLComponents *components = [KSURLComponents componentsWithURL:[NSURL URLWithString:@"scheme://?query"]
                                             resolvingAgainstBaseURL:NO];
    
    XCTAssertEqualObjects(components.scheme, @"scheme");
    XCTAssertNil(components.user);
    XCTAssertNil(components.password);
    XCTAssertEqualObjects(components.percentEncodedHost, @"");
    XCTAssertNil(components.host);
    XCTAssertNil(components.port);
    XCTAssertEqualObjects(components.percentEncodedPath, @"");
    XCTAssertNil(components.path);
    XCTAssertEqualObjects(components.query, @"query");
    XCTAssertNil(components.fragment);
}

#pragma mark Escaping

- (void)testSchemeValidation;
{
    KSURLComponents *components = [[KSURLComponents alloc] init];
    XCTAssertThrowsSpecificNamed([components setScheme:@"!*'();:@&=+$,/?#[]"], NSException, NSInvalidArgumentException);
    [components release];
}

- (void)testUserEscaping;
{
    KSURLComponents *components = [[KSURLComponents alloc] init];
    
    components.user = @"!*'();:@&=+$,/?#[]";
    XCTAssertEqualObjects(components.percentEncodedUser, @"!*'();%3A%40&=+$,%2F%3F%23%5B%5D");
    
    [components release];
}

- (void)testPasswordEscaping;
{
    KSURLComponents *components = [[KSURLComponents alloc] init];
    
    components.password = @"!*'();:@&=+$,/?#[]";
    XCTAssertEqualObjects(components.percentEncodedPassword, @"!*'();%3A%40&=+$,%2F%3F%23%5B%5D");
    
    [components release];
}

- (void)testHostEscaping;
{
    KSURLComponents *components = [[KSURLComponents alloc] init];
    
    components.host = @"!*'();:@&=+$,/?#[]";
    XCTAssertEqualObjects(components.percentEncodedHost, @"!*'();%3A%40&=+$,%2F%3F%23%5B%5D");
    
    [components release];
}

- (void)testLiteralHostEscaping;
{
    KSURLComponents *components = [[KSURLComponents alloc] init];
    
    components.host = @"[!*'();:@&=+$,/?#[]]";
    XCTAssertEqualObjects(components.percentEncodedHost, @"[!*'();:%40&=+$,%2F%3F%23%5B%5D]", @"Bracketing in [ ] indicates a literal host, which is allowed to contain : characters, e.g. for IPv6 addresses");
    
    [components release];
}

- (void)testPathEscaping;
{
    KSURLComponents *components = [[KSURLComponents alloc] init];
    
    components.path = @"!*'();:@&=+$,/?#[]";
    XCTAssertEqualObjects(components.percentEncodedPath, @"!*'()%3B%3A@&=+$,/%3F%23%5B%5D");
    
    [components release];
}

- (void)testQueryEscaping;
{
    KSURLComponents *components = [[KSURLComponents alloc] init];
    
    components.query = @"!*'();:@&=+$,/?#[]";
    XCTAssertEqualObjects(components.percentEncodedQuery, @"!*'();:@&=+$,/?%23%5B%5D");
    
    [components release];
}

- (void)testFragmentEscaping;
{
    KSURLComponents *components = [[KSURLComponents alloc] init];
    
    components.fragment = @"!*'();:@&=+$,/?#[]";
    XCTAssertEqualObjects(components.percentEncodedFragment, @"!*'();:@&=+$,/?%23%5B%5D");
    
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
    XCTAssertEqualObjects(url.relativeString, @"scheme://user:password@host:0/path?query#fragment");
    
    [components release];
}

- (void)testURLFromScheme;
{
    KSURLComponents *components = [[KSURLComponents alloc] init];
    components.scheme = @"scheme";
    
    NSURL *url = [components URL];
    XCTAssertEqualObjects(url.relativeString, @"scheme:");
}

- (void)testURLFromUser;
{
    KSURLComponents *components = [[KSURLComponents alloc] init];
    components.user = @"user";
    
    NSURL *url = [components URL];
    XCTAssertEqualObjects(url.relativeString, @"//user@");
}

- (void)testURLFromPassword;
{
    KSURLComponents *components = [[KSURLComponents alloc] init];
    components.password = @"password";
    
    NSURL *url = [components URL];
    XCTAssertEqualObjects(url.relativeString, @"//:password@");
}

- (void)testURLFromHost;
{
    KSURLComponents *components = [[KSURLComponents alloc] init];
    components.host = @"host";
    
    NSURL *url = [components URL];
    XCTAssertEqualObjects(url.relativeString, @"//host");
}

- (void)testURLFromPort;
{
    KSURLComponents *components = [[KSURLComponents alloc] init];
    components.port = @(0);
    
    NSURL *url = [components URL];
    XCTAssertEqualObjects(url.relativeString, @"//:0");
}

- (void)testURLFromAbsolutePath;
{
    KSURLComponents *components = [[KSURLComponents alloc] init];
    components.path = @"/path";
    
    NSURL *url = [components URL];
    XCTAssertEqualObjects(url.relativeString, @"/path");
}

- (void)testURLFromRelativePath;
{
    KSURLComponents *components = [[KSURLComponents alloc] init];
    components.path = @"path";
    
    NSURL *url = [components URL];
    XCTAssertEqualObjects(url.relativeString, @"path");
}

- (void)testURLFromQuery;
{
    KSURLComponents *components = [[KSURLComponents alloc] init];
    components.query = @"query";
    
    NSURL *url = [components URL];
    XCTAssertEqualObjects(url.relativeString, @"?query");
}

- (void)testURLFromFragment;
{
    KSURLComponents *components = [[KSURLComponents alloc] init];
    components.fragment = @"fragment";
    
    NSURL *url = [components URL];
    XCTAssertEqualObjects(url.relativeString, @"#fragment");
}

- (void)testURLWithoutSchemeOrHost;
{
    KSURLComponents *components = [[KSURLComponents alloc] init];
    components.user = @"user";
    components.password = @"password";
    components.port = @(0);
    components.path = @"/path";
    
    NSURL *url = [components URL];
    XCTAssertEqualObjects(url.relativeString, @"//user:password@:0/path");
}

- (void)testURLWithNoAuthorityComponentButAbsolutePath;
{
    KSURLComponents *components = [[KSURLComponents alloc] init];
    components.scheme = @"scheme";
    components.path = @"/path";
    
    NSURL *url = [components URL];
    XCTAssertEqualObjects(url.relativeString, @"scheme:/path");
}

- (void)testURLWithEmptyAuthorityComponentButAbsolutePath;
{
    KSURLComponents *components = [[KSURLComponents alloc] init];
    components.scheme = @"scheme";
    components.host = @"";
    components.path = @"/path";
    
    NSURL *url = [components URL];
    XCTAssertEqualObjects(url.relativeString, @"scheme:///path");
}

- (void)testURLWithNoAuthorityComponentButRelativePath;
{
    KSURLComponents *components = [[KSURLComponents alloc] init];
    components.scheme = @"scheme";
    components.path = @"path";
    
    NSURL *url = [components URL];
    XCTAssertEqualObjects(url.relativeString, @"scheme:path");
}

- (void)testURLWithEmptyAuthorityComponentButRelativePath;
{
    KSURLComponents *components = [[KSURLComponents alloc] init];
    components.scheme = @"scheme";
    components.host = @"";
    components.path = @"path";
    
    NSURL *url = [components URL];
    XCTAssertNil(url);
}

- (void)testURLFromAuthorityComponentAndRelativePath
{
    KSURLComponents *components = [KSURLComponents componentsWithString:@"http://example.com"];
    components.path = @"relative";
    
    NSURL *url = [components URL];
    XCTAssertNil(url, @"If the KSURLComponents has an authority component (user, password, host or port) and a path component, then the path must either begin with \"/\" or be an empty string");
}

- (void)testURLFromNoAuthorityComponentAndProtocolRelativePath
{
    KSURLComponents *components = [[KSURLComponents alloc] init];
    components.scheme = @"scheme";
    components.path = @"//protocol/relative";
    
    NSURL *url = [components URL];
    XCTAssertNil(url, @"If the KSURLComponents does not have an authority component (user, password, host or port) and has a path component, the path component must not start with \"//\"");
    
    [components release];
}

#pragma mark NSCopying

- (void)testCopying;
{
    KSURLComponents *components = [KSURLComponents componentsWithURL:[NSURL URLWithString:@"scheme://user:password@host:0/path?query#fragment"]
                                             resolvingAgainstBaseURL:NO];
    
    KSURLComponents *components2 = [components copy];
    
    XCTAssertEqualObjects(components, components2);
    [components2 release];
}

#pragma mark Query Parameters

- (void)testNilQuery;
{
    KSURLQuery *query = [[KSURLQuery alloc] init];
    NSDictionary *parameters = [query parametersWithOptions:0];
    
    XCTAssertNil(parameters);
}

- (void)testEmptyQuery;
{
    KSURLQuery *query = [KSURLQuery queryWithURL:[NSURL URLWithString:@"scheme://host?"]];
    
    NSDictionary *parameters = [query parametersWithOptions:0];
    XCTAssertNil(parameters);
    
    __block BOOL blockCalled = NO;
    [query enumerateParametersWithOptions:0 usingBlock:^(NSString *key, NSString *value, BOOL *stop) {
        XCTAssertEqualObjects(key, @"");
        XCTAssertNil(value);
        blockCalled = YES;
    }];
    XCTAssertTrue(blockCalled);
}

- (void)testNonParameterisedQuery;
{
    KSURLQuery *query = [KSURLQuery queryWithURL:[NSURL URLWithString:@"scheme://host?query"]];
    
    NSDictionary *parameters = [query parametersWithOptions:0];
    XCTAssertNil(parameters);
    
    __block BOOL blockCalled = NO;
    [query enumerateParametersWithOptions:0 usingBlock:^(NSString *key, NSString *value, BOOL *stop) {
        XCTAssertEqualObjects(key, @"query");
        XCTAssertNil(value);
        blockCalled = YES;
    }];
    XCTAssertTrue(blockCalled);
}

- (void)testSingleQueryParameter;
{
    KSURLQuery *query = [KSURLQuery queryWithURL:[NSURL URLWithString:@"scheme://host?key=value"]];
    
    NSDictionary *parameters = [query parametersWithOptions:0];
    XCTAssertEqualObjects(parameters, @{ @"key" : @"value" });
}

- (void)testQueryParameters;
{
    KSURLQuery *query = [KSURLQuery queryWithURL:[NSURL URLWithString:@"scheme://host?key=value&foo=bar"]];
    
    NSDictionary *parameters = [query parametersWithOptions:0];
    NSDictionary *expected = @{ @"key" : @"value", @"foo" : @"bar" };
    XCTAssertEqualObjects(parameters, expected);
}

- (void)testEmptyQueryParameterKey;
{
    KSURLQuery *query = [KSURLQuery queryWithURL:[NSURL URLWithString:@"scheme://host?=value"]];
    
    NSDictionary *parameters = [query parametersWithOptions:0];
    XCTAssertEqualObjects(parameters, @{ @"" : @"value" });
}

- (void)testEmptyQueryParameterValue;
{
    KSURLQuery *query = [KSURLQuery queryWithURL:[NSURL URLWithString:@"scheme://host?key="]];
    
    NSDictionary *parameters = [query parametersWithOptions:0];
    XCTAssertEqualObjects(parameters, @{ @"key" : @"" });
}

- (void)testRepeatedKeys;
{
    KSURLQuery *query = [KSURLQuery queryWithURL:[NSURL URLWithString:@"scheme://host?key=value&key=value2"]];
    
    NSDictionary *parameters = [query parametersWithOptions:0];
    XCTAssertNil(parameters);
    
    __block int blockCalled = 0;
    [query enumerateParametersWithOptions:0 usingBlock:^(NSString *key, NSString *value, BOOL *stop) {
        XCTAssertEqualObjects(key, @"key");
        XCTAssertEqualObjects(value, (blockCalled ? @"value2" : @"value"));
        ++blockCalled;
    }];
    XCTAssertEqual(blockCalled, 2);
}

- (void)testEqualsSignInQueryParameterValue;
{
    KSURLQuery *query = [KSURLQuery queryWithURL:[NSURL URLWithString:@"scheme://host?key=val=ue"]];
    
    NSDictionary *parameters = [query parametersWithOptions:0];
    XCTAssertEqualObjects(parameters, @{ @"key" : @"val=ue" });
}

- (void)testQueryParameterUnescaping;
{
    KSURLQuery *query = [KSURLQuery queryWithURL:[NSURL URLWithString:@"scheme://host?k%2Fy=va%2Fue"]];
    
    NSDictionary *parameters = [query parametersWithOptions:0];
    XCTAssertEqualObjects(parameters, @{ @"k/y" : @"va/ue" });
}

- (void)testPlusSymbolInQueryParameters;
{
    KSURLQuery *query = [KSURLQuery queryWithURL:[NSURL URLWithString:@"?size=%7B64%2C+64%7D"]];
    
    NSDictionary *parameters = [query parametersWithOptions:0];
    XCTAssertEqualObjects(parameters, @{ @"size" : @"{64,+64}" });
    
    parameters = [query parametersWithOptions:KSURLQueryParameterDecodingPlusAsSpace];
    XCTAssertEqualObjects(parameters, @{ @"size" : @"{64, 64}" });
}

- (void)testEncodeNilQueryParameters;
{
    KSURLQuery *query = [[KSURLQuery alloc] init];
    [query setParameters:nil];
    XCTAssertNil(query.percentEncodedString);
}

- (void)testEncodeEmptyQueryParameters;
{
    KSURLQuery *query = [[KSURLQuery alloc] init];
    [query setParameters:@{ }];
    XCTAssertEqualObjects(query.percentEncodedString, @"");
}

- (void)testEncodeQueryParameter;
{
    KSURLQuery *query = [[KSURLQuery alloc] init];
    [query setParameters:@{ @"key" : @"value" }];
    XCTAssertEqualObjects(query.percentEncodedString, @"key=value");
}

- (void)testEncodeQueryParameters;
{
    KSURLQuery *query = [[KSURLQuery alloc] init];
    [query setParameters:@{ @"key" : @"value", @"key2" : @"value2" }];
    XCTAssertEqualObjects(query.percentEncodedString, @"key=value&key2=value2");
}

- (void)testEncodeQueryParameterEscaping;
{
    KSURLQuery *query = [[KSURLQuery alloc] init];
    [query setParameters:@{ @"!*'();:@&=+$,/?#[]" : @"!*'();:@&=+$,/?#[]" }];
    XCTAssertEqualObjects(query.percentEncodedString, @"!*'();:@%26%3D%2B$,/?%23%5B%5D=!*'();:@%26=%2B$,/?%23%5B%5D");
}

@end
