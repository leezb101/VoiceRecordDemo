//
//  VoiceHelper.h
//  VoiceRecord
//
//  Created by leezb101 on 2017/4/22.
//  Copyright © 2017年 leezb101. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VoiceHelper : NSObject <NSCopying>

+ (instancetype)sharedHelper;

- (void)recordBegin;
- (void)recordStop;
@end
