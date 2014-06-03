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

- (void)testURLStrings {
    NSURL *url = [[NSBundle bundleForClass:self.class] URLForResource:@"URLComponents" withExtension:@"testdata"];
    NSArray *data = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfURL:url] options:0 error:NULL];
    
    for (NSDictionary *properties in data) {
		
		NSURL *url = [NSURL URLWithString:properties[@"String"] relativeToURL:[NSURL URLWithString:properties[@"baseURL"]]];
		
		{{
			KSURLComponents *components = [KSURLComponents componentsWithURL:url resolvingAgainstBaseURL:NO];
			
			STAssertEqualObjects(components.scheme, properties[@"scheme"], nil);
			STAssertEqualObjects(components.user, properties[@"user"], nil);
			STAssertEqualObjects(components.percentEncodedUser, properties[@"percentEncodedUser"], nil);
			STAssertEqualObjects(components.password, properties[@"password"], nil);
			STAssertEqualObjects(components.percentEncodedPassword, properties[@"percentEncodedPassword"], nil);
			STAssertEqualObjects(components.host, properties[@"host"], nil);
			STAssertEqualObjects(components.percentEncodedHost, properties[@"percentEncodedHost"], nil);
			STAssertEqualObjects(components.port, properties[@"port"], nil);
			STAssertEqualObjects(components.path, properties[@"path"], nil);
			STAssertEqualObjects(components.percentEncodedPath, properties[@"percentEncodedPath"], nil);
			STAssertEqualObjects(components.query, properties[@"query"], nil);
			STAssertEqualObjects(components.percentEncodedQuery, properties[@"percentEncodedQuery"], nil);
			STAssertEqualObjects(components.fragment, properties[@"fragment"], nil);
			STAssertEqualObjects(components.percentEncodedFragment, properties[@"percentEncodedFragment"], nil);
		}}
		
		{{
			NSURLComponents *components = [NSURLComponents componentsWithURL:url resolvingAgainstBaseURL:NO];
			
			STAssertEqualObjects(components.scheme, properties[@"scheme"], nil);
			STAssertEqualObjects(components.user, properties[@"user"], nil);
			STAssertEqualObjects(components.percentEncodedUser, properties[@"percentEncodedUser"], nil);
			STAssertEqualObjects(components.password, properties[@"password"], nil);
			STAssertEqualObjects(components.percentEncodedPassword, properties[@"percentEncodedPassword"], nil);
			STAssertEqualObjects(components.host, properties[@"host"], nil);
			STAssertEqualObjects(components.percentEncodedHost, properties[@"percentEncodedHost"], nil);
			STAssertEqualObjects(components.port, properties[@"port"], nil);
			STAssertEqualObjects(components.path, properties[@"path"], nil);
			STAssertEqualObjects(components.percentEncodedPath, properties[@"percentEncodedPath"], nil);
			STAssertEqualObjects(components.query, properties[@"query"], nil);
			STAssertEqualObjects(components.percentEncodedQuery, properties[@"percentEncodedQuery"], nil);
			STAssertEqualObjects(components.fragment, properties[@"fragment"], nil);
			STAssertEqualObjects(components.percentEncodedFragment, properties[@"percentEncodedFragment"], nil);
		}}
    }
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

@end
