//
//  LocalStoryTests.m
//  LocalStoryTests
//
//  Created by Jacob Hawken on 11/14/14.
//  Copyright (c) 2014 Jacob Hawken. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "NetworkController.h"
#import "Story.h"
#import "SearchArea.h"


@interface LocalStoryTests : XCTestCase

@property (nonatomic, weak) NetworkController *networkController;
@property (nonatomic, strong) SearchArea *searchArea;
@property (nonatomic, strong) Story *story;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSString *pwd1;
@property (nonatomic, strong) NSString *pwd2;
@property (nonatomic, strong) NSString *pwd3;

@end

@implementation LocalStoryTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
  self.networkController = [NetworkController sharedNetworkController];

  NSDate *date = [NSDate date];
  NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
  [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSZ"];

  NSString *dateVal = [formatter stringFromDate:date];
  NSLog(@"dateVal = %@", dateVal);

  NSString *path = [[NSBundle mainBundle] pathForResource:@"avatar" ofType:@"jpg"];
  NSArray *pathParse = [path componentsSeparatedByString:@".app/"];
  NSString *filename = [pathParse lastObject];
  UIImage *imageFor = [UIImage imageNamed:filename];

  self.image = imageFor;

  self.searchArea = [[SearchArea alloc] init];
  self.searchArea.latMax = @"47.61935310123863";
  self.searchArea.latMin = @"47.62067738754244";
  self.searchArea.lngMax = @"-122.3397260020462";
  self.searchArea.lngMin = @"-122.3342328378582";

  self.story = [[Story alloc] init];

  self.username = [NSString stringWithFormat:@"UNIT TEST %@", dateVal];
  NSLog(@"username %@", self.username);
  self.pwd1 = @"DD";
  self.pwd2 = @"DD";
  self.pwd3 = @"D!";

  self.story.underscoreid = @"546ebc0a2506590200dc0269";
  self.story.title = [NSString stringWithFormat:@"TEST STORY TITLE %@", dateVal];
  self.story.story = [NSString stringWithFormat:@"TEST STORY BODY %@", dateVal];
  self.story.lat = [NSString stringWithFormat:@"47.62224566262243"];
  self.story.lng = [NSString stringWithFormat:@"-122.3367979041642"];

}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    // This is an example of a functional test case.
    XCTAssert(YES, @"Pass");
}

- (void)testMakeUserWithImage {
  NSLog(@"testMakeUserWithImage");
  XCTAssertNoThrow([self.networkController postAddNewUser:self.username withPassword:self.pwd1 withConfirmedPassword:self.pwd2]);
}

- (void)testUserList {
  NSLog(@"TESTING USER LIST");

  [self.networkController getStoriesForUserWithCompletionHandler:^(NSArray *stories) {
    XCTAssertTrue(stories);
  }];
}

- (void)testUserArea {
  NSLog(@"TESTING USER AREA");

  [self.networkController getStoriesInView:self.searchArea completionHandler:^(NSArray *stories) {
    XCTAssertTrue(stories);
  }];
  
}





- (void)testMakeStoryWithImage {
  NSLog(@"testMakeStoryWithImage");
  XCTAssertNoThrow([self.networkController postNewStoryToForm:self.story withImage:self.image]);
}

- (void)testMakeStoryNoImage {
  NSLog(@"testMakeStoryNoImage");
  XCTAssertNoThrow([self.networkController postNewStoryToForm:self.story withImage:nil]);
}

//- (void)testExpectation {
//  XCTestExpectation *expectation = [self expectationWithDescription:@"expctedExpected"];
//
//
//  [self waitForExpectationsWithTimeout:5 handler: ^(NSError *error) {
//    [self stopMeasuring];
//  }];
//}

- (void)testGetImage {
  NSLog(@"TESTING USER IMAGE");

  [self.networkController getUIImageForStory:self.story withCompletionHandler:^(UIImage *imageForStory) {
    UIImage *imageFrom = imageForStory;
    NSLog(@"Length is %@", imageFrom.imageAsset.description);
    XCTAssertTrue(imageForStory);
  }];
}



- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
