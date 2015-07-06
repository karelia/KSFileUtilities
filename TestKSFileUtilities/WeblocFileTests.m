//
//  WeblocFileTests.m
//  KSFileUtilities
//
//  Created by Mike on 06/07/2015.
//  Copyright (c) 2015 Jungle Candy Software. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "KSWebLocation.h"


@interface WeblocFileTests : XCTestCase

@end

@implementation WeblocFileTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testReadingWeblocFile {
    
    NSURL *url = [[NSBundle bundleForClass:self.class] URLForResource:@"Example Domain" withExtension:@"webloc"];
    XCTAssertNotNil(url);
    
    KSWebLocation *location = [[KSWebLocation alloc] initWithContentsOfWeblocFile:url];
    XCTAssertNotNil(location);
    XCTAssertEqualObjects(location.URL.absoluteString, @"http://example.com/");
    XCTAssertEqualObjects(location.title, @"Example Domain");
}

@end
