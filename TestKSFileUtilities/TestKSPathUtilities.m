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

- (void)testPathRelativeToDirectory {
    // Test cases for ks_pathRelativeToDirectory
    NSString *result;
    NSString *expectedResult;
    
    
    /*  No traversal needed
     */
    result = [pathRoot ks_pathRelativeToDirectory:pathRoot];
    expectedResult = @".";
    STAssertTrue([result isEqualToString:expectedResult], @"\'%@\' relative to \'%@\' should be \'%@\' instead of \'%@\'", pathRoot, pathRoot, expectedResult, result);
    
    
    result = [pathFoo ks_pathRelativeToDirectory:pathFoo];
    expectedResult = @".";
    STAssertTrue([result isEqualToString:expectedResult], @"\'%@\' relative to \'%@\' should be \'%@\' instead of \'%@\'", pathFoo, pathFoo, expectedResult, result);
    
    
    result = [pathFooBar ks_pathRelativeToDirectory:pathFooBar];
    expectedResult = @".";
    STAssertTrue([result isEqualToString:expectedResult], @"\'%@\' relative to \'%@\' should be \'%@\' instead of \'%@\'", pathFooBar, pathFooBar, expectedResult, result);
    
    
    
    /*  No traversal needed, trailing slashes
     */
    result = [pathRoot_TrailingSlash ks_pathRelativeToDirectory:pathRoot_TrailingSlash];
    expectedResult = @".";
    STAssertTrue([result isEqualToString:expectedResult], @"\'%@\' relative to \'%@\' should be \'%@\' instead of \'%@\'", pathRoot_TrailingSlash, pathRoot_TrailingSlash, expectedResult, result);
    
    
    result = [pathRoot_TrailingSlash ks_pathRelativeToDirectory:pathRoot];
    expectedResult = @"./";
    STAssertTrue([result isEqualToString:expectedResult], @"\'%@\' relative to \'%@\' should be \'%@\' instead of \'%@\'", pathRoot_TrailingSlash, pathRoot, expectedResult, result);
    
    
    result = [pathRoot ks_pathRelativeToDirectory:pathRoot_TrailingSlash];
    expectedResult = @"./"; // this is legal, but would ideally be @"."
    STAssertTrue([result isEqualToString:expectedResult], @"\'%@\' relative to \'%@\' should be \'%@\' instead of \'%@\'", pathRoot, pathRoot_TrailingSlash, expectedResult, result);
    
    
    result = [pathFoo_TrailingSlash ks_pathRelativeToDirectory:pathFoo_TrailingSlash];
    expectedResult = @".";
    STAssertTrue([result isEqualToString:expectedResult], @"\'%@\' relative to \'%@\' should be \'%@\' instead of \'%@\'", pathFoo_TrailingSlash, pathFoo_TrailingSlash, expectedResult, result);
    
    
    result = [pathFoo_TrailingSlash ks_pathRelativeToDirectory:pathFoo];
    expectedResult = @"./";
    STAssertTrue([result isEqualToString:expectedResult], @"\'%@\' relative to \'%@\' should be \'%@\' instead of \'%@\'", pathFoo_TrailingSlash, pathFoo, expectedResult, result);
    
    
    result = [pathFoo ks_pathRelativeToDirectory:pathFoo_TrailingSlash];
    expectedResult = @".";
    STAssertTrue([result isEqualToString:expectedResult], @"\'%@\' relative to \'%@\' should be \'%@\' instead of \'%@\'", pathFoo, pathFoo_TrailingSlash, expectedResult, result);
    
    
    result = [pathFooBar_TrailingSlash ks_pathRelativeToDirectory:pathFooBar_TrailingSlash];
    expectedResult = @".";
    STAssertTrue([result isEqualToString:expectedResult], @"\'%@\' relative to \'%@\' should be \'%@\' instead of \'%@\'", pathFooBar_TrailingSlash, pathFooBar_TrailingSlash, expectedResult, result);
    
    
    result = [pathFooBar_TrailingSlash ks_pathRelativeToDirectory:pathFooBar];
    expectedResult = @"./";
    STAssertTrue([result isEqualToString:expectedResult], @"\'%@\' relative to \'%@\' should be \'%@\' instead of \'%@\'", pathFooBar_TrailingSlash, pathFooBar, expectedResult, result);
    
    
    result = [pathFooBar ks_pathRelativeToDirectory:pathFooBar_TrailingSlash];
    expectedResult = @".";
    STAssertTrue([result isEqualToString:expectedResult], @"\'%@\' relative to \'%@\' should be \'%@\' instead of \'%@\'", pathFooBar, pathFooBar_TrailingSlash, expectedResult, result);
    
    
    
    /*  No traversal needed, relative paths
     */
    result = [pathFoo_Relative ks_pathRelativeToDirectory:pathFoo_Relative];
    expectedResult = @".";
    STAssertTrue([result isEqualToString:expectedResult], @"\'%@\' relative to \'%@\' should be \'%@\' instead of \'%@\'", pathFoo_Relative, pathFoo_Relative, expectedResult, result);
    
    
    result = [pathFooBar_Relative ks_pathRelativeToDirectory:pathFooBar_Relative];
    expectedResult = @".";
    STAssertTrue([result isEqualToString:expectedResult], @"\'%@\' relative to \'%@\' should be \'%@\' instead of \'%@\'", pathFooBar_Relative, pathFooBar_Relative, expectedResult, result);
    
    
    /*  Traversing from root
     */
    result = [pathFoo ks_pathRelativeToDirectory:pathRoot];
    expectedResult = @"foo";
    STAssertTrue([result isEqualToString:expectedResult], @"\'%@\' relative to \'%@\' should be \'%@\' instead of \'%@\'", pathFoo, pathRoot, expectedResult, result);
    
    
    result = [pathFooBar ks_pathRelativeToDirectory:pathRoot];
    expectedResult = @"foo/bar";
    STAssertTrue([result isEqualToString:expectedResult], @"\'%@\' relative to \'%@\' should be \'%@\' instead of \'%@\'", pathFooBar, pathRoot, expectedResult, result);
    
    
    result = [pathFoo_TrailingSlash ks_pathRelativeToDirectory:pathRoot];
    expectedResult = @"foo/";
    STAssertTrue([result isEqualToString:expectedResult], @"\'%@\' relative to \'%@\' should be \'%@\' instead of \'%@\'", pathFoo_TrailingSlash, pathRoot, expectedResult, result);
    
    
    result = [pathFooBar_TrailingSlash ks_pathRelativeToDirectory:pathRoot];
    expectedResult = @"foo/bar/";
    STAssertTrue([result isEqualToString:expectedResult], @"\'%@\' relative to \'%@\' should be \'%@\' instead of \'%@\'", pathFooBar_TrailingSlash, pathRoot, expectedResult, result);
    
    
    
    /*  Traversing from unusual root
     */
    result = [pathFoo ks_pathRelativeToDirectory:pathRoot_TrailingSlash];
    expectedResult = @"foo";
    STAssertTrue([result isEqualToString:expectedResult], @"\'%@\' relative to \'%@\' should be \'%@\' instead of \'%@\'", pathFoo, pathRoot, expectedResult, result);
    
    
    result = [pathFooBar ks_pathRelativeToDirectory:pathRoot_TrailingSlash];
    expectedResult = @"foo/bar";
    STAssertTrue([result isEqualToString:expectedResult], @"\'%@\' relative to \'%@\' should be \'%@\' instead of \'%@\'", pathFooBar, pathRoot, expectedResult, result);
    
    
    
    /*  Traversing back to root
     */
    result = [pathRoot ks_pathRelativeToDirectory:pathFoo];
    expectedResult = @"..";
    STAssertTrue([result isEqualToString:expectedResult], @"\'%@\' relative to \'%@\' should be \'%@\' instead of \'%@\'", pathRoot, pathFoo, expectedResult, result);
    
    
    result = [pathRoot ks_pathRelativeToDirectory:pathFooBar];
    expectedResult = @"../..";
    STAssertTrue([result isEqualToString:expectedResult], @"\'%@\' relative to \'%@\' should be \'%@\' instead of \'%@\'", pathRoot, pathFooBar, expectedResult, result);
    
    
    result = [pathRoot ks_pathRelativeToDirectory:pathFoo_TrailingSlash];
    expectedResult = @"..";
    STAssertTrue([result isEqualToString:expectedResult], @"\'%@\' relative to \'%@\' should be \'%@\' instead of \'%@\'", pathRoot, pathFoo_TrailingSlash, expectedResult, result);
    
    
    result = [pathRoot ks_pathRelativeToDirectory:pathFooBar_TrailingSlash];
    expectedResult = @"../..";
    STAssertTrue([result isEqualToString:expectedResult], @"\'%@\' relative to \'%@\' should be \'%@\' instead of \'%@\'", pathRoot, pathFooBar_TrailingSlash, expectedResult, result);
    
    
    
    /*  Traversing from parent folder
     */
    result = [pathFooBar ks_pathRelativeToDirectory:pathFoo];
    expectedResult = @"bar";
    STAssertTrue([result isEqualToString:expectedResult], @"\'%@\' relative to \'%@\' should be \'%@\' instead of \'%@\'", pathFooBar, pathFoo, expectedResult, result);
    
    
    result = [pathFooBar ks_pathRelativeToDirectory:pathFoo_TrailingSlash];
    expectedResult = @"bar";
    STAssertTrue([result isEqualToString:expectedResult], @"\'%@\' relative to \'%@\' should be \'%@\' instead of \'%@\'", pathFooBar, pathFoo, expectedResult, result);
    
    
    result = [pathFooBar_TrailingSlash ks_pathRelativeToDirectory:pathFoo];
    expectedResult = @"bar/";
    STAssertTrue([result isEqualToString:expectedResult], @"\'%@\' relative to \'%@\' should be \'%@\' instead of \'%@\'", pathFooBar_TrailingSlash, pathFoo, expectedResult, result);
    
    
    
    /*  Traversing to parent folder
     */
    result = [pathFoo ks_pathRelativeToDirectory:pathFooBar];
    expectedResult = @"..";
    STAssertTrue([result isEqualToString:expectedResult], @"\'%@\' relative to \'%@\' should be \'%@\' instead of \'%@\'", pathFoo, pathFooBar, expectedResult, result);
    
    
    result = [pathFoo ks_pathRelativeToDirectory:pathFooBar_TrailingSlash];
    expectedResult = @"..";
    STAssertTrue([result isEqualToString:expectedResult], @"\'%@\' relative to \'%@\' should be \'%@\' instead of \'%@\'", pathFoo, pathFooBar_TrailingSlash, expectedResult, result);
    
    
    result = [pathFoo_TrailingSlash ks_pathRelativeToDirectory:pathFooBar];
    expectedResult = @".."; // TODO: It would probably be nicer to return @"../" although this is valid
    STAssertTrue([result isEqualToString:expectedResult], @"\'%@\' relative to \'%@\' should be \'%@\' instead of \'%@\'", pathFoo_TrailingSlash, pathFooBar, expectedResult, result);
    
    
    /*  Only dir in common is root
     */
    result = [pathFoo ks_pathRelativeToDirectory:pathBaz];
    expectedResult = @"../foo";
    STAssertTrue([result isEqualToString:expectedResult], @"\'%@\' relative to \'%@\' should be \'%@\' instead of \'%@\'", pathFoo, pathBaz, expectedResult, result);
    
    
    result = [pathFoo_TrailingSlash ks_pathRelativeToDirectory:pathBaz];
    expectedResult = @"../foo/";
    STAssertTrue([result isEqualToString:expectedResult], @"\'%@\' relative to \'%@\' should be \'%@\' instead of \'%@\'", pathFoo_TrailingSlash, pathBaz, expectedResult, result);
    
    
    result = [pathFooBar ks_pathRelativeToDirectory:pathBaz];
    expectedResult = @"../foo/bar";
    STAssertTrue([result isEqualToString:expectedResult], @"\'%@\' relative to \'%@\' should be \'%@\' instead of \'%@\'", pathFooBar, pathBaz, expectedResult, result);
    
    
    result = [pathFooBar_TrailingSlash ks_pathRelativeToDirectory:pathBaz];
    expectedResult = @"../foo/bar/";
    STAssertTrue([result isEqualToString:expectedResult], @"\'%@\' relative to \'%@\' should be \'%@\' instead of \'%@\'", pathFooBar_TrailingSlash, pathBaz, expectedResult, result);
    
    
    result = [pathBaz ks_pathRelativeToDirectory:pathFooBar];
    expectedResult = @"../../baz";
    STAssertTrue([result isEqualToString:expectedResult], @"\'%@\' relative to \'%@\' should be \'%@\' instead of \'%@\'", pathBaz, pathFooBar, expectedResult, result);
    
    
    /*  Foo dir is in common
     */
    result = [pathFooBar ks_pathRelativeToDirectory:pathFooBaz];
    expectedResult = @"../bar";
    STAssertTrue([result isEqualToString:expectedResult], @"\'%@\' relative to \'%@\' should be \'%@\' instead of \'%@\'", pathFooBar, pathFooBaz, expectedResult, result);
}

@end
