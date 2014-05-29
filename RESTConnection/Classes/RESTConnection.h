//
//  RESTConnection.h
//
//  Created by Russell on 10/11/13.
//  Copyright (c) 2013 Russell Research Corporation. All rights reserved.
//
//  The RESTConnection class provides GCD block based methods for the following
//  types of HTTP or HTTPS RESTful methods:
//
//  GET
//  PUT
//  POST
//  DELETE
//
//  If the response contains ether XML or JSON, then the block response will
//  return an NSDictionary based on the reponse content, otherwise the block
//  response will return an NSDictionary containing the raw NSData response.
//
// USAGE
//
//  [RESTConnection getRequestForURL:@"http://myrestfulserver.com/api/get" block:^(NSMutableDictionary *dictionary) {
//
//      // do something with the dictionary
//
//  }];
//
//------------------------------------------------------------------------------

#import <UIKit/UIKit.h>

@interface RESTConnection : NSObject

+ (void)getHTTPRequestForURL:(NSString *)url block:( void (^)( NSMutableDictionary *dictionary ))block;
+ (void)getHTTPSRequestForURL:(NSString *)url username:(NSString *)username password:(NSString *)password block:( void (^)( NSMutableDictionary *dictionary ))block;

+ (void)deleteHTTPRequestForURL:(NSString *)url block:( void (^)( NSMutableDictionary *dictionary ))block;
+ (void)deleteHTTPSRequestForURL:(NSString *)url username:(NSString *)username password:(NSString *)password block:( void (^)( NSMutableDictionary *dictionary ))block;

+ (void)putHTTPRequestForURL:(NSString *)url body:(NSData *)body contentType:(NSString *)contentType block:( void (^)( NSMutableDictionary *dictionary ))block;
+ (void)putHTTPSRequestForURL:(NSString *)url username:(NSString *)username password:(NSString *)password body:(NSData *)body contentType:(NSString *)contentType block:( void (^)( NSMutableDictionary *dictionary ))block;

+ (void)postHTTPRequestForURL:(NSString *)url body:(NSData *)body contentType:(NSString *)contentType block:( void (^)( NSMutableDictionary *dictionary ))block;
+ (void)postHTTPSRequestForURL:(NSString *)url username:(NSString *)username password:(NSString *)password body:(NSData *)body contentType:(NSString *)contentType block:( void (^)( NSMutableDictionary *dictionary ))block;

@end
