//
//  AppDelegate.swift
//  ToDoApp
//
//  Created by 工藤海斗 on 2020/04/05.
//  Copyright © 2020 工藤海斗. All rights reserved.
//

import UIKit
import RealmSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        let config = Realm.Configuration(
            
            //新しいスキーマバージョンを設定。以前に使用したものよりも大きくなければならない。
            //スキーマのバージョンを設定したことがない場合、バージョンは0。
            schemaVersion : 3,
            
            //スキーマのバージョンが上記のものよりも低い/を開くときに自動的に呼び出されるブロックを設定する
            migrationBlock : { migration, oldSchemaVersion in
                if (oldSchemaVersion < 1) {
                    // Realmは新しいプロパティと削除されたプロパティを自動的に検出する。
                    //そして自動的にディスク上のスキーマを更新する。
                }
            }
        )
        
        //デフォルトのレルムにこの新しい設定オブジェクトを使用するようにレルムに伝えます
        Realm.Configuration.defaultConfiguration = config
        
        let realm = try! Realm()
        print(realm, "Realm")
        print(config,"Realm Version")
        
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

