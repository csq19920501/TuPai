//
//  NSData+HexAdditions.m
//  sdkDemo
//
//  Created by qqconnect on 13-6-27.
//  Copyright (c) 2013年 qqconnect. All rights reserved.
//

#import "NSData+HexAdditions.h"
#import <CommonCrypto/CommonDigest.h>
#import <UIKit/UIKit.h>
@implementation NSData (NSData_HexAdditions)

/***********************************************************************
 * 方法名称： stringWithHexBytes1
 * 功能描述： 转化为16进制
 * 输入参数：
 * 输出参数：
 * 返回值：   stringBuffer
 ***********************************************************************/
- (NSString *)stringWithHexBytes1
{
    NSMutableString *stringBuffer = [NSMutableString stringWithCapacity:([self length] * 2)];
    const unsigned char *dataBuffer = [self bytes];
    
    for (int i = 0; i < [self length]; ++i)
    {
        [stringBuffer appendFormat:@"%02x", (unsigned int)dataBuffer[i]];
    }
    return stringBuffer;
}

/***********************************************************************
 * 方法名称： stringWithHexBytes2
 * 功能描述： 转化为16进制
 * 输入参数：
 * 输出参数：
 * 返回值：   hexBytes
 ***********************************************************************/
- (NSString*)stringWithHexBytes2
{
    static const char hexdigits[] = "0123456789ABCDEF";
    const size_t numBytes = [self length];
    const unsigned char* bytes = [self bytes];
    char *strbuf = (char *)malloc(numBytes * 2 + 1);
    char *hex = strbuf;
    NSString *hexBytes = nil;
    
    for (int i = 0; i<numBytes; ++i)
    {
        const unsigned char c = *bytes++;
        *hex++ = hexdigits[(c >> 4) & 0xF];
        *hex++ = hexdigits[(c ) & 0xF];
    }
    *hex = 0;
    hexBytes = [NSString stringWithUTF8String:strbuf];
    free(strbuf);
    return hexBytes;
}

/***********************************************************************
 * 方法名称： digest
 * 功能描述： digest 加密
 * 输入参数：
 * 输出参数：
 * 返回值：   output
 ***********************************************************************/
-(NSString *)digest
{
    uint8_t digest[CC_SHA1_DIGEST_LENGTH];
    CC_SHA1([self bytes], [self length], digest);
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
    for (int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++)
    {
        [output appendFormat:@"%02x", digest[i]];
    }
    
    return output;
}

/***********************************************************************
 * 方法名称： md5
 * 功能描述： md5加密
 * 输入参数：
 * 输出参数：
 * 返回值：
 ***********************************************************************/
-(NSString *)md5
{
    unsigned char result[16];
    CC_MD5(self.bytes, self.length, result);
    return [NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            result[0], result[1], result[2], result[3], result[4], result[5], result[6], result[7], result[8],
            result[9], result[10], result[11], result[12], result[13], result[14], result[15]];
}

/***********************************************************************
 * 方法名称： dataFromHex16String
 * 功能描述： 16进制转化为nsdata
 * 输入参数： hex16Str
 * 输出参数：
 * 返回值：   bytes
 ***********************************************************************/
+ (NSData *)dataFromHex16String:(NSString *)hex16Str
{
    NSString *hexString=[[hex16Str uppercaseString] stringByReplacingOccurrencesOfString:@" " withString:@""];
    if ([hexString length]%2!=0) {
        return nil;
    }
    Byte tempbyt[1]={0};
    NSMutableData* bytes=[NSMutableData data];
    for(int i=0;i<[hexString length];i++)
    {
        unichar hex_char1 = [hexString characterAtIndex:i]; ////两位16进制数中的第一位(高位*16)
        int int_ch1 = 0;
        if(hex_char1 >= '0' && hex_char1 <='9')
            int_ch1 = (hex_char1-48)*16;   //// 0 的Ascll - 48
        else if(hex_char1 >= 'A' && hex_char1 <='F')
            int_ch1 = (hex_char1-55)*16; //// A 的Ascll - 65
        else
            return nil;
        i++;
        
        unichar hex_char2 = [hexString characterAtIndex:i]; ///两位16进制数中的第二位(低位)
        int int_ch2 = 0;
        if(hex_char2 >= '0' && hex_char2 <='9')
            int_ch2 = (hex_char2-48); //// 0 的Ascll - 48
        else if(hex_char2 >= 'A' && hex_char2 <='F')
            int_ch2 = hex_char2-55; //// A 的Ascll - 65
        else
            return nil;
        
        tempbyt[0] = int_ch1+int_ch2;  ///将转化后的数放入Byte数组里
        [bytes appendBytes:tempbyt length:1];
    }
    return bytes;
}
/***********************************************************************
 * 方法名称：zipNSDataWithImage
 * 功能描述： 压缩图片
 * 输入参数：
 * 输出参数：
 * 返回值：
 ***********************************************************************/
+(NSData *)zipNSDataWithImage:(UIImage *)sourceImage{
    //进行图像的画面质量压缩
    NSData *data=UIImageJPEGRepresentation(sourceImage, 1.0);
    if (data.length>500*1024) {
        if (data.length>1024*1024 * 10) {//10M以及以上
            data=UIImageJPEGRepresentation(sourceImage, 0.1);
        }else if (data.length>1024*1024 * 5) {//5M以及以上
            data=UIImageJPEGRepresentation(sourceImage, 0.2);
        }else if (data.length>1024*1024 * 2) {//2M以及以上
            data=UIImageJPEGRepresentation(sourceImage, 0.5);
        }else if (data.length>1024*1024 * 1) {//1M以及以上
            data=UIImageJPEGRepresentation(sourceImage, 0.8);
        }else if (data.length>1024*1024 * 0.5) {//0.5M以及以上
            data=UIImageJPEGRepresentation(sourceImage, 0.8);
        }
        
    }
    return data;
}


@end
