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
    var queue:NSMutableArray?
    var backgroundTaskId:UIBackgroundTaskIdentifier?
    
    override init() {
        
        super.init()
        self.taskDict=NSMutableDictionary()
        self.queue=NSMutableArray()
        self.backgroundTaskId=UIBackgroundTaskInvalid
        
        let notificationCenter=NSNotificationCenter.defaultCenter()
        notificationCenter.addObserver(self, selector: #selector(XGFDownloaderManager.downloadTaskDidFinishDownloading(_:)), name: FGGDownloadTaskDidFinishDownloadingNotification, object: nil)
        notificationCenter.addObserver(self, selector:#selector(XGFDownloaderManager.downloadTaskWillResign(_:)), name: UIApplicationWillResignActiveNotification, object: nil)
        notificationCenter.addObserver(self, selector:#selector(XGFDownloaderManager.downloadTaskDidBecomActive(_:)), name: UIApplicationDidBecomeActiveNotification, object: nil)
        notificationCenter.addObserver(self, selector:#selector(XGFDownloaderManager.downloadTaskWillBeTerminate(_:)), name: UIApplicationWillTerminateNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(XGFDownloaderManager.systemInsufficientSpace(_:)), name: FGGDownloaderInsufficientSystemFreeSpaceNotification, object: nil)
    }
    func systemInsufficientSpace(sender:NSNotification){
        
        let dict:NSDictionary=sender.userInfo!
        let downloadUrlString=dict .objectForKey("urlString") as! String
        self .cancelDownloadTaskWithUrlString(downloadUrlString)
    }
    
    func downloadTaskWillResign(sender:NSNotification) {
        
        if self.taskDict?.count>0{
            self.backgroundTaskId=UIApplication.sharedApplication().beginBackgroundTaskWithExpirationHandler({ 
                
            });
        }
    }
    
    func downloadTaskDidBecomActive(sender:NSNotification){
        if self.backgroundTaskId==UIBackgroundTaskInvalid{
            
            return
        }
        UIApplication.sharedApplication().endBackgroundTask(self.backgroundTaskId!)
        self.backgroundTaskId=UIBackgroundTaskInvalid
    }
    
    func downloadTaskWillBeTerminate(sender:NSNotification) {
        
        self.cancelAllTasks()
    }
    
    func downloadTaskDidFinishDownloading(sender:NSNotification) {
        
        let dict:NSDictionary=sender.userInfo!
        let downloadUrlString=dict .objectForKey("urlString")
        self.sychronizedFunc(self) { 
          self.taskDict?.removeObjectForKey(downloadUrlString!)
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
        
        self.taskDict?.enumerateKeysAndObjectsUsingBlock({ (key, obj, stop) in
            
            let downloader:XGFDownloader=obj as! XGFDownloader
            downloader.cancel()
            self.taskDict?.removeObjectForKey(key)
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
        self.sychronizedFunc(self) {
            self.taskDict?.setObject(downloader, forKey: urlString!)
        }
        downloader.download(urlString, toPath: toPath, process: process, completion: completion, failure: failure)
    }
    //MARK:仿写OC的@synchronized (self)
    func sychronizedFunc(lock:AnyObject?,function:()->()) {
        
        objc_sync_enter(lock)
        function()
        objc_sync_exit(lock)
    }
    //MARK:取消任务
    func cancelDownloadTaskWithUrlString(urlString:String) {
        
        let downloader=self.taskDict?.objectForKey(urlString)
        downloader?.cancel()
        self.sychronizedFunc(self) { 
            self.taskDict?.removeObjectForKey(urlString)
        }
    }
    
    //MARK:彻底删除任务
    func removeTaskForUrl(urlString:String, filePath:String) {
        let downloader=self.taskDict?.objectForKey(urlString)
        downloader?.cancel()
        self.sychronizedFunc(self) {
            self.taskDict?.removeObjectForKey(urlString)
        }
        
        let usd=NSUserDefaults.standardUserDefaults()
        let progressKey=String(format: "%@progress",urlString)
        let lenthKey=String(format: "%@totalLength",urlString)
        usd.removeObjectForKey(progressKey)
        usd.removeObjectForKey(lenthKey)
        usd.synchronize()
        
        let exist=NSFileManager.defaultManager().fileExistsAtPath(filePath)
        if exist {
            do {
                try NSFileManager.defaultManager().removeItemAtPath(filePath)
            }
            catch{
                
            }
        }
    }
    
    func lastProgress(urlString:String) ->Float {
        return XGFDownloader.lastProgress(urlString)
    }
    
    func filesSize(urlString:String) -> String {
        return XGFDownloader.filesSize(urlString)
    }
}

