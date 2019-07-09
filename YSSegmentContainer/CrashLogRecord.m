//
//  CrashLogRecord.m
//  YSSegmentContainer
//
//  Created by Lola001 on 2019/7/9.
//  Copyright © 2019年 all. All rights reserved.
//

#import "CrashLogRecord.h"

@implementation CrashLogRecord

+ (void)startCatch {
    
    NSSetUncaughtExceptionHandler(&uncaughtExceptionHandler);
}

void uncaughtExceptionHandler(NSException *exception) {
    
    //异常的堆栈信息
    NSArray *stackArray = [exception callStackSymbols];
    //异常原因
    NSString *reason = [exception reason];
    //异常名称
    NSString *name = [exception name];
    NSString *exceptionInfo = [NSString stringWithFormat:@"Exception reason：%@\nException name：%@\nException stack：%@",name, reason, stackArray];
    
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    format.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    NSString *dateStr = [format stringFromDate:[NSDate date]];
    
    NSString *log = [NSString stringWithFormat:@"%@\n%@", dateStr, exceptionInfo];
    
    NSString *documentFilePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *filePath = [documentFilePath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.txt",dateStr]];
    [log writeToFile:filePath atomically:false encoding:(NSUTF8StringEncoding) error:nil];
}

@end
