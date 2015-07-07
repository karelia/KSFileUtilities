//
//  WeblocFileTests.m
//  KSFileUtilities
//
//  Created by Mike on 06/07/2015.
//  Copyright (c) 2015 Karelia Software. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "KSWebLocation.h"


@interface KSWebLocationTests : XCTestCase

@end

@implementation KSWebLocationTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testTitleless {
    KSWebLocation *webloc = [KSWebLocation webLocationWithURL:[NSURL URLWithString:@"http://example.com"]];
    XCTAssertNotNil(webloc);
    XCTAssertEqualObjects(webloc.URL.absoluteString, @"http://example.com");
    XCTAssertNil(webloc.title);
}

- (void)testURLAndTitle {
    KSWebLocation *webloc = [KSWebLocation webLocationWithURL:[NSURL URLWithString:@"http://example.com"]
                                                        title:@"Test"];
    
    XCTAssertNotNil(webloc);
    XCTAssertEqualObjects(webloc.URL.absoluteString, @"http://example.com");
    XCTAssertEqualObjects(webloc.title, @"Test");
}

- (void)testNoURL {
    XCTAssertThrows([KSWebLocation webLocationWithURL:nil]);
}

@end
