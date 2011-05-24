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

- (void)testPath:(NSString *)path relativeToDirectory:(NSString *)dirPath expectedResult:(NSString *)expectedResult;
@end


@implementation TestKSPathUtilities

#pragma mark - Common test strings

NSString * const pathRoot = @"/";
NSString * const pathFoo = @"/foo";
NSString * const pathBaz = @"/baz";
NSString * const pathFooBar = @"/foo/bar";
NSString * const pathFooBaz = @"/foo/baz";
NSString * const pathBazBar = @"/baz/bar";

NSString * const pathRoot_TrailingSlash = @"//";
NSString * const pathFoo_TrailingSlash = @"/foo/";
NSString * const pathFooBar_TrailingSlash = @"/foo/bar/";

NSString * const pathFoo_Relative = @"foo";
NSString * const pathFooBar_Relative = @"foo/bar";



#pragma mark - Tests

- (void)testPath:(NSString *)path relativeToDirectory:(NSString *)dirPath expectedResult:(NSString *)expectedResult;
{
    NSString *result = [path ks_pathRelativeToDirectory:dirPath];
    
    STAssertTrue([result isEqualToString:expectedResult],
                 @"\'%@\' relative to \'%@\' should be \'%@\' instead of \'%@\'",
                 path,
                 dirPath,
                 expectedResult,
                 result);
}

- (void)testPathRelativeToDirectory {
    // Test cases for ks_pathRelativeToDirectory
    
    
    /*  No traversal needed
     */
    [self testPath:pathRoot relativeToDirectory:pathRoot expectedResult:@"."];
    [self testPath:pathFoo relativeToDirectory:pathFoo expectedResult:@"."];
    [self testPath:pathFooBar relativeToDirectory:pathFooBar expectedResult:@"."];
    
    
    
    /*  No traversal needed, trailing slashes
     */
    [self testPath:pathRoot_TrailingSlash relativeToDirectory:pathRoot_TrailingSlash expectedResult:@"."];
    [self testPath:pathRoot_TrailingSlash relativeToDirectory:pathRoot expectedResult:@"./"];
    [self testPath:pathRoot relativeToDirectory:pathRoot_TrailingSlash expectedResult:@"."];
    [self testPath:pathFoo_TrailingSlash relativeToDirectory:pathFoo_TrailingSlash expectedResult:@"."];
    [self testPath:pathFoo_TrailingSlash relativeToDirectory:pathFoo expectedResult:@"./"];
    [self testPath:pathFoo relativeToDirectory:pathFoo_TrailingSlash expectedResult:@"."];
    [self testPath:pathFooBar_TrailingSlash relativeToDirectory:pathFooBar_TrailingSlash expectedResult:@"."];
    [self testPath:pathFooBar_TrailingSlash relativeToDirectory:pathFooBar expectedResult:@"./"];
    [self testPath:pathFooBar relativeToDirectory:pathFooBar_TrailingSlash expectedResult:@"."];
    
        
    /*  No traversal needed, relative paths
     */
    [self testPath:pathFoo_Relative relativeToDirectory:pathFoo_Relative expectedResult:@"."];
    [self testPath:pathFooBar_Relative relativeToDirectory:pathFooBar_Relative expectedResult:@"."];
    
    
    /*  Traversing from root
     */
    [self testPath:pathFoo relativeToDirectory:pathRoot expectedResult:@"foo"];
    [self testPath:pathFooBar relativeToDirectory:pathRoot expectedResult:@"foo/bar"];
    [self testPath:pathFoo_TrailingSlash relativeToDirectory:pathRoot expectedResult:@"foo/"];
    [self testPath:pathFooBar_TrailingSlash relativeToDirectory:pathRoot expectedResult:@"foo/bar/"];
    
    
    
    /*  Traversing from unusual root
     */
    [self testPath:pathFoo relativeToDirectory:pathRoot_TrailingSlash expectedResult:@"foo"];
    [self testPath:pathFooBar relativeToDirectory:pathRoot_TrailingSlash expectedResult:@"foo/bar"];
    
    
    
    /*  Traversing back to root
     */
    [self testPath:pathRoot relativeToDirectory:pathFoo expectedResult:@".."];
    [self testPath:pathRoot relativeToDirectory:pathFooBar expectedResult:@"../.."];
    [self testPath:pathRoot relativeToDirectory:pathFoo_TrailingSlash expectedResult:@".."];
    [self testPath:pathRoot relativeToDirectory:pathFooBar_TrailingSlash expectedResult:@"../.."];
    
    
    
    /*  Traversing from parent folder
     */
    [self testPath:pathFooBar relativeToDirectory:pathFoo expectedResult:@"bar"];
    [self testPath:pathFooBar relativeToDirectory:pathFoo_TrailingSlash expectedResult:@"bar"];
    [self testPath:pathFooBar_TrailingSlash relativeToDirectory:pathFoo expectedResult:@"bar/"];
    
    
    
    /*  Traversing to parent folder
     */
    [self testPath:pathFoo relativeToDirectory:pathFooBar expectedResult:@".."];
    [self testPath:pathFoo relativeToDirectory:pathFooBar_TrailingSlash expectedResult:@".."];
    [self testPath:pathFoo_TrailingSlash relativeToDirectory:pathFooBar expectedResult:@".."]; // TODO: It would probably be nicer to return @"../" although this is valid
    
    
    /*  Only dir in common is root
     */
    [self testPath:pathFoo relativeToDirectory:pathBaz expectedResult:@"../foo"];
    [self testPath:pathFoo_TrailingSlash relativeToDirectory:pathBaz expectedResult:@"../foo/"];
    [self testPath:pathFooBar relativeToDirectory:pathBaz expectedResult:@"../foo/bar"];
    [self testPath:pathFooBar_TrailingSlash relativeToDirectory:pathBaz expectedResult:@"../foo/bar/"];
    [self testPath:pathBaz relativeToDirectory:pathFooBar expectedResult:@"../../baz"];
    
    
    /*  Foo dir is in common
     */
    [self testPath:pathFooBar relativeToDirectory:pathFooBaz expectedResult:@"../bar"];
}

@end
