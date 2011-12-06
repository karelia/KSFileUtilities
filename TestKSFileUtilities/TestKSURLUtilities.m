//
//  TestKSURLUtilities.m
//  KSFileUtilities
//
//  Created by Mike on 06/12/2011.
//  Copyright 2011 Jungle Candy Software. All rights reserved.
//


#import <SenTestingKit/SenTestingKit.h>
#import "KSURLUtilities.h"


@interface TestKSURLUtilities : SenTestCase
@end


#pragma mark -


@implementation TestKSURLUtilities

#pragma mark - Test helpers.

/*  Performs test pretty much as it says on the tin
 *  URLs are tested as given, but then also with a trailing slash applied to A
 */
- (void)checkURL:(NSURL *)a relativeToURL:(NSURL *)b againstExpectedResult:(NSString *)expectedResult;
{
    NSURL *aTrailing = [NSURL URLWithString:[a.relativeString stringByAppendingString:@"/"] relativeToURL:a.baseURL];
    //NSURL *bTrailing = [NSURL URLWithString:[b.relativeString stringByAppendingString:@"/"] relativeToURL:b.baseURL];
    
    
    // Regular
    NSString *result = [a ks_stringRelativeToURL:b];
    
    STAssertTrue([result isEqualToString:expectedResult],
                 @"\'%@\' relative to \'%@\' should be \'%@\' instead of \'%@\'",
                 a,
                 b,
                 expectedResult,
                 result);
    
    
    // A trailing
    result = [aTrailing ks_stringRelativeToURL:b];
    expectedResult = [expectedResult stringByAppendingString:@"/"];
    
    STAssertTrue([result isEqualToString:expectedResult],
                 @"\'%@\' relative to \'%@\' should be \'%@\' instead of \'%@\'",
                 aTrailing,
                 b,
                 expectedResult,
                 result);
    
}

- (void)testURLRelativeToURL
{
    NSURL *exampleURL = [NSURL URLWithString:@"http://example.com/"];
    
    // Impossible to find a relative path
    [self checkURL:exampleURL relativeToURL:[NSURL URLWithString:@"https://example.com/"] againstExpectedResult:@"http://example.com/"];
    [self checkURL:exampleURL relativeToURL:[NSURL URLWithString:@"http://example.org/"] againstExpectedResult:@"http://example.com/"];
    [self checkURL:exampleURL relativeToURL:[NSURL URLWithString:@""] againstExpectedResult:@"http://example.com/"];
    
    
    // Diving in
    [self checkURL:[NSURL URLWithString:@"http://example.com/foo"] relativeToURL:exampleURL againstExpectedResult:@"foo"];
    [self checkURL:[NSURL URLWithString:@"http://example.com/foo/bar"] relativeToURL:exampleURL againstExpectedResult:@"foo/bar"];
    
    [self checkURL:[NSURL URLWithString:@"http://example.com/foo/bar"]
     relativeToURL:[NSURL URLWithString:@"http://example.com/foo/"]
againstExpectedResult:@"bar"];

    [self checkURL:[NSURL URLWithString:@"http://example.com/foo/bar"]
     relativeToURL:[NSURL URLWithString:@"http://example.com/foo"]
againstExpectedResult:@"foo/bar"];
    
}

@end
