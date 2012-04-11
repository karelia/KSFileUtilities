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

- (void)checkURL:(NSURL *)a relativeToURL:(NSURL *)b againstExpectedResult:(NSString *)expectedResult checkByAppendingToURLToo:(BOOL)testAppending;
{
    // Regular
    NSString *result = [a ks_stringRelativeToURL:b];
    
    STAssertTrue([result isEqualToString:expectedResult],
                 @"\'%@\' relative to \'%@\' should be \'%@\' instead of \'%@\'",
                 a,
                 b,
                 expectedResult,
                 result);
    
    
    // Get NSURL to see if it agrees with the result
    NSURL *nsurlsOpinion = [[[NSURL URLWithString:result relativeToURL:b] absoluteURL] standardizedURL];    // gotta do absoluteURL first apparently
    STAssertEqualObjects([nsurlsOpinion absoluteString], [a absoluteString],
                         @"(\'%@\' relative to \'%@\')",
                         result,
                         b,
                         [a absoluteString],
                         nsurlsOpinion);
    
    
    // A trailing
    if (testAppending)
    {
        NSURL *aTrailing = [NSURL URLWithString:[a.relativeString stringByAppendingString:@"/"] relativeToURL:a.baseURL];
        //NSURL *bTrailing = [NSURL URLWithString:[b.relativeString stringByAppendingString:@"/"] relativeToURL:b.baseURL];
        
        [self checkURL:aTrailing relativeToURL:b againstExpectedResult:[expectedResult stringByAppendingString:@"/"] checkByAppendingToURLToo:NO];
        
        
        // Percent encoding, but not for root URLs
        NSString *encodedSlash = @"%2F";
        if (![[a relativeString] hasSuffix:encodedSlash] && a.path.length)
        {
            NSURL *aWithCrazyEncoding = [NSURL URLWithString:[a.relativeString stringByAppendingString:encodedSlash] relativeToURL:a.baseURL];
            
            [self checkURL:aWithCrazyEncoding
             relativeToURL:b
     againstExpectedResult:[expectedResult stringByAppendingString:encodedSlash]
  checkByAppendingToURLToo:YES];
        }
    }
}

/*  Performs test pretty much as it says on the tin
 *  URLs are tested as given, but then also with a trailing slash applied to A
 *  Similarly they are also tested by appending escaping sequences to check escaping is working fine
 */
- (void)checkURL:(NSURL *)a relativeToURL:(NSURL *)b againstExpectedResult:(NSString *)expectedResult;
{
    [self checkURL:a relativeToURL:b againstExpectedResult:expectedResult checkByAppendingToURLToo:![a ks_hasDirectoryPath]];
}

- (void)testURLRelativeToURL
{
    // Impossible to find a relative path
    [self checkURL:URL(@"http://example.com") relativeToURL:URL(@"https://example.com/") againstExpectedResult:@"http://example.com"];
    [self checkURL:URL(@"http://example.com") relativeToURL:URL(@"http://example.org/")  againstExpectedResult:@"http://example.com"];
    [self checkURL:URL(@"http://example.com") relativeToURL:URL(@"")                     againstExpectedResult:@"http://example.com"];
    [self checkURL:URL(@"http://example.com:5000/") relativeToURL:URL(@"http://example.com/") againstExpectedResult:@"http://example.com:5000/"];
    
    
    
    // Same
    [self checkURL:URL(@"http://example.com") relativeToURL:URL(@"http://example.com")  againstExpectedResult:@"."];
    [self checkURL:URL(@"http://example.com") relativeToURL:URL(@"http://example.com/")  againstExpectedResult:@"."];
    [self checkURL:URL(@"http://example.com/foo") relativeToURL:URL(@"http://example.com/foo")  againstExpectedResult:@"foo"];
    
    // somewhat of a special case:
    [self checkURL:URL(@"http://example.com/foo") relativeToURL:URL(@"http://example.com/foo/") againstExpectedResult:@"../foo" checkByAppendingToURLToo:NO];
    [self checkURL:URL(@"http://example.com/foo/") relativeToURL:URL(@"http://example.com/foo/") againstExpectedResult:@"./" checkByAppendingToURLToo:NO];
    [self checkURL:URL(@"http://example.com/foo%2F") relativeToURL:URL(@"http://example.com/foo/") againstExpectedResult:@"../foo%2F"];
    
    
    
    // Diving in
    [self checkURL:URL(@"http://example.com/foo")     relativeToURL:URL(@"http://example.com")         againstExpectedResult:@"foo"];
    [self checkURL:URL(@"http://example.com/foo/bar") relativeToURL:URL(@"http://example.com")         againstExpectedResult:@"foo/bar"];
    [self checkURL:URL(@"http://example.com/foo/bar") relativeToURL:URL(@"http://example.com/foo")  againstExpectedResult:@"foo/bar"];
    [self checkURL:URL(@"http://example.com/foo/bar") relativeToURL:URL(@"http://example.com/foo/") againstExpectedResult:@"bar"];
    
    
    
    // Walking out
    [self checkURL:URL(@"http://example.com") relativeToURL:URL(@"http://example.com/foo%2F")      againstExpectedResult:@"."];
    [self checkURL:URL(@"http://example.com") relativeToURL:URL(@"http://example.com/foo%2F/")     againstExpectedResult:@".."];
    [self checkURL:URL(@"http://example.com") relativeToURL:URL(@"http://example.com/foo%2F/bar")  againstExpectedResult:@".."];
    [self checkURL:URL(@"http://example.com") relativeToURL:URL(@"http://example.com/foo%2F/bar/") againstExpectedResult:@"../.."];
    
    
    
    // Cross-directory
    [self checkURL:URL(@"http://example.com/foo")     relativeToURL:URL(@"http://example.com/bar")         againstExpectedResult:@"foo"];
    [self checkURL:URL(@"http://example.com/foo")     relativeToURL:URL(@"http://example.com/bar/")        againstExpectedResult:@"../foo"];
    [self checkURL:URL(@"http://example.com/foo/bar") relativeToURL:URL(@"http://example.com/bar")         againstExpectedResult:@"foo/bar"];
    [self checkURL:URL(@"http://example.com/foo/bar") relativeToURL:URL(@"http://example.com/bar/")        againstExpectedResult:@"../foo/bar"];
    [self checkURL:URL(@"http://example.com/foo/bar") relativeToURL:URL(@"http://example.com/bar/foo%2F")  againstExpectedResult:@"../foo/bar"];
    [self checkURL:URL(@"http://example.com/foo/bar") relativeToURL:URL(@"http://example.com/bar/foo%2F/") againstExpectedResult:@"../../foo/bar"];
}

@end
