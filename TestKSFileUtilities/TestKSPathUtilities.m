//
//  TestKSPathUtilities.m
//  KSFileUtilities
//
//  Created by Abizer Nasir on 22/05/2011.
//

#import <SenTestingKit/SenTestingKit.h>
#import "KSPathUtilities.h"


@interface TestKSPathUtilities : SenTestCase {
@private
    
}

- (void)checkPath:(NSString *)path relativeToDirectory:(NSString *)dirPath againstExpectedResult:(NSString *)expectedResult;
@end


@implementation TestKSPathUtilities

#pragma mark - Test helpers.

/*  Performs test pretty much as it says on the tin
 *  If you pass in a non-absolute path, will test that, plus absolute equivalent
 */
- (void)checkPath:(NSString *)path relativeToDirectory:(NSString *)dirPath againstExpectedResult:(NSString *)expectedResult;
{
    NSString *result = [path ks_pathRelativeToDirectory:dirPath];
    
    STAssertTrue([result isEqualToString:expectedResult],
                 @"\'%@\' relative to \'%@\' should be \'%@\' instead of \'%@\'",
                 path,
                 dirPath,
                 expectedResult,
                 result);
    
    if (![path isAbsolutePath] && ![dirPath isAbsolutePath])
    {
        path = [@"/" stringByAppendingString:path];
        
        // Absolute path, relative to a relative path = the exact path
        [self checkPath:path relativeToDirectory:dirPath againstExpectedResult:path];
        
        // Absolute variants of the paths should give the same result
        [self checkPath:path
   relativeToDirectory:[@"/" stringByAppendingString:dirPath]
        againstExpectedResult:expectedResult];
    }
}

#pragma mark - Tests

