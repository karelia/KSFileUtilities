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

#define URL(string) [NSURL URLWithString:string]
#define RELURL(string, base) [NSURL URLWithString:string relativeToURL:base]

/*  Performs test pretty much as it says on the tin
 *  URLs are tested as given, but then also with a trailing slash applied to A
 */
- (void)checkURL:(NSURL *)a relativeToURL:(NSURL *)b againstExpectedResult:(NSString *)expectedResult;
{
    
    
    // Regular
    NSString *result = [a ks_stringRelativeToURL:b];
    
    STAssertTrue([result isEqualToString:expectedResult],
                 @"\'%@\' relative to \'%@\' should be \'%@\' instead of \'%@\'",
                 a,
                 b,
                 expectedResult,
                 result);
    
    
    // A trailing
    if (![a ks_hasDirectoryPath])
    {
        NSURL *aTrailing = [NSURL URLWithString:[a.relativeString stringByAppendingString:@"/"] relativeToURL:a.baseURL];
        //NSURL *bTrailing = [NSURL URLWithString:[b.relativeString stringByAppendingString:@"/"] relativeToURL:b.baseURL];
        
        [self checkURL:aTrailing relativeToURL:b againstExpectedResult:[expectedResult stringByAppendingString:@"/"]];
    }
    
}

- (void)testURLRelativeToURL
{
    // Impossible to find a relative path
    [self checkURL:URL(@"http://example.com") relativeToURL:URL(@"https://example.com/") againstExpectedResult:@"http://example.com"];
    [self checkURL:URL(@"http://example.com") relativeToURL:URL(@"http://example.org/")  againstExpectedResult:@"http://example.com"];
    [self checkURL:URL(@"http://example.com") relativeToURL:URL(@"")                     againstExpectedResult:@"http://example.com"];
    
    
    // Same
    [self checkURL:URL(@"http://example.com") relativeToURL:URL(@"http://example.com")  againstExpectedResult:@"."];
    [self checkURL:URL(@"http://example.com") relativeToURL:URL(@"http://example.com/")  againstExpectedResult:@"."];
    
    
    // Diving in
    [self checkURL:URL(@"http://example.com/foo%2F")     relativeToURL:URL(@"http://example.com")         againstExpectedResult:@"foo%2F"];
    [self checkURL:URL(@"http://example.com/foo%2F/bar") relativeToURL:URL(@"http://example.com")         againstExpectedResult:@"foo%2F/bar"];
    [self checkURL:URL(@"http://example.com/foo%2F/bar") relativeToURL:URL(@"http://example.com/foo%2F")  againstExpectedResult:@"foo%2F/bar"];
    [self checkURL:URL(@"http://example.com/foo%2F/bar") relativeToURL:URL(@"http://example.com/foo%2F/") againstExpectedResult:@"bar"];
    
    
    // Walking out
    [self checkURL:URL(@"http://example.com") relativeToURL:URL(@"http://example.com/foo%2F")      againstExpectedResult:@"."];
    [self checkURL:URL(@"http://example.com") relativeToURL:URL(@"http://example.com/foo%2F/")     againstExpectedResult:@".."];
    [self checkURL:URL(@"http://example.com") relativeToURL:URL(@"http://example.com/foo%2F/bar")  againstExpectedResult:@".."];
    [self checkURL:URL(@"http://example.com") relativeToURL:URL(@"http://example.com/foo%2F/bar/") againstExpectedResult:@"../.."];
    
    
    // Cross-directory
    [self checkURL:URL(@"http://example.com/foo%2F")     relativeToURL:URL(@"http://example.com/bar")         againstExpectedResult:@"foo%2F"];
    [self checkURL:URL(@"http://example.com/foo%2F")     relativeToURL:URL(@"http://example.com/bar/")        againstExpectedResult:@"../foo%2F"];
    [self checkURL:URL(@"http://example.com/foo%2F/bar") relativeToURL:URL(@"http://example.com/bar")         againstExpectedResult:@"foo%2F/bar"];
    [self checkURL:URL(@"http://example.com/foo%2F/bar") relativeToURL:URL(@"http://example.com/bar/")        againstExpectedResult:@"../foo%2F/bar"];
    [self checkURL:URL(@"http://example.com/foo%2F/bar") relativeToURL:URL(@"http://example.com/bar/foo%2F")  againstExpectedResult:@"../foo%2F/bar"];
    [self checkURL:URL(@"http://example.com/foo%2F/bar") relativeToURL:URL(@"http://example.com/bar/foo%2F/") againstExpectedResult:@"../../foo%2F/bar"];
    
}

@end
