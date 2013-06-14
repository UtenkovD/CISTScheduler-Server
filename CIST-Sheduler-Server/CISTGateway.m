//
//  CISTGateway.m
//  CIST-Sheduler-Server
//
//  Created by Dmitry Utenkov on 6/9/13.
//  Copyright (c) 2013 Coderivium. All rights reserved.
//

#import "CISTGateway.h"
#import "URLConnection.h"
#import "CHCSVParser.h"

@interface CISTGateway () <NSURLConnectionDelegate, NSURLConnectionDataDelegate, CHCSVParserDelegate> {
    NSMutableArray *currentRow;
    NSMutableArray *rows;
}


@end

@implementation CISTGateway

- (id)init {
    if (self = [super init]) {
        rows = [NSMutableArray array];
    }
    return self;
}

//- (void)getCSV {
////    NSURL *url = [NSURL URLWithString:@"http://cist.kture.kharkov.ua/ias/app/tt/WEB_IAS_TT_GNR_RASP.GEN_GROUP_POTOK_RASP?ATypeDoc=3&Aid_group=2664907&Aid_potok=0&ADateStart=01.02.2013&ADateEnd=30.07.2013&AMultiWorkSheet=0"];
//    
//    NSString *urlString = @"http://www.google.com";
//    
//    NSURLRequest *request = [[NSURLRequest alloc]
// 							 initWithURL: [NSURL URLWithString:urlString]
// 							 cachePolicy: NSURLRequestReloadIgnoringLocalCacheData
// 							 timeoutInterval: 10
// 							 ];
////    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
////    URLConnection *connection = [[URLConnection alloc] initWithRequest:request delegate:self];
////    [connection setDidFailSelector:@selector(connectionDidFail:)];
////    [connection start];
//    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];
//    
//    if(!connection) {
// 		NSLog(@"connection failed :(");
// 	} else {
// 		NSLog(@"connection succeeded  :)");
// 		
// 	}
//
//}

-(void)getCSV {
    
    NSDictionary *groupsKeys = [self getCodesForGroups];
    NSArray *keys = [groupsKeys allKeys];
    NSError *error = nil;
    for (NSString *key in keys) {
        NSString *urlString = [NSString stringWithFormat:@"http://cist.kture.kharkov.ua/ias/app/tt/WEB_IAS_TT_GNR_RASP.GEN_GROUP_POTOK_RASP?ATypeDoc=3&Aid_group=%@&Aid_potok=0&ADateStart=01.02.2013&ADateEnd=30.07.2013&AMultiWorkSheet=0", [groupsKeys objectForKey:key]];

        NSString *csvString = [NSString stringWithContentsOfURL:[NSURL URLWithString:urlString] encoding:NSWindowsCP1251StringEncoding error:&error];
        
        NSData *utfData = [csvString dataUsingEncoding:NSUTF8StringEncoding];
        
        BOOL status = [utfData writeToFile:[NSString stringWithFormat:@"/Users/administrator/CSV/%@.csv", key]
                                  atomically:NO];
        if (status != YES) {
            NSLog(@"Error in writing: %@", key);
        }
        
        
    }
    
    NSArray *array = [NSArray arrayWithContentsOfCSVFile:@"/Users/administrator/CSV/ВПС-09-1.csv"];
    
    for (NSArray *subarray in array) {
//        for (NSString *strin in subarray) {
//            NSLog(strin);
//        }
        NSLog(@"%@", [subarray lastObject]);
        NSLog(@"***************");
    }
    
    
    
    

}

- (void) parser:(CHCSVParser *)parser didStartLine:(NSUInteger)lineNumber {
    currentRow = [[NSMutableArray alloc] init];
}
- (void) parser:(CHCSVParser *)parser didReadField:(NSString *)field {
    [currentRow addObject:field];
}
- (void) parser:(CHCSVParser *)parser didEndLine:(NSUInteger)lineNumber {
    NSLog(@"finished line! %@", currentRow);
    if (currentRow)
    [rows addObject:currentRow];
    [currentRow release], currentRow = nil;
}

- (void)connectionDidFail:(URLConnection *)connection {
    
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    
}



- (NSDictionary *)getCodesForGroups {
    NSError *error = nil;
    NSURL *url = [NSURL URLWithString:@"http://cist.kture.kharkov.ua/ias/app/tt/f?p=778:2:374160973585834::NO#"];
    
    NSString *mainPageString = [NSString stringWithContentsOfURL:url encoding:NSWindowsCP1251StringEncoding error:&error];
    
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"\"javascript:IAS_ADD_Group_in_List.*?\""
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:&error];
    NSMutableArray *matches = [NSMutableArray array];
    
    [regex enumerateMatchesInString:mainPageString
                            options:0
                              range:NSMakeRange(0, [mainPageString length])
                         usingBlock:^(NSTextCheckingResult *match, NSMatchingFlags flags, BOOL *stop)
    {
        [matches addObject:[mainPageString substringWithRange:[match range]]];
    }];
    
    NSRegularExpression *regex2 = [NSRegularExpression
                                  regularExpressionWithPattern:@"\\(.+?\\)"
                                  options:NSRegularExpressionCaseInsensitive
                                  error:&error];
    
    NSMutableArray *codes = [NSMutableArray array];
    
    for (NSString *match in matches) {
        [regex2 enumerateMatchesInString:match
                                 options:0
                                   range:NSMakeRange(0, [match length])
                              usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop)
        {
            [codes addObject:[match substringWithRange:[result range]]];
        }];
    }
    
    NSMutableDictionary *groupIndexes = [NSMutableDictionary dictionary];
    
    for (NSString *code in codes) {
        NSArray *values = [code componentsSeparatedByString:@","];
        NSString *key = [[values objectAtIndex:0] substringWithRange:NSMakeRange(2, [[values objectAtIndex:0] length]-3)];
        NSString *value = [[values objectAtIndex:1] substringWithRange:NSMakeRange(0, [[values objectAtIndex:1] length]-1)];
        [groupIndexes setObject:value forKey:key];
    }
    return [NSDictionary dictionaryWithDictionary:groupIndexes];
}

@end
