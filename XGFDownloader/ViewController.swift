//
//  ViewController.swift
//  XGFDownloader
//
//  Created by 夏桂峰 on 16/6/6.
//  Copyright © 2016年 夏桂峰. All rights reserved.
//

import UIKit
import Foundation

let kWidth=UIScreen.mainScreen().bounds.size.width
let kHeight=UIScreen.mainScreen().bounds.size.height
//Libaray/Caches
let kCachePath=NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.CachesDirectory, NSSearchPathDomainMask.UserDomainMask, true).last

class ViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {

    var dataArray:NSMutableArray?
    var tbView:UITableView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor=UIColor.whiteColor()
        self.navigationController?.navigationBar.barStyle=UIBarStyle.BlackOpaque
        self.title="XGFDownloadManager Demo"
        self.automaticallyAdjustsScrollViewInsets=false
        self.prepareData()
        self.createTableView()
    }
    //MARK:构造数据
    func prepareData() {
        //print(kCachePath)
        self.dataArray=NSMutableArray()
        let model=TaskModel()
        model.name="GDTSDK.zip"
        model.destinationPath=String(format: "%@/%@",kCachePath!,model.name!)
        model.urlString="http://imgcache.qq.com/qzone/biz/gdt/dev/sdk/ios/release/GDT_iOS_SDK.zip"
        self.dataArray?.addObject(model)
        
        let another=TaskModel()
        another.name="CONTENT.jar"
        another.destinationPath=String(format: "%@/%@",kCachePath!,another.name!)
        another.urlString="http://android-mirror.bugly.qq.com:8080/eclipse_mirror/juno/content.jar"
        self.dataArray?.addObject(another)
        
        let third=TaskModel()
        third.name="Dota2国服版"
        third.urlString="http://dota2.dl.wanmei.com/dota2/client/DOTA2Setup20160329.zip"
        third.destinationPath=String(format: "%@/%@",kCachePath!,third.name!)
        self.dataArray?.addObject(third)
    }
    //MARK:创建表视图
    func createTableView() {
        self.tbView=UITableView.init(frame: CGRectMake(0, 64, kWidth, kHeight-64), style: UITableViewStyle.Plain)
        self.tbView?.delegate=self
        self.tbView?.dataSource=self
        self.view.addSubview(self.tbView!)
        self.tbView?.tableFooterView=UIView()
    }
    //MARK:UITableView
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return (self.dataArray?.count)!
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath)  -> UITableViewCell{
        
        let cid="cid"
        var cell=tableView.dequeueReusableCellWithIdentifier(cid) as? TaskCell
        if cell==nil {
            
            cell=TaskCell.init(style: UITableViewCellStyle.Default, reuseIdentifier: cid)
        }
        let taskCell=cell! as TaskCell
        let model=self.dataArray?.objectAtIndex(indexPath.row) as! TaskModel
        taskCell.cellWithModel(model)
        cell?.downloadBlock = { (sender) -> Void  in
            
            self.downloadWithSender(sender, model: model,cell: cell!)
        }
        cell?.selectionStyle=UITableViewCellSelectionStyle.None
        return cell!
    }
    func downloadWithSender(sender:UIButton? ,model:TaskModel?,cell:TaskCell){
        let currentTitle=sender?.currentTitle
        if (currentTitle=="开始") || (currentTitle=="恢复"){
            
            sender?.setTitle("暂停", forState:UIControlState.Normal)
            
            XGFDownloaderManager.sharedManager.download(model!.urlString, toPath: model!.destinationPath, process: { (progress, sizeString, speedString) in
                cell.progressView?.progress=progress;
                cell.progressLabel?.text=String(format: "%.1f%%",progress*100)
                cell.sizeLabel?.text=sizeString
                cell.speedLabel?.text=speedString
                if(speedString==nil){
                    cell.speedLabel?.hidden=true
                }
                else{
                    cell.speedLabel?.hidden=false
                }
        
            }, completion: {
                
                sender?.setTitle("完成", forState: UIControlState.Normal)
                sender?.enabled=false
                cell.speedLabel?.hidden=true
                let alert=UIAlertView.init(title:String(format: "%@下载完成",(model?.name)!), message: nil, delegate: nil, cancelButtonTitle: "确定")
                alert.show()
                
            }, failure: { (error) in
                
                XGFDownloaderManager.sharedManager.cancelDownloadTaskWithUrlString((model?.urlString)!)
                sender?.setTitle("恢复", forState: UIControlState.Normal)
                cell.speedLabel?.hidden=true
                let alert=UIAlertView.init(title:"ERROR", message: nil, delegate: nil, cancelButtonTitle: "确定")
                alert.show()
            })
        }
        else if (currentTitle=="暂停"){
            sender?.setTitle("恢复", forState: UIControlState.Normal)
            XGFDownloaderManager.sharedManager.cancelDownloadTaskWithUrlString((model?.urlString)!)
            cell.speedLabel?.hidden=true
        }
    }
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 60
    }
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
        let task=self.dataArray?.objectAtIndex(indexPath.row) as! TaskModel
        XGFDownloaderManager.sharedManager.removeTaskForUrl(task.urlString, filePath: task.destinationPath)
        self.dataArray?.removeObjectAtIndex(indexPath.row)
        self.tbView?.reloadData()
    }
    func tableView(tableView: UITableView, titleForDeleteConfirmationButtonForRowAtIndexPath indexPath: NSIndexPath) -> String? {
        return "删除"
    }
}