- (void)testPathRelativeToDirectory {
    // Test cases for ks_pathRelativeToDirectory
    
    
    /*  No traversal needed
     */
    [self checkPath:@"/" relativeToDirectory:@"/" againstExpectedResult:@"."];
    [self checkPath:@"foo" relativeToDirectory:@"foo" againstExpectedResult:@"."];
    [self checkPath:@"foo/bar" relativeToDirectory:@"foo/bar" againstExpectedResult:@"."];
    
    
    
    /*  No traversal needed, trailing slashes
     */
    [self checkPath:@"//" relativeToDirectory:@"//" againstExpectedResult:@"."];
    [self checkPath:@"//" relativeToDirectory:@"/" againstExpectedResult:@"./"];
    [self checkPath:@"/" relativeToDirectory:@"//" againstExpectedResult:@"."];
    [self checkPath:@"/." relativeToDirectory:@"/" againstExpectedResult:@"."];
    [self checkPath:@"/.////././//" relativeToDirectory:@"/" againstExpectedResult:@".////././//"];
    [self checkPath:@"/" relativeToDirectory:@"/." againstExpectedResult:@"."];
    [self checkPath:@"/" relativeToDirectory:@"/.//.///." againstExpectedResult:@"."];
    
    [self checkPath:@"foo/" relativeToDirectory:@"foo/" againstExpectedResult:@"."];
    [self checkPath:@"foo/" relativeToDirectory:@"foo" againstExpectedResult:@"./"];
    [self checkPath:@"foo" relativeToDirectory:@"foo/" againstExpectedResult:@"."];
    [self checkPath:@"foo/bar/" relativeToDirectory:@"foo/bar/" againstExpectedResult:@"."];
    [self checkPath:@"foo/bar/" relativeToDirectory:@"foo/bar" againstExpectedResult:@"./"];
    [self checkPath:@"foo/bar" relativeToDirectory:@"foo/bar/" againstExpectedResult:@"."];
    
        
    
    /*  Traversing from root
     */
    [self checkPath:@"/foo" relativeToDirectory:@"/" againstExpectedResult:@"foo"];
    [self checkPath:@"/foo/bar" relativeToDirectory:@"/" againstExpectedResult:@"foo/bar"];
    [self checkPath:@"/foo/" relativeToDirectory:@"/" againstExpectedResult:@"foo/"];
    [self checkPath:@"/foo/bar/" relativeToDirectory:@"/" againstExpectedResult:@"foo/bar/"];
    
    
    
    /*  Traversing from unusual root
     */
    [self checkPath:@"/foo" relativeToDirectory:@"//" againstExpectedResult:@"foo"];
    [self checkPath:@"/foo/bar" relativeToDirectory:@"//" againstExpectedResult:@"foo/bar"];
    
    
    
    /*  Traversing back to root
     */
    [self checkPath:@"/" relativeToDirectory:@"/foo" againstExpectedResult:@".."];
    [self checkPath:@"/" relativeToDirectory:@"/foo/bar" againstExpectedResult:@"../.."];
    [self checkPath:@"/" relativeToDirectory:@"/foo/" againstExpectedResult:@".."];
    [self checkPath:@"/" relativeToDirectory:@"/foo/bar/" againstExpectedResult:@"../.."];
    
    
    
    /*  Traversing from parent folder
     */
    [self checkPath:@"foo/bar" relativeToDirectory:@"foo" againstExpectedResult:@"bar"];
    [self checkPath:@"foo/bar" relativeToDirectory:@"foo/" againstExpectedResult:@"bar"];
    [self checkPath:@"foo/bar/" relativeToDirectory:@"foo" againstExpectedResult:@"bar/"];
        
    
    
    /*  Traversing to parent folder
     */
    [self checkPath:@"foo" relativeToDirectory:@"foo/bar" againstExpectedResult:@".."];
    [self checkPath:@"foo" relativeToDirectory:@"foo/bar/" againstExpectedResult:@".."];
    [self checkPath:@"foo/" relativeToDirectory:@"foo/bar" againstExpectedResult:@".."]; // TODO: It would probably be nicer to return @"../" although this is valid
    
    
    
    /*  Only dir in common is root
     */
    [self checkPath:@"/foo" relativeToDirectory:@"/baz" againstExpectedResult:@"../foo"];
    [self checkPath:@"/foo/" relativeToDirectory:@"/baz" againstExpectedResult:@"../foo/"];
    [self checkPath:@"/foo/bar" relativeToDirectory:@"/baz" againstExpectedResult:@"../foo/bar"];
    [self checkPath:@"/foo/bar/" relativeToDirectory:@"/baz" againstExpectedResult:@"../foo/bar/"];
    [self checkPath:@"/baz" relativeToDirectory:@"/foo/bar" againstExpectedResult:@"../../baz"];
    
    
    /*  Foo dir is in common
     */
    [self checkPath:@"foo/bar" relativeToDirectory:@"foo/baz" againstExpectedResult:@"../bar"];
}

- (void)testStringByIncrementingPath;
{
    NSString *path = @"foo/bar.png/";
    path = [path ks_stringByIncrementingPath];
    
    STAssertTrue([path isEqualToString:@"foo/bar-2.png"],
                 @"Incremented path \'%@\' should be \'%@\'",
                 path,
                 @"foo/bar-2.png");
    
    path = [path ks_stringByIncrementingPath];
    
    STAssertTrue([path isEqualToString:@"foo/bar-3.png"],
                 @"Incremented path \'%@\' should be \'%@\'",
                 path,
                 @"foo/bar-3.png");
    
    
    
    path = @"foo/bar/";
    path = [path ks_stringByIncrementingPath];
    
    STAssertTrue([path isEqualToString:@"foo/bar-2"],
                 @"Incremented path \'%@\' should be \'%@\'",
                 path,
                 @"foo/bar-2");
    
    path = [path ks_stringByIncrementingPath];
    
    STAssertTrue([path isEqualToString:@"foo/bar-3"],
                 @"Incremented path \'%@\' should be \'%@\'",
                 path,
                 @"foo/bar-3");
}

@end
