//
//  XGFDownloader.swift
//  XGFDownloader
//
//  Created by 夏桂峰 on 16/6/6.
//  Copyright © 2016年 夏桂峰. All rights reserved.
//

import Foundation
import UIKit
/**
 *  下载完成的通知名
 */
let FGGDownloadTaskDidFinishDownloadingNotification="FGGDownloadTaskDidFinishDownloadingNotification";
 /// 内存空间不足的通知名
let FGGDownloaderInsufficientSystemFreeSpaceNotification="FGGDownloaderInsufficientSystemFreeSpaceNotification"

/// 下载过程中回调的代码块，会多次调用
typealias ProcessHandle=(_ progress:Float,_ sizeString:String?,_ speedString:String?)->Void
/// 下载完成的回调
typealias CompletionHandle=()->Void
/// 下载失败的回调
typealias FailureHandle=(_ error:Error)->Void


class XGFDownloader: NSObject,NSURLConnectionDataDelegate,NSURLConnectionDelegate{

    var process:ProcessHandle?
    var completion:CompletionHandle?
    var failure:FailureHandle?
    var growthSize:NSInteger?
    var lastSize:NSInteger?
    var destination_path:String?
    var urlString:String?
    var con:NSURLConnection?
    var writeHandle:FileHandle?
    
    
    private var timer:Timer?
    
