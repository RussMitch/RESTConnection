//
//  RESTConnection.m
//
//  Created by Russell on 10/11/13.
//  Copyright (c) 2013 Russell Research Corporation. All rights reserved.
//
//------------------------------------------------------------------------------

#import "XMLReader.h"
#import "Base64Encoder.h"
#import "SBJsonReader.h"
#import "RESTConnection.h"

@implementation RESTConnection

//------------------------------------------------------------------------------
+ (void)sendRequestForURL:(NSString *)url
                 username:(NSString *)username
                 password:(NSString *)password
               httpMethod:(NSString *)httpMethod
                     body:(NSData *)body
              contentType:(NSString *)contentType
                    block:( void (^)( NSMutableDictionary *dictionary ))block
//------------------------------------------------------------------------------
{
    if (!url) {
        
        dispatch_async( dispatch_get_main_queue(), ^{
            block( nil );
        });
        
        return;
    }
    
    // save input parameters just in case the calling thread goes outa scope
    
    NSString *theUrl= url;
    NSData *theBody= body;
    NSString *theUsername= username;
    NSString *thePassword= password;
    NSString *theHttpMethod= httpMethod;
    NSString *theContentType= contentType;
    
    dispatch_async( dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0 ), ^{
        
        NSMutableURLRequest *request= [[NSMutableURLRequest alloc] init];
        [request setURL:[NSURL URLWithString:theUrl]];
        [request setTimeoutInterval:30];

        if ((theUsername)&&(thePassword))
            [request setValue:[Base64Encoder encodeLogin:theUsername withPassword:thePassword] forHTTPHeaderField:@"Authorization"];
        
        if (theHttpMethod)
            [request setHTTPMethod:theHttpMethod];
        
        if (theBody) {
            [request setValue:[NSString stringWithFormat:@"%ld", (long)[theBody length]] forHTTPHeaderField:@"Content-Length"];
            [request setHTTPBody:theBody];
        }
        
        if (theContentType)
            [request setValue:theContentType forHTTPHeaderField:@"Content-Type"];
        
        NSData *data= [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
        
        NSMutableDictionary *dict= [RESTConnection getDictionary:data];
        
        dispatch_async( dispatch_get_main_queue(), ^{
            block( dict );
        });
    });
}

//------------------------------------------------------------------------------
+ (void)getHTTPRequestForURL:(NSString *)url block:( void (^)( NSMutableDictionary *dictionary ))block
//------------------------------------------------------------------------------
{
    [RESTConnection sendRequestForURL:url username:nil password:nil httpMethod:@"GET" body:nil contentType:nil block:block];
}

//------------------------------------------------------------------------------
+ (void)getHTTPSRequestForURL:(NSString *)url username:(NSString *)username password:(NSString *)password block:( void (^)( NSMutableDictionary *dictionary ))block
//------------------------------------------------------------------------------
{
    [RESTConnection sendRequestForURL:url username:username password:password httpMethod:@"GET" body:nil contentType:nil block:block];
}

//------------------------------------------------------------------------------
+ (void)putHTTPRequestForURL:(NSString *)url body:(NSData *)body contentType:(NSString *)contentType block:( void (^)( NSMutableDictionary *dictionary ))block
//------------------------------------------------------------------------------
{
    [RESTConnection sendRequestForURL:url username:nil password:nil httpMethod:@"PUT" body:body contentType:contentType block:block];
}

//------------------------------------------------------------------------------
+ (void)putHTTPSRequestForURL:(NSString *)url username:(NSString *)username password:(NSString *)password body:(NSData *)body contentType:(NSString *)contentType block:( void (^)( NSMutableDictionary *dictionary ))block
//------------------------------------------------------------------------------
{
    [RESTConnection sendRequestForURL:url username:username password:password httpMethod:@"PUT" body:body contentType:contentType block:block];
}

//------------------------------------------------------------------------------
+ (void)postHTTPRequestForURL:(NSString *)url body:(NSData *)body contentType:(NSString *)contentType block:( void (^)( NSMutableDictionary *dictionary ))block
//------------------------------------------------------------------------------
{
    [RESTConnection sendRequestForURL:url username:nil password:nil httpMethod:@"POST" body:body contentType:contentType block:block];
}

//------------------------------------------------------------------------------
+ (void)postHTTPSRequestForURL:(NSString *)url username:(NSString *)username password:(NSString *)password body:(NSData *)body contentType:(NSString *)contentType block:( void (^)( NSMutableDictionary *dictionary ))block
//------------------------------------------------------------------------------
{
    [RESTConnection sendRequestForURL:url username:username password:password httpMethod:@"POST" body:body contentType:contentType block:block];
}

//------------------------------------------------------------------------------
+ (void)deleteHTTPRequestForURL:(NSString *)url block:( void (^)( NSMutableDictionary *dictionary ))block
//------------------------------------------------------------------------------
{
    [RESTConnection sendRequestForURL:url username:nil password:nil httpMethod:@"DELETE" body:nil contentType:nil block:block];
}

//------------------------------------------------------------------------------
+ (void)deleteHTTPSRequestForURL:(NSString *)url username:(NSString *)username password:(NSString *)password block:( void (^)( NSMutableDictionary *dictionary ))block
//------------------------------------------------------------------------------
{
    [RESTConnection sendRequestForURL:url username:username password:password httpMethod:@"DELETE" body:nil contentType:nil block:block];
}

//------------------------------------------------------------------------------
+ (NSMutableDictionary *)getDictionary:(NSData *)data
//------------------------------------------------------------------------------
{
    if ((!data)||([data length]==0))
        return nil;
    
    NSString *dataString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    if (dataString) {
        
        // is the reponse JSON ?

        NSMutableDictionary *dict= [dataString SBJSONValue];
        
        if (dict) {
            
            return dict;  // yes, return dictionary based on JSON content
            
        } else {

            // is the response XML ?
            
            NSMutableDictionary *dict= [XMLReader dictionaryForXMLData:data];
            
            if (dict) {
                
                return dict;  // yes, return dictionary based on XML content
                
            }
        }
    }
    
    // unknown content, return the dictionary with data
    
    return [NSMutableDictionary dictionaryWithObject:data forKey:@"data"];
}

@end
