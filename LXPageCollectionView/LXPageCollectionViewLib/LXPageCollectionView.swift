//
//  LXPageContentView.swift
//  LXPageCollectionView
//
//  Created by 刘行 on 2017/5/4.
//  Copyright © 2017年 刘行. All rights reserved.
//

import UIKit

protocol LXPageCollectionViewDataSource : class {
    func numberOfSections(in pageCollectionView: LXPageCollectionView) -> Int
    func pageCollectionView(_ pageCollectionView: LXPageCollectionView, numberOfItemsInSection section: Int) -> Int
    func pageCollectionView(_ pageCollectionView: LXPageCollectionView, collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
}

@objc protocol LXPageCollectionViewDelegate  {
    @objc optional func pageCollectionView(_ pageCollectionView: LXPageCollectionView, didSelectItemAt indexPath: IndexPath)
    @objc optional func pageCollectionView(_ pageCollectionView: LXPageCollectionView, sectionChangedAt section: Int)
}


class LXPageCollectionView: UIView {
    
    weak var dataSource : LXPageCollectionViewDataSource?
    
    weak var delegate : LXPageCollectionViewDelegate?
    
    override var backgroundColor: UIColor?{
        didSet{
            collectionView.backgroundColor = backgroundColor
        }
    }
    
    fileprivate var layout : LXPageCollectionViewLayout
    
    fileprivate var style : LXPageCollectionViewStyle
    
    fileprivate lazy var collectionView : UICollectionView = {
        let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: self.layout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.scrollsToTop = false
        collectionView.bounces = false
        collectionView.isPagingEnabled = true
        collectionView.showsHorizontalScrollIndicator = false
        return collectionView
    }()
    
    fileprivate lazy var pageControl : UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.currentPageIndicatorTintColor = self.style.pageControlSelectedColor
        pageControl.pageIndicatorTintColor = self.style.pageControlNormalColor
        pageControl.isEnabled = false
//        pageControl.addTarget(self, action: #selector(pageControlClick(pageControl:)), for: UIControlEvents.valueChanged)
        return pageControl
    }()
    
    fileprivate var currentSection : Int = 0
    
    fileprivate lazy var sectionIndexs : [Int] = {
        let sectionIndexs = [Int]()
        return sectionIndexs
    }()

    init(frame: CGRect, layout: LXPageCollectionViewLayout, style: LXPageCollectionViewStyle) {
        self.layout = layout
        self.style = style
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.collectionView.frame = CGRect(x: 0, y: 0, width: bounds.width, height: style.isShowPageControl ? bounds.height - 20 : bounds.height)
        if style.isShowPageControl {
            self.pageControl.frame = CGRect(x: 0, y: bounds.height - 20, width: bounds.width, height: 20)
        }
    }

}

extension LXPageCollectionView {
    
    fileprivate func setupUI() {
        backgroundColor = UIColor.lightGray
        addSubview(collectionView)
        if style.isShowPageControl {
            addSubview(pageControl)
        }
    }
    
//    @objc fileprivate func pageControlClick(pageControl: UIPageControl){
//        var totalPage = 0
//        for i in 0..<currentSection {
//            let itemCounts = collectionView.numberOfItems(inSection: i)
//            totalPage += (itemCounts - 1) / (layout.columnCount * layout.rowCount) + 1
//        }
//        sectionIndexs[currentSection] = pageControl.currentPage
//        totalPage += pageControl.currentPage
//        collectionView.setContentOffset(CGPoint(x: CGFloat(totalPage) * bounds.width, y: 0), animated: false)
//    }
}

//MARK:- 外部调用方法
extension LXPageCollectionView {
    
    open func registerCellClass(_ cellClass: Swift.AnyClass?, identifier: String){
        collectionView.register(cellClass, forCellWithReuseIdentifier: identifier)
    }
    
    open func registerNib(_ nib: UINib?, identifier: String){
        collectionView.register(nib, forCellWithReuseIdentifier: identifier)
    }
    
    open func reloadData() {
        collectionView.reloadData()
    }
    
    open func scrollToSection(_ section: Int){
        if section < 0 || section >= sectionIndexs.count {
            return
        }
        currentSection = section
        var totalPage = 0
        for i in 0..<currentSection {
            let itemCounts = collectionView.numberOfItems(inSection: i)
            totalPage += (itemCounts - 1) / (layout.columnCount * layout.rowCount) + 1
        }
        totalPage += sectionIndexs[currentSection]
        collectionView.setContentOffset(CGPoint(x: CGFloat(totalPage) * bounds.width, y: 0), animated: false)
        if style.isShowPageControl {
            let itemsCount = collectionView.numberOfItems(inSection: currentSection)
            pageControl.numberOfPages = (itemsCount - 1) / (layout.columnCount * layout.rowCount) + 1
            pageControl.currentPage = sectionIndexs[currentSection]
        }
    }
}

//MARK:- 设置UICollectionViewDataSource
extension LXPageCollectionView : UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        let sectionsCount = dataSource?.numberOfSections(in: self) ?? 0
        sectionIndexs = Array(repeating: 0, count: sectionsCount)
        return sectionsCount
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let itemsCount = dataSource?.pageCollectionView(self, numberOfItemsInSection: section) ?? 0
        if section == currentSection && style.isShowPageControl {
            pageControl.numberOfPages = (itemsCount - 1) / (layout.columnCount * layout.rowCount) + 1
        }
        return itemsCount
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return dataSource!.pageCollectionView(self, collectionView: collectionView, cellForItemAt: indexPath)
    }
}

//MARK:- 设置UICollectionViewDelegate
extension LXPageCollectionView : UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.pageCollectionView?(self, didSelectItemAt: indexPath)
    }

    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if scrollView == collectionView && !decelerate {
            collectionViewEndScroll()
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView == collectionView {
            collectionViewEndScroll()
        }
    }
    
    private func collectionViewEndScroll() {
        let offsetX = collectionView.contentOffset.x
        guard let indexPath = collectionView.indexPathForItem(at: CGPoint(x: offsetX + layout.edgeInsets.left + 1, y: layout.edgeInsets.top + 1)) else {
            return
        }
        sectionIndexs[indexPath.section] = indexPath.item / (layout.columnCount * layout.rowCount)
        if currentSection != indexPath.section {
            currentSection = indexPath.section
            delegate?.pageCollectionView?(self, sectionChangedAt: currentSection)
        }
        if style.isShowPageControl {
            let itemsCount = collectionView.numberOfItems(inSection: indexPath.section)
            pageControl.numberOfPages = (itemsCount - 1) / (layout.columnCount * layout.rowCount) + 1
            pageControl.currentPage = indexPath.item / (layout.columnCount * layout.rowCount)
        }
    }
    
}
