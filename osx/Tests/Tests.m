//
//  Tests.m
//  Tests
//
//  Created by Vladimir Ignatev on 07.12.13.
//  Copyright (c) 2013 Dropbox, Inc. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "NSString+LinkDetection.h"

@interface Tests : XCTestCase

@property(nonatomic, retain) NSArray* validEmails;
@property(nonatomic, retain) NSMutableArray* invalidEmails;

@property(nonatomic, retain) NSArray* validLinks;
@property(nonatomic, retain) NSMutableArray* invalidLinks;

@property(nonatomic, retain) NSArray* validUrls;
@property(nonatomic, retain) NSMutableArray* invalidUrls;

@end

@implementation Tests

- (void)setUp
{
    [super setUp];
    
    self.validEmails = @[
                         @"very.very-long.long1238@email.organization.info",
                         @"ya.na.pochte@gmail.com",
                         @"varuzhnikov@gmail.com",
                         @"huy@ivanov.krutoy.server.museum"
                         ];
    self.validLinks = @[@"itms-services://?action=download-manifest&url=http://www.yoursite.ru/dirname/yourFile.plist",
                        @"myapp-is-cool://showbigboobs!",
                        @"ftp://someuser:somepassword@very-long.domain.63.com"];
    
    self.validUrls = @[@"http://yandex.ru",
                       @"https://tumblr.com",
                       @"www.yandex.ru"];
    
    self.invalidEmails = [[NSMutableArray alloc] init];
    [self.invalidEmails addObjectsFromArray:@[]];
    [self.invalidEmails addObjectsFromArray:self.validUrls];
    [self.invalidEmails addObjectsFromArray:self.validLinks];

    self.invalidLinks = [[NSMutableArray alloc] init];
    [self.invalidLinks addObjectsFromArray:@[]];
    [self.invalidLinks addObjectsFromArray:self.validUrls];
    [self.invalidLinks addObjectsFromArray:self.validEmails];
    
    self.invalidUrls = [[NSMutableArray alloc] init];
    [self.invalidUrls addObjectsFromArray:@[]];
    [self.invalidUrls addObjectsFromArray:self.validLinks];
    [self.invalidUrls addObjectsFromArray:self.validEmails];
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testEmail
{
    for (NSString* example in self.validEmails) {
        XCTAssertTrue([example isEmail], @"");
    }
    
    for (NSString* example in self.invalidEmails) {
        XCTAssertFalse([example isEmail], @"");
    }
}

- (void)testSchemeLinks
{
    for (NSString* example in self.validLinks) {
        XCTAssertTrue([example isSchemeLink], @"");
    }
    
    for (NSString* example in self.invalidLinks) {
        XCTAssertFalse([example isSchemeLink], @"");
    }
}

- (void)testWebUrls
{
    for (NSString* example in self.validUrls) {
        XCTAssertTrue([example isWebURL], @"");
    }
    
    for (NSString* example in self.invalidUrls) {
        XCTAssertFalse([example isWebURL], @"");
    }
}

@end
