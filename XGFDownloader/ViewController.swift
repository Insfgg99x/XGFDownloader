//
//  ViewController.swift
//  XGFDownloader
//
//  Created by 夏桂峰 on 16/6/6.
//  Copyright © 2016年 夏桂峰. All rights reserved.
//

import UIKit
import Foundation

let kWidth=UIScreen.main.bounds.size.width
let kHeight=UIScreen.main.bounds.size.height
//Libaray/Caches
let kCachePath=NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).last

class ViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {

    var dataArray:NSMutableArray?
    var tbView:UITableView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor=UIColor.white
        self.navigationController?.navigationBar.barStyle = .black
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
        self.dataArray?.add(model)
        
        let another=TaskModel()
        another.name="CONTENT.jar"
        another.destinationPath=String(format: "%@/%@",kCachePath!,another.name!)
        another.urlString="http://android-mirror.bugly.qq.com:8080/eclipse_mirror/juno/content.jar"
        self.dataArray?.add(another)
        
        let third=TaskModel()
        third.name="Dota2国服版"
        third.urlString="http://dota2.dl.wanmei.com/dota2/client/DOTA2Setup20160329.zip"
        third.destinationPath=String(format: "%@/%@",kCachePath!,third.name!)
        self.dataArray?.add(third)
    }
    //MARK:创建表视图
    func createTableView() {
        self.tbView=UITableView.init(frame: CGRect(x: 0, y: 64, width: kWidth, height: kHeight-64), style: .plain)
        self.tbView?.delegate=self
        self.tbView?.dataSource=self
        self.view.addSubview(self.tbView!)
        self.tbView?.tableFooterView=UIView()
    }
    //MARK:UITableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return (self.dataArray?.count)!
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath)  -> UITableViewCell{
        
        let cid="cid"
        var cell=tableView.dequeueReusableCell(withIdentifier: cid) as? TaskCell
        if cell==nil {
            
            cell=TaskCell.init(style: UITableViewCellStyle.default, reuseIdentifier: cid)
        }
        let taskCell=cell! as TaskCell
        let model=self.dataArray?.object(at: indexPath.row) as! TaskModel
        taskCell.cellWithModel(model: model)
        cell?.downloadBlock = { (sender) -> Void  in
            
            self.downloadWithSender(sender: sender, model: model,cell: cell!)
        }
        cell?.selectionStyle=UITableViewCellSelectionStyle.none
        return cell!
    }
    func downloadWithSender(sender:UIButton? ,model:TaskModel?,cell:TaskCell){
        let currentTitle=sender?.currentTitle
        if (currentTitle=="开始") || (currentTitle=="恢复"){
            
            sender?.setTitle("暂停", for:UIControlState.normal)
            
            XGFDownloaderManager.shared.download(urlString: model!.urlString, toPath: model!.destinationPath, process: { (progress, sizeString, speedString) in
                cell.progressView?.progress=progress;
                cell.progressLabel?.text=String(format: "%.1f%%",progress*100)
                cell.sizeLabel?.text=sizeString
                cell.speedLabel?.text=speedString
                if(speedString==nil){
                    cell.speedLabel?.isHidden=true
                }
                else{
                    cell.speedLabel?.isHidden=false
                }
        
            }, completion: {
                
                sender?.setTitle("完成", for: UIControlState.normal)
                sender?.isEnabled=false
                cell.speedLabel?.isHidden=true
                let alert=UIAlertView.init(title:String(format: "%@下载完成",(model?.name)!), message: nil, delegate: nil, cancelButtonTitle: "确定")
                alert.show()
                
            }, failure: { (error) in
                
                XGFDownloaderManager.shared.cancelDownloadTaskWithUrlString(urlString: (model?.urlString)!)
                sender?.setTitle("恢复", for: UIControlState.normal)
                cell.speedLabel?.isHidden=true
                let alert=UIAlertView.init(title:"ERROR", message: nil, delegate: nil, cancelButtonTitle: "确定")
                alert.show()
            })
        }
        else if (currentTitle=="暂停"){
            sender?.setTitle("恢复", for: UIControlState.normal)
            XGFDownloaderManager.shared.cancelDownloadTaskWithUrlString(urlString: (model?.urlString)!)
            cell.speedLabel?.isHidden=true
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        let task=self.dataArray?.object(at: indexPath.row) as! TaskModel
        XGFDownloaderManager.shared.removeTaskForUrl(urlString: task.urlString, filePath: task.destinationPath)
        self.dataArray?.removeObject(at: indexPath.row)
        self.tbView?.reloadData()
    }
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "删除"
    }
}

