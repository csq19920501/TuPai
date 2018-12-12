/*
 ============================================================================
 Name        : LocalizedStringTool.h
 Version     : 1.0.0
 Copyright   : 
 Description : 多语言工具类
 ============================================================================
 */

#import <Foundation/Foundation.h>

/***********************************************************************
 * 方法名称： L
 * 功能描述： 获取多语言key对应的值
 * 输入参数： key 名称
 * 输出参数：
 * 返回值：   多语言key对应的值
 ***********************************************************************/
NSString *L(NSString *key);

/***********************************************************************
 * 方法名称： LT
 * 功能描述： 获取多语言key对应的值
 * 输入参数： key 名称
 table string文件名称
 * 输出参数：
 * 返回值：   多语言key对应的值
 ***********************************************************************/
NSString *LT(NSString *key, NSString *table);