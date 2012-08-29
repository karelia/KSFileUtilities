//
//  TestKSURLFormatter.m
//  KSFileUtilities
//
//  Created by Mike Abdullah on 12/04/2012.
//  Copyright (c) 2012 Jungle Candy Software. All rights reserved.
//

#import "TestKSURLFormatter.h"
#import "KSURLFormatter.h"


@implementation TestKSURLFormatter

- (void)testAllowedSchemesWithString:(NSString *)urlString expectedURLString:(NSString *)expectedResult
{
    KSURLFormatter *formatter = [[KSURLFormatter alloc] init];
    [formatter setAllowedSchemes:[NSArray arrayWithObjects:@"http", @"https", @"file", nil]];
    
    NSURL *URL = [formatter URLFromString:urlString];
    STAssertEqualObjects([URL absoluteString], expectedResult, nil);
    
    [formatter release];
}

- (void)testAllowedSchemesPrimary;
{
    [self testAllowedSchemesWithString:@"http://example.com/" expectedURLString:@"http://example.com/"];
}

- (void)testAllowedSchemesSecondary
{
    [self testAllowedSchemesWithString:@"https://example.com/" expectedURLString:@"https://example.com/"];
}

- (void)testAllowedSchemesCloseMatchPrimary
{
    [self testAllowedSchemesWithString:@"ttp://example.com/" expectedURLString:@"http://example.com/"];
}

- (void)testAllowedSchemesCloseMatchSecondary
{
    [self testAllowedSchemesWithString:@"ttps://example.com/" expectedURLString:@"https://example.com/"];
}

- (void)testAllowedSchemesRandom
{
    [self testAllowedSchemesWithString:@"test://example.com/" expectedURLString:@"http://example.com/"];
}

- (void)testPercentEncoding
{
    [self testAllowedSchemesWithString:@"test://test test.com/" expectedURLString:@"http://test%20test.com/"];
    [self testAllowedSchemesWithString:@"test://test test/" expectedURLString:@"http://test%20test.com/"];
    [self testAllowedSchemesWithString:@"test test/" expectedURLString:@"http://test%20test.com/"];
}

- (void)testLikelyEmailAddress
{
    STAssertFalse([KSURLFormatter isLikelyEmailAddress:@"http://example.com@foo.com"], @"It's a *valid* email address, but more likely to be a URL");
}

@end
