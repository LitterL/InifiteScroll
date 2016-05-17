//
//  InifiteScrollView.swift
//  PJTZ_Swift
//
//  Created by PJTZ on 16/5/17.
//  Copyright © 2016年 PJTZ. All rights reserved.
//

import UIKit

//MARK: - 定义一个枚举
public enum InifiteScrollDirection {
    /** 左右滑动 */
    case InifiteScrollDirectionHorizontal
    /** 上下滑动 */
    case InifiteScrollDirectionVertical
}

//MARK: - 定义一份协议
protocol InifiteScrollViewDelegate{
    //代理方法
    func inifiteScrollView(inifiteScrollView:InifiteScrollView,didClickImageAtIndex:Int)
}



/** scrollView中UIImageView的数量 */
let ImageViewCount = 3
public class InifiteScrollView: UIView {
    
    //MARK: - 属性
    /** 代理 */
    var delegate: InifiteScrollViewDelegate?
    /** 每张图片之间的时间间隔 */
    public var interval: NSTimeInterval = 2{
        didSet{
            self.startTimer()
        }
    }
    /** 滑动方向 */
    public var scrolldirection: InifiteScrollDirection = .InifiteScrollDirectionHorizontal
    /** 图片数据(里面可以存放UIImage对象、NSString对象【本地图片名】、NSURL对象【远程图片的URL】) */
    public var images = []{
        didSet
        {
            pageControl.numberOfPages = images.count
        }
    }
    /** 用于定时操作 */
    var time : NSTimer = NSTimer()
    /** 定义ScrollView */
    let scrollView : UIScrollView = {
        var view =  UIScrollView()
        view.pagingEnabled = true
        view.bounces = false
        view.showsHorizontalScrollIndicator = false
        view.showsVerticalScrollIndicator = false
        return view
    }()
    /** 页脚 */
    let pageControl : UIPageControl =  UIPageControl()
    
    //MARK: - 生命周期
    override init(frame: CGRect) {
        super.init(frame: frame)
        //初始化子视图
        initChildView()
    }
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        //布局子视图
        layoutSubview()
        // 更新内容
        updateContentAndOffset()
    }
}


//MARK: - 添加以及布局子视图
extension InifiteScrollView{
    /**
     初始化子视图
     */
    private func initChildView(){
        //默认2秒一次
        interval = 2
        //设置代理
        scrollView.delegate = self
        //不允许交互
        pageControl.userInteractionEnabled = false
        //添加到视图上面
        self.addSubview(scrollView)
        self.addSubview(pageControl)
        
        //创建imageView  并且添加手势
        for _ in 0...ImageViewCount{
            let imageView = UIImageView()
            imageView.userInteractionEnabled = true
            imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: Selector("imageClick:")))
            scrollView.addSubview(imageView)
        }
    }
    
    /**
     布局子视图
     */
    private func layoutSubview(){
        //拿到frame后面有用
        let selfW = self.frame.size.width
        let selfH = self.frame.size.height
        
        
        //设置他们的frame
        scrollView.frame = self.bounds
        if scrolldirection == .InifiteScrollDirectionHorizontal{
            scrollView.contentSize = CGSizeMake(CGFloat(ImageViewCount) * selfW, 0)
        }else{
            scrollView.contentSize = CGSizeMake(0, CGFloat(ImageViewCount) * selfH)
        }
        for index in 0...ImageViewCount{
            let imageview = scrollView.subviews[index]
            if scrolldirection == .InifiteScrollDirectionHorizontal{
                imageview.frame = CGRectMake(CGFloat(index) * selfW, 0, selfW, selfH)
            }else{
                imageview.frame = CGRectMake(0, CGFloat(index) * selfH, selfW, selfH)
            }
        }
        let pageControlW : CGFloat = 100
        let pageControlH : CGFloat = 25
        self.pageControl.frame = CGRectMake(selfW - pageControlW, selfH - pageControlH, pageControlW, pageControlH)
    }
    
    /**
     图片的点击事件
     
     */
    @objc private func imageClick(tap:UITapGestureRecognizer){
        self.delegate?.inifiteScrollView(self, didClickImageAtIndex: (tap.view?.tag)!)
    }
    
    /**
     *  更新图片内容和scrollView的偏移量
     */
    private func updateContentAndOffset(){
        
        let currentpage = self.pageControl.currentPage
        for i in 0..<ImageViewCount{    // index是用来获取imageView的
            let imageview = self.scrollView.subviews[i] as! UIImageView
            //根据当前页码求出imageIndex
            var imageindex = 0
            if i == 0{  // 左边
                imageindex = currentpage - 1
                if imageindex == -1{ // 显示最后面一张
                    imageindex = images.count - 1
                }
            }
            else if i == 1{ // 中间
                imageindex = currentpage
            }else if i == 2{// 右边
                imageindex = currentpage + 1
                if imageindex == self.images.count{// 显示最前面一张
                    imageindex = 0
                }
            }
            imageview.tag = imageindex
            
            
            //用来判断出来的值  为url  还是本地图片  还是image对象
            let obj = images[imageindex]
            if obj.isKindOfClass(UIImage){  // UIImage对象
                imageview.image = obj as? UIImage
            }else if obj.isKindOfClass(NSString){// 本地图片名
                imageview.image = UIImage(named: obj as! String)
            }else if obj.isKindOfClass(NSURL){// 远程图片URL
                imageview.sd_setImageWithURL(obj as! NSURL)
            }
        }
        
        if scrolldirection == .InifiteScrollDirectionHorizontal{
            self.scrollView.contentOffset = CGPointMake(scrollView.frame.size.width, 0)
        }else{
            self.scrollView.contentOffset = CGPointMake(0,scrollView.frame.size.height)
        }
    }
}

