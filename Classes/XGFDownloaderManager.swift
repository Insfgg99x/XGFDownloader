//
//  XGFDownloaderManager.swift
//  XGFDownloader
//
//  Created by 夏桂峰 on 16/6/6.
//  Copyright © 2016年 夏桂峰. All rights reserved.
//

import Foundation
import UIKit
/**
 *  最大同时下载任务数，超过将自动存入排队对列中
 */
let kFGGDwonloadMaxTaskCount=3


class XGFDownloaderManager: NSObject {

    static var sharedManager:XGFDownloaderManager=XGFDownloaderManager()
    
    var taskDict:NSMutableDictionary?
    var queue:[String]?
    var backgroundTaskId:UIBackgroundTaskIdentifier?
    
    override init() {
        
        super.init()
        self.taskDict=NSMutableDictionary.init()
        self.queue=Array.init()
        self.backgroundTaskId=UIBackgroundTaskInvalid
        
        let notificationCenter=NotificationCenter.default
        notificationCenter .addObserver(self, selector: #selector(downloadTaskDidFinishDownloading(sender:)), name: NSNotification.Name(rawValue: FGGDownloadTaskDidFinishDownloadingNotification), object: nil)
        notificationCenter.addObserver(self, selector: #selector(downloadTaskWillResign(sender:)), name: NSNotification.Name.UIApplicationWillResignActive, object: nil)
        notificationCenter.addObserver(self, selector: #selector(downloadTaskDidBecomActive(sender:)), name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
        notificationCenter.addObserver(self, selector: #selector(downloadTaskWillBeTerminate(sender:)), name: NSNotification.Name.UIApplicationWillTerminate, object: nil)
        notificationCenter.addObserver(self, selector: #selector(systemInsufficientSpace(sender:)), name: NSNotification.Name(rawValue: FGGDownloaderInsufficientSystemFreeSpaceNotification), object: nil)
    }
    func systemInsufficientSpace(sender:NSNotification){
        
        let dict:Dictionary?=sender.userInfo
        let downloadUrlString:String?=dict?["urlString"] as! String?;
        self .cancelDownloadTaskWithUrlString(urlString: downloadUrlString!)
    }
    
    func downloadTaskWillResign(sender:NSNotification) {
        
        if (self.taskDict?.count)!>0{
            
            self.backgroundTaskId=UIApplication.shared.beginBackgroundTask(expirationHandler: {
                
            });
        }
    }
    
    func downloadTaskDidBecomActive(sender:NSNotification){
        if self.backgroundTaskId==UIBackgroundTaskInvalid{
            
            return
        }
        UIApplication.shared.endBackgroundTask(self.backgroundTaskId!)
        self.backgroundTaskId=UIBackgroundTaskInvalid
    }
    
    func downloadTaskWillBeTerminate(sender:NSNotification) {
        
        self.cancelAllTasks()
    }
    
    func downloadTaskDidFinishDownloading(sender:NSNotification) {
        
        let dict:Dictionary=sender.userInfo!
        let downloadUrlString:String=dict["urlString"] as! String
        self.sychronizedFunc(lock: self) {

            taskDict?.removeObject(forKey: downloadUrlString)
        }
        /*
        if self.taskDict?.count<kFGGDwonloadMaxTaskCount {
            
            if self.queue?.count>0 {
                
                let first:NSDictionary=(self.queue?.firstObject)! as! NSDictionary
                
                self.queue?.removeObjectAtIndex(0)
            }
        }*/
    }
    
    func cancelAllTasks() {
        
        self.taskDict?.enumerateKeysAndObjects({ (key, obj, stop) in
            
            let downloader:XGFDownloader=obj as! XGFDownloader
            downloader.cancel()
            self.taskDict?.removeObject(forKey: key)
        })
    }
    
    func download(urlString:String?,toPath:String?,process:ProcessHandle?,completion:CompletionHandle?,failure:FailureHandle?){
        /*
        if(self.taskDict?.count>kFGGDwonloadMaxTaskCount){
            
            let dict:NSMutableDictionary=NSMutableDictionary()
            dict.setValue(urlString, forKey: "urlString")
            dict.setValue(toPath, forKey: "destinationPath")
            dict.setValue(process, forKey: "process")
            dict.setValue(completion, forKey: "completion")
            dict.setValue(failure, forKey: "failure")
        }
         */
        let downloader=XGFDownloader.downloader()
        self.sychronizedFunc(lock: self) {
            
            self.taskDict?.setObject(downloader, forKey: urlString! as NSCopying)
        }
        downloader.download(urlString: urlString, toPath: toPath, process: process, completion: completion, failure: failure)
    }
    //MARK:仿写OC的@synchronized (self)
    func sychronizedFunc(lock:AnyObject?,function:()->()) {
        
        objc_sync_enter(lock)
        function()
        objc_sync_exit(lock)
    }
    //MARK:取消任务
    func cancelDownloadTaskWithUrlString(urlString:String) {
        
        let downloader:XGFDownloader?=self.taskDict?.object(forKey: urlString) as! XGFDownloader?
        downloader?.cancel()
        self.sychronizedFunc(lock: self) {
            self.taskDict?.removeObject(forKey: urlString)
        }
    }
    
    //MARK:彻底删除任务
    func removeTaskForUrl(urlString:String, filePath:String) {
        
        let downloader:XGFDownloader?=self.taskDict?.object(forKey: urlString) as! XGFDownloader?
        downloader?.cancel();
        self.sychronizedFunc(lock: self) {
            self.taskDict?.removeObject(forKey: urlString)
        }
        
        let usd=UserDefaults.standard
        let progressKey=String(format: "%@progress",urlString)
        let lenthKey=String(format: "%@totalLength",urlString)
        usd.removeObject(forKey: progressKey)
        usd.removeObject(forKey: lenthKey)
        usd.synchronize()
        
        let exist=FileManager.default.fileExists(atPath: filePath)
        if exist {
            do {
                try FileManager.default.removeItem(atPath: filePath)
            }
            catch{
                
            }
        }
    }
    
    func lastProgress(urlString:String) ->Float {
        return XGFDownloader.lastProgress(url: urlString)
    }
    
    func filesSize(urlString:String) -> String {
        return XGFDownloader.filesSize(url: urlString)
    }
}

