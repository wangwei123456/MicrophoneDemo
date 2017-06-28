//
//  AppDelegate.h
//  MicrophoneDemo
//
//  Created by 王魏 on 2017/6/28.
//  Copyright © 2017年 wangwei. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong) NSPersistentContainer *persistentContainer;

- (void)saveContext;


@end

