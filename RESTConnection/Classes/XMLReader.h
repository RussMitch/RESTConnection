//
//  XMLReader.h
//
//  Created by Troy on 9/18/10.
//  Copyright 2010 Troy Brant. All rights reserved.
//
//------------------------------------------------------------------------------

#import <Foundation/Foundation.h>


@interface XMLReader : NSObject {
    
    BOOL errorOccurred;
    NSMutableArray *dictionaryStack;
    NSMutableString *textInProgress;
    
}

+ (NSMutableDictionary *)dictionaryForXMLData:(NSData *)data;
+ (NSMutableDictionary *)dictionaryForXMLString:(NSString *)string;

@end
