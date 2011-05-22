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
NSString * const pathFooBar = @"/foo/bar";



#pragma mark - Tests

- (void)testPathRelativeToDirectory {
    // Test cases for ks_pathRelativeToDirectory
    NSString *result;
    NSString *expectedResult;

    result = [pathFoo ks_pathRelativeToDirectory:pathRoot];
    expectedResult = @"foo";
    STAssertTrue([result isEqualToString:expectedResult], @"\'%@\' relative to \'%@\' should be \'%@\' instead of \'%@\'", pathFoo, pathRoot, expectedResult, result);
    
    
    result = [pathFoo ks_pathRelativeToDirectory:pathFooBar];
    expectedResult = @"..";
    STAssertTrue([result isEqualToString:expectedResult], @"\'%@\' relative to \'%@\' should be \'%@\' instead of \'%@\'", pathFoo, pathRoot, expectedResult, result);
}

@end
