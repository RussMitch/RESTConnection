//
//  XMLReader.m
//
//  Created by Troy on 9/18/10.
//  Copyright 2010 Troy Brant. All rights reserved.
//
//------------------------------------------------------------------------------

#import "XMLReader.h"

NSString *const kXMLReaderTextNodeKey = @"StringValue";

@interface XMLReader (Internal) <NSXMLParserDelegate>

@end

@implementation XMLReader

//------------------------------------------------------------------------------
+ (NSMutableDictionary *)dictionaryForXMLData:(NSData *)data
//------------------------------------------------------------------------------
{
    XMLReader *reader = [[XMLReader alloc] init];
    NSMutableDictionary *rootDictionary = [reader objectWithData:data];
    return rootDictionary;
}

//------------------------------------------------------------------------------
+ (NSMutableDictionary *)dictionaryForXMLString:(NSString *)string
//------------------------------------------------------------------------------
{
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    return [XMLReader dictionaryForXMLData:data];
}

//------------------------------------------------------------------------------
- (NSMutableDictionary *)objectWithData:(NSData *)data
//------------------------------------------------------------------------------
{
    dictionaryStack = [[NSMutableArray alloc] init];
    textInProgress = [[NSMutableString alloc] init];
    
    [dictionaryStack addObject:[NSMutableDictionary dictionary]];
        
    NSXMLParser *parser = [[NSXMLParser alloc] initWithData:data];
    parser.delegate = self;
    BOOL success = [parser parse];
    
    if ((success)&&(!errorOccurred)) {
        NSMutableDictionary *resultDict = [dictionaryStack objectAtIndex:0];
        return resultDict;
    }
    
    return nil;
}

//------------------------------------------------------------------------------
- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
//------------------------------------------------------------------------------
{
    // Get the dictionary for the current level in the stack
    NSMutableDictionary *parentDict = [dictionaryStack lastObject];

    // Create the child dictionary for the new element, and initilaize it with the attributes
    NSMutableDictionary *childDict = [NSMutableDictionary dictionary];
    [childDict addEntriesFromDictionary:attributeDict];
    
    // If there's already an item for this key, it means we need to create an array
    id existingValue = [parentDict objectForKey:elementName];
    if (existingValue) {
        NSMutableArray *array = nil;
        if ([existingValue isKindOfClass:[NSMutableArray class]]) {
            // The array exists, so use it
            array = (NSMutableArray *) existingValue;
        } else {
            // Create an array if it doesn't exist
            array = [NSMutableArray array];
            [array addObject:existingValue];

            // Replace the child dictionary with an array of children dictionaries
            [parentDict setObject:array forKey:elementName];
        }
        
        // Add the new child dictionary to the array
        [array addObject:childDict];
    } else {
        // No existing value, so update the dictionary
        [parentDict setObject:childDict forKey:elementName];
    }
    
    // Update the stack
    [dictionaryStack addObject:childDict];
}

//------------------------------------------------------------------------------
- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
//------------------------------------------------------------------------------
{
    NSMutableDictionary *dictInProgress = [dictionaryStack lastObject];
    
    if ([textInProgress length] > 0) {
        [dictInProgress setObject:[[textInProgress stringByReplacingOccurrencesOfString:@"\n" withString:@""] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] forKey:kXMLReaderTextNodeKey];

        textInProgress = [[NSMutableString alloc] init];
    }
    
    // Pop the current dict
    [dictionaryStack removeLastObject];
}

//------------------------------------------------------------------------------
- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
//------------------------------------------------------------------------------
{
    if (string) {
        [textInProgress appendString:string];
    }
}

//------------------------------------------------------------------------------
- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError
//------------------------------------------------------------------------------
{
    errorOccurred= YES;
}

@end