//
//  NetTool.m
//  YYIM
//
//  Created by Jobs on 2018/7/13.
//  Copyright © 2018年 Jobs. All rights reserved.
//

#import "NetTool.h"


#include <arpa/inet.h>
#include <netdb.h>

#include <net/if.h>

#include <ifaddrs.h>
#import <dlfcn.h>

#import <AFNetworking.h>


#import <SystemConfiguration/SystemConfiguration.h>


static NetTool *shared = nil;
@interface NetTool()
@property (nonatomic,strong)NSTimer * detectionTimer;


@end
@implementation NetTool
+ (instancetype)share{
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [[NetTool alloc] init];
    });
    
    return shared;
}


//获取host的名称
+ (NSString *) hostname
{
    char baseHostName[256]; // Thanks, Gunnar Larisch
    int success = gethostname(baseHostName, 255);
    if (success != 0) return nil;
    baseHostName[255] = '/0';
    
#if TARGET_IPHONE_SIMULATOR
    return [NSString stringWithFormat:@"%s", baseHostName];
#else
    return [NSString stringWithFormat:@"%s.local", baseHostName];
#endif
}
//从host获取地址
+ (NSString *) getIPAddressForHost: (NSString *) theHost
{
    struct hostent *host = gethostbyname([theHost UTF8String]);
    if (!host) {herror("resolv"); return NULL; }
    struct in_addr **list = (struct in_addr **)host->h_addr_list;
    NSString *addressString = [NSString stringWithCString:inet_ntoa(*list[0]) encoding:NSUTF8StringEncoding];
    return addressString;
}
//这是本地host的IP地址
+ (NSString *) localIPAddress
{
    struct hostent *host = gethostbyname([[NetTool hostname] UTF8String]);
    if (!host) {herror("resolv"); return nil;}
    struct in_addr **list = (struct in_addr **)host->h_addr_list;
    return [NSString stringWithCString:inet_ntoa(*list[0]) encoding:NSUTF8StringEncoding];
}



+(NSInteger)getNetPort{
    return get_free_port();
}
int get_free_port()
{
    int port = 0;
    int fd = -1;
    //    socklen_t = 0;
    port = -1;
    
#ifndef AF_IPV6
    struct sockaddr_in sin;
    memset(&sin, 0, sizeof(sin));
    sin.sin_family = AF_INET;
    sin.sin_port = htons(0);
    sin.sin_addr.s_addr = htonl(INADDR_ANY);
    
    fd = socket(AF_INET, SOCK_STREAM, IPPROTO_TCP);
    
    if(fd < 0){
        printf("socket() error:%s\n", strerror(errno));
        return -1;
    }
    if(bind(fd, (struct sockaddr *)&sin, sizeof(sin)) != 0)
    {
        printf("bind() error:%s\n", strerror(errno));
        close(fd);
        return -1;
    }
    
    int len = sizeof(sin);
    if(getsockname(fd, (struct sockaddr *)&sin, &len) != 0)
    {
        printf("getsockname() error:%s\n", strerror(errno));
        close(fd);
        return -1;
    }
    
    port = sin.sin_port;
    if(fd != -1)
        close(fd);
    
#else
    struct sockaddr_in6 sin6;
    memset(&sin6, 0, sizeof(sin6));
    sin.sin_family = AF_INET6;
    sin.sin_port = htons(0);
    sin6.sin_addr.s_addr = htonl(IN6ADDR_ANY);
    
    fd = socket(AF_INET6, SOCK_STREAM, IPPROTO_TCP);
    
    if(fd < 0){
        printf("socket() error:%s\n", strerror(errno));
        return -1;
    }
    
    if(bind(fd, (struct sockaddr *)&sin6, sizeof(sin6)) != 0)
    {
        printf("bind() error:%s\n", strerror(errno));
        close(fd);
        return -1;
    }
    
    len = sizeof(sin6);
    if(getsockname(fd, (struct sockaddr *)&sin6, &len) != 0)
    {
        printf("getsockname() error:%s\n", strerror(errno));
        close(fd);
        return -1;
    }
    
    port = sin6.sin6_port;
    
    if(fd != -1)
        close(fd);
    
#endif
    return port;
}
-(void)startDetection{
    /**
     *  建立定时器，每隔50s像服务器发送心跳包
     *
     *  longConnectToSocket:心跳包调用方法，在longConnectToSocket方法中进行长连接，并向服务器发送的讯息
     *
     *  TimeInterval:心跳包执行间隔时间
     *
     */
    [self stopDetection];
    self.detectionTimer = [NSTimer scheduledTimerWithTimeInterval:20 target:self selector:@selector(detectionServer) userInfo:nil repeats:YES];// 在longConnectToSocket方法中进行长连接需要向服务器发送的讯息
    /**
     *  启动定时器
     */
    [self.detectionTimer fire];
    
}
-(void)stopDetection{
    [self.detectionTimer invalidate];
    self.detectionTimer = nil;
    
}
+(void)detectionNet{
    AFNetworkReachabilityManager * manager = [AFNetworkReachabilityManager sharedManager];
    [manager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        /*
         AFNetworkReachabilityStatusUnknown          = -1,
         AFNetworkReachabilityStatusNotReachable     = 0,
         AFNetworkReachabilityStatusReachableViaWWAN = 1,
         AFNetworkReachabilityStatusReachableViaWiFi = 2,
         */
        switch (status) {
            case AFNetworkReachabilityStatusUnknown:
                NSLog(@"网络状态未知");
                break;
            case AFNetworkReachabilityStatusNotReachable:
                NSLog(@"没有网络");
                [[NSNotificationCenter defaultCenter] postNotificationName:@"NotReachable" object:nil];
                
                break;
            case  AFNetworkReachabilityStatusReachableViaWWAN:
                NSLog(@"3G|4G蜂窝移动网络");
                break;
            case AFNetworkReachabilityStatusReachableViaWiFi:
                NSLog(@"WIFI网络");
                break;
            default:
                break;
        }
    }];
    [manager startMonitoring];
}
-(void)detectionServer{
    // 1.获取AFN的请求管理者
    
    AFHTTPSessionManager * manger = [AFHTTPSessionManager manager];
    //    AFHTTPRequestOperationManager *manger = [AFHTTPRequestOperationManager manager];
    //网络延时设置15秒
    manger.requestSerializer.timeoutInterval = 5;
    manger.responseSerializer = [AFJSONResponseSerializer serializer];
    NSString * urlPath = [NSString stringWithFormat:@"%@%@",UrlPath,@"/FindAllUser"];
    // 3.发送请求

    [manger GET:urlPath parameters:nil progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            [[NSNotificationCenter defaultCenter] postNotificationName:NotiForServerStatusChange object:@(YES) userInfo:nil];
//        self.onLine = YES;
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            [[NSNotificationCenter defaultCenter] postNotificationName:NotiForServerStatusChange object:@(NO) userInfo:nil];
    
//        self.onLine = NO;
    }];
    
 
}

@end