    override init() {
        super.init()
        self.growthSize=0
        self.lastSize=0
        self.timer=Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(XGFDownloader.getGrowthSize), userInfo: nil, repeats: true)
    }
    
    //与计算网速相关的方法
    @objc func getGrowthSize() {
        do{
            let dict:Dictionary=try FileManager.default.attributesOfItem(atPath: self.destination_path!)
            
            let size=dict[.size] as! NSInteger
            self.growthSize=size-self.lastSize!
            self.lastSize=size
        }
        catch {
            
        }
    }
    
    //MARK:断点下载
    func download(urlString:String?,toPath:String?,process:ProcessHandle?,completion:CompletionHandle?,failure:FailureHandle?){
        
        if (toPath == nil) || (urlString==nil){
            
            return;
        }
        self.destination_path=toPath
        self.urlString=urlString
        self.process=process
        self.completion=completion
        self.failure=failure
        
        let url=URL(string:urlString!)
        let request=NSMutableURLRequest(url: url!)
        let exist=FileManager.default.fileExists(atPath: toPath!)
        if exist {
            
            do {
                let dict:Dictionary=try FileManager.default.attributesOfItem(atPath: toPath!)
                let length:NSInteger=dict[.size] as! NSInteger
                let rangeString=String.init(format: "bytes=%ld-", length)
                request.setValue(rangeString, forHTTPHeaderField: "Range")
            }
            catch {
                
            }
        }
        self.con=NSURLConnection(request: request as URLRequest, delegate: self)
    }
    //MARK:便捷方法
    class func downloader() -> XGFDownloader {
        
        let downloader=XGFDownloader();
        return downloader;
    }

    class func lastProgress(url:String?)->Float{
        
        if(url==nil){
            return 0.0;
        }
        return UserDefaults.standard.float(forKey: String(format: "%@progress",url!))
    }
    //MARK:Cancel
    func cancel(){
        self.con?.cancel()
        self.con=nil
        if (self.timer != nil){
            self.timer?.invalidate()
            self.timer=nil
        }
    }
    
    class func filesSize(url:String?)->String{
        
        if(url==nil){
            return "0.00K/0.00K"
        }
        let lenthKey=String(format: "%@totalLength",url!)
        let totalLength=UserDefaults.standard.integer(forKey: lenthKey)
        if(totalLength==0){
            return "0.00K/0.00K"
        }
        let progressKey=String(format: "%@progress",url!)
        let downloadProgress=UserDefaults.standard.float(forKey: progressKey)
        let currentLength=Int(Float(totalLength) * downloadProgress)
        let currentSize=self.convertSize(length: currentLength)
        let totalSize=self.convertSize(length: totalLength)
        return String(format: "%@/%@",currentSize,totalSize)
    }
    
    //MARK:转换
    class func convertSize(length:NSInteger?)->String{
        
        if length!<1024 {
            return String(format: "%ldB",length!)
        }
        else if length!>=1024&&length!<1024*1024 {
            return String(format: "%.0fK",Float(length!/1024))
        }
        else if length!>=1024*1024&&length!<1024*1024*1024 {
            
            return String(format: "%.1fM",Float(length!)/(1024.0*1024.0))
        }
        else{
            return String(format: "%.1fG",Float(length!/(1024*1024*1024)))
        }
    }

    //MARK:NSURLConnection
    func connection(_ connection: NSURLConnection, didFailWithError error: Error) {
        
        if (self.failure != nil){
            self.failure!(error)
        }
    }
    func connection(_ connection: NSURLConnection, didReceive response: URLResponse) {
        
        
        let lenthKey=String(format: "%@totalLength",self.urlString!)
        let totalLength=UserDefaults.standard.integer(forKey: lenthKey)
        if(totalLength==0){
            let expectLength=Int(response.expectedContentLength);
            UserDefaults.standard.set(expectLength, forKey: lenthKey)
            UserDefaults.standard.synchronize()
        }
        let exist=FileManager.default.fileExists(atPath: self.destination_path!)
        if !exist{
            FileManager.default.createFile(atPath: self.destination_path!, contents: nil, attributes: nil)
        }
        self.writeHandle=FileHandle.init(forWritingAtPath: self.destination_path!)
        //print(self.destination_path)

    }
    func connection(_ connection: NSURLConnection, didReceive data: Data) {
        
        self.writeHandle?.seekToEndOfFile()
        
        let systemFreeSpace=self.systemAvailableSpace()
        if(systemFreeSpace<1024*1024*20){
            let alert:UIAlertController=UIAlertController.init(title: "提示", message: "可用存储空间不足20M", preferredStyle: UIAlertControllerStyle.alert)
            let confirmAction=UIAlertAction.init(title: "确定", style: UIAlertActionStyle.default, handler: nil)
            alert.addAction(confirmAction)
            let root=UIApplication.shared.keyWindow?.rootViewController
            root?.present(alert, animated: true, completion: nil)
            //发送系统存储空间不足的通知
            let dict:Dictionary<String,String>=["urlString":self.urlString!]
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: FGGDownloaderInsufficientSystemFreeSpaceNotification), object: nil, userInfo: dict)
            return
        }
        self.writeHandle?.write(data)
        do{
            let dict:Dictionary=try FileManager.default.attributesOfItem(atPath: self.destination_path!)
            let length:NSInteger?=dict[.size] as? NSInteger
            let lenthKey=String(format: "%@totalLength",self.urlString!)
            let totalLength=UserDefaults.standard.integer(forKey: lenthKey)
            let downloadProgress=Float(length!)/(Float(totalLength))
            
            let progressKey=String(format: "%@progress",self.urlString!)
            UserDefaults.standard.set(downloadProgress, forKey: progressKey)
            UserDefaults.standard.synchronize()
            
            let sizeString=XGFDownloader.filesSize(url: self.urlString)
            //print(sizeString)
            var speedString="0.0Kb/s"
            let growthString=XGFDownloader.convertSize(length: self.growthSize!*Int(1.0/0.1))
            speedString=String(format: "%@/s",growthString)
            //print(speedString)
            if self.process != nil {
                self.process!(downloadProgress,sizeString,speedString)
            }
        }
        catch {
            
        }
    }
    func connectionDidFinishLoading(_ connection: NSURLConnection) {
        
        let dict:Dictionary<String,String>=["urlString":self.urlString!]
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: FGGDownloadTaskDidFinishDownloadingNotification), object: nil,userInfo:dict)
        self.cancel()
        if self.completion != nil {
            self.completion!()
        }
    }
    //MARK:获取系统可用存储空间
    func systemAvailableSpace()->NSInteger{
        
        var freeSpace:NSInteger=0
        let docPath=NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).last
        do {
            
            let dict:Dictionary<FileAttributeKey,Any>=try FileManager.default.attributesOfFileSystem(forPath: docPath!)
            freeSpace=dict[.systemFreeSize] as! NSInteger;
        }
        catch {
            
        }
        return freeSpace
    }
}

