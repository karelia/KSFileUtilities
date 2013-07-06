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

@end