//MARK: - 定时操作
extension InifiteScrollView{
    //开始定时器
    private func startTimer()
    {
        time = NSTimer.scheduledTimerWithTimeInterval(self.interval, target: self, selector: Selector("nextPage"), userInfo: nil, repeats: true)
        NSRunLoop.mainRunLoop().addTimer(time, forMode: NSRunLoopCommonModes)
    }
    
    //停止定时器
    private func stopTimer()
    {
        time.invalidate()
        time = NSTimer()
    }
    
    /**
     下一页
     */
    @objc private func nextPage(){
        UIView.animateWithDuration(0.25, animations: { [weak self] in
            if self?.scrolldirection == .InifiteScrollDirectionHorizontal{
                self!.scrollView.contentOffset = CGPointMake(2 * self!.scrollView.frame.size.width, 0)
            }else
            {
                self!.scrollView.contentOffset = CGPointMake(0, 2 * self!.scrollView.frame.size.height)
            }
            }) { [weak self] (_) -> Void in
                self!.updateContentAndOffset()
        }
    }
    
}

//MARK: - UIScrollViewDelegate协议
extension InifiteScrollView:UIScrollViewDelegate{
    /**
     拖拽的时候执行   目的为：得到中间视图的tag
     */
    public func scrollViewDidScroll(scrollView: UIScrollView) {
        // 找出显示在最中间的imageView
        var middleImageView : UIImageView = UIImageView()
        // x值和偏移量x的最小差值
        var minDelta = MAXFLOAT
        
        for i in 0..<ImageViewCount {
            let imageView = scrollView.subviews[i]
            // x值和偏移量x差值最小的imageView，就是显示在最中间的imageView
            var currentDelta:CGFloat = 0
            if (self.scrolldirection == .InifiteScrollDirectionHorizontal) {
                currentDelta = fabs(imageView.frame.origin.x - self.scrollView.contentOffset.x)
            } else {
                currentDelta = fabs(imageView.frame.origin.y - self.scrollView.contentOffset.y)
            }
            if currentDelta < CGFloat(minDelta) {
                minDelta = Float(currentDelta)
                middleImageView = (imageView as? UIImageView)!
            }
        }
        self.pageControl.currentPage = middleImageView.tag
        
    }
    
    /**
     停止减速时候执行
     */
    public func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        updateContentAndOffset()
    }
    
    
    /**
     *  用户即将开始拖拽的时候调用
     */
    public func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        self.stopTimer()
    }
    
    /**
     *  用户手松开的时候调用
     */
    public func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        self.startTimer()
    }
}