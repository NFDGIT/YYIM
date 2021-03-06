//
//  MessageManager.m
//  YYIM
//
//  Created by Jobs on 2018/7/16.
//  Copyright © 2018年 Jobs. All rights reserved.
//

#import "MessageManager.h"
#import "DBTool.h"

static MessageManager *shared = nil;

@interface MessageManager()
@property (nonatomic,strong)NSMutableDictionary * messageDic;

@property (nonatomic,strong)NSMutableArray * messageTargets;
@end
@implementation MessageManager

+(instancetype)share{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [MessageManager new];
        [shared initData];
        [shared handleMewMsg];
    });
    
    return shared;
}
-(void)initData{
    _messageTargets = [NSMutableArray array];
    _messageDic = [NSMutableDictionary dictionary];
    
    
}


#pragma mark -- 会话

/**
 获取所有的会话
 
 @param success 获取成功
 */
-(void)getConversations:(void (^)(NSArray *))success{
    [[DBTool share]getConversations:^(NSArray *result) {
        if (success){
            success(result);
        }
    }];
}

/**
 添加会画
 
 @param model 会话的模型
 @param response 添加会话的结果
 */
-(void)addConversationModel:(ConversationModel *)model response:(void (^)(BOOL))response{
    
    
    
    
    [[DBTool share] addConversationModel:model response:^(BOOL success) {
        if (response) {
            response(success);
        }
    }];
    
}


/**
 删除某个会话
 
 @param conversationId 会话Id
 @param response 结果
 */
-(void)deleteConversationId:(NSString *)conversationId response:(void (^)(BOOL))response{
    [[DBTool share] deleteConversationId:conversationId response:^(BOOL success) {
        if (response) {
            response(success);
        }
    }];
}
/**
 获取某个会话
 
 @param conversationId 会话Id
 @param response 结果
 */
-(void)getConversationWithId:(NSString *)conversationId response:(void (^)(ConversationModel *model))response{
    [[DBTool share]getConversationWithId:conversationId response:^(ConversationModel *model) {
        if (response) {
            response(model);
        }
    }];
}

/**
 为会话设置 新消息个数

 @param newCount 新消息个数
 @param conversationId 会话ID
 @param response 结果
 */
-(void)setNewCount:(NSUInteger)newCount withId:(NSString *)conversationId response:(void(^)(BOOL success))response{
    [self getConversationWithId:conversationId response:^(ConversationModel *model) {
        model.newCount = newCount;
        
        [self updateConversationWith:model response:^(BOOL succes) {
            if (response) {
                response(succes);
            }
        }];
    }];
}
/**
 更新会话 不改变顺序
 
 @param conversationModel 新消息个数
 @param response 结果
 */
-(void)updateConversationWith:(ConversationModel *)conversationModel response:(void(^)(BOOL success))response{
    [[DBTool share] updateConversationWith:conversationModel response:^(BOOL success) {
        if (response) {
            response(success);
        }
    }];
}
/**
 获取新消息总个数
 
 @param response 结果
 */
-(void)getTotalNewCountResponse:(void(^)(NSUInteger totalCount))response{
    [[DBTool share]getConversations:^(NSArray *result) {
        NSUInteger totalCout = 0;
        
        for (ConversationModel * model in result) {
             totalCout = totalCout  + model.newCount;
        }
        if (response) {
            response(totalCout);
        }
    }];
}


//-(void)getMsgTargetsSuccess:(void (^)(NSArray *))success{
////    NSArray * msgTargets = [NSArray array];
////    if (_messageTargets) {
////        msgTargets = _messageTargets;
////    }
////    return msgTargets;
//    [[DBTool share] getChatPersons:^(NSArray *result) {
//        if (success){
//            success(result);
//        }
//    }];
//
//}

//-(void)addMsgTarget:(MessageTargetModel *)target{
//    [[DBTool share] addTargetModel:target response:^(BOOL success) {
//
//    }];
//
//}




#pragma mark -- 消息
-(NSArray *)getMessagesWithTargetId:(NSString *)targetId success:(void (^)(NSArray *))success{
//    NSArray * messages = [NSArray array];
//
//    if ([_messageDic.allKeys containsObject:targetId]) {
//        NSArray * msgs = _messageDic[targetId];
//        if ([msgs isKindOfClass:[NSArray class]]) {
//            messages = msgs;
//        }
//    }
//
    NSArray * messages =  [[DBTool share]getMessagesWithTarget:targetId success:^(NSArray *result) {
        if (success) {
            success(result);
        }
    }];
    return messages;
    
    
//    return messages;
}
/**
 获取最新的消息
 
 @param targetId 会话ID
 @param response 回调
 */
-(MsgModel *)getLastMessageWithTargetId:(NSString *)targetId response:(void (^)(MsgModel *))response{
    NSArray * messages = [self getMessagesWithTargetId:targetId success:^(NSArray * result) {
        
    }];
    
    if (messages.count>0) {
        return messages.lastObject;
    }
    return nil;
}
-(void)addMsg:(MsgModel *)msg toTarget:(ConversationModel *)target{
    
    [[DBTool share]addModel:msg withTarget:target.Id response:^(BOOL success) {
        
    }];

    
    [self getConversationWithId:target.Id response:^(ConversationModel *model) {// 获取本地的 会话
        ConversationModel * targetModel;
        
        if (model) { // 如果本地已经存在这个会话
            targetModel = model;
        }else{ // 不存在
            targetModel = target;
        }
        
        if (![msg.sendId isEqualToString:CurrentUserId]) {  // 如果 是接受的消息 则绘画 增加
            targetModel.newCount = targetModel.newCount + 1;
        }
        [self addConversationModel:targetModel response:^(BOOL success) {
        }];
        
        
    }];
    


    
//    [self getMessagesWithTargetId:targetId success:^(NSArray * result) {
//        
////        NSMutableArray * messages = [NSMutableArray arrayWithArray:result];
////        [messages addObject:msg];
////        [self->_messageDic setObject:messages forKey:targetId];
//        
//        [[DBTool share]addModel:msg withTarget:targetId response:^(BOOL success) {
//            
//        }];
//    }];

}
/**
 删除 某个会话的聊天记录
 
 @param conversationId 会话ID
 @param response response description
 */
-(void)deleteMessagesWithConversationId:(NSString *)conversationId response:(void(^)(BOOL success))response{
    [[DBTool share]deleteMessagesWithConversationId:conversationId response:^(BOOL success) {
        if (response) {
            response(success);
        }
    }];
}

#pragma mark -- 处理 socket 收到的数据
-(void)handleMewMsg{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleMewMessageWithNoti:) name:NotiForReceive object:nil];
}
-(void)handleMewMessageWithNoti:(NSNotification *)noti{
    
    
}


-(void)getAllPerson{
    [Request getUserListSuccess:^(NSUInteger code, NSString *msg, id data) {
        
        
        
        
    } failure:^(NSError *error) {
        
    }];
    
    
}
@end
