//
//  ViewController.swift
//  InifiteScrollDemo
//
//  Created by PJTZ on 16/5/17.
//  Copyright © 2016年 PJTZ. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        addChildScorll()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    private func  addChildScorll(){
        //1、创建无线轮播器   设置frame
        let scroll =  InifiteScrollView(frame: CGRectMake(0,0,view.frame.size.width,200))
        //2、添加图片数据
        scroll.images = [
            NSURL(string: "https://picjumbo.imgix.net/HNCK2415.jpg?q=40&w=1650&sharp=30")!,
            NSURL(string: "https://i0.wp.com/picjumbo.com/wp-content/uploads/HNCK5165.jpg?zoom=2&resize=259%2C148&ssl=1")!,
            NSURL(string: "https://i1.wp.com/picjumbo.com/wp-content/uploads/HNCK5058.jpg?zoom=2&resize=259%2C148&ssl=1")!,
            UIImage(named: "background_1")!,
            "background_2"
            
        ]
        
        //3、设置页脚的颜色
        scroll.pageControl.currentPageIndicatorTintColor = UIColor.redColor()
        scroll.pageControl.pageIndicatorTintColor =  UIColor.grayColor()
        //设置间断时间   默认为2秒
        //        scroll.interval = 3
        //设置滚动方向  默认为左右
        //        scroll.scrolldirection = .InifiteScrollDirectionVertical
        scroll.delegate = self
        //4、添加到视图上去
        view.addSubview(scroll)
    }
}

extension ViewController:InifiteScrollViewDelegate{
    func inifiteScrollView(inifiteScrollView: InifiteScrollView, didClickImageAtIndex: Int) {
        SVProgressHUD.showWithStatus("点击了第\(didClickImageAtIndex+1)张图片")
        
        
        
        let delayInSeconds = 1.0
        let popTime = dispatch_time(DISPATCH_TIME_NOW,
                                    Int64(delayInSeconds * Double(NSEC_PER_SEC))) // 1
        dispatch_after(popTime, dispatch_get_main_queue()) {
            SVProgressHUD.dismiss()
        }
    }
}

