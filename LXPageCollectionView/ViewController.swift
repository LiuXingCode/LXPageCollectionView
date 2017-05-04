//
//  ViewController.swift
//  LXPageCollectionView
//
//  Created by 刘行 on 2017/5/4.
//  Copyright © 2017年 刘行. All rights reserved.
//

import UIKit
import LXScrollContentView

private let kPageContentCellID = "kPageContentCellID"

class ViewController: UIViewController {
    
    fileprivate lazy var pageCollectionView : LXPageCollectionView = {
        let layout = LXPageCollectionViewLayout()
        layout.columnMargin = 15
        layout.rowMargin = 5
        let pageCollectionView = LXPageCollectionView(frame: CGRect.zero, layout: layout)
        pageCollectionView.dataSource = self
        pageCollectionView.delegate = self
        pageCollectionView.registerCellClass(UICollectionViewCell.self, identifier: kPageContentCellID)
        return pageCollectionView
    }()
    
    fileprivate lazy var segmentTitleView : LXSegmentTitleView = {
        let segmentTitleView = LXSegmentTitleView(frame: CGRect.zero)
        segmentTitleView.backgroundColor = UIColor.purple
        segmentTitleView.delegate = self
        segmentTitleView.segmentTitles = ["A组", "B组", "C组", "D组"]
        return segmentTitleView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        segmentTitleView.frame = CGRect(x: 0, y: 40, width: self.view.bounds.width, height: 50)
        pageCollectionView.frame = CGRect(x: 0, y: segmentTitleView.frame.maxY, width: self.view.bounds.width, height: 250)
    }

}

extension ViewController {
    
    fileprivate func setupUI() {
        view.addSubview(pageCollectionView)
        view.addSubview(segmentTitleView)
    }
    
}

extension ViewController : LXPageCollectionViewDataSource {
    
    func numberOfSections(in pageCollectionView: LXPageCollectionView) -> Int {
        return 4
    }
    
    func pageCollectionView(_ pageCollectionView: LXPageCollectionView, numberOfItemsInSection section: Int) -> Int {
        return Int(arc4random_uniform(80)) + 30
    }
    
    func pageCollectionView(_ pageCollectionView: LXPageCollectionView, collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: kPageContentCellID, for: indexPath)
        cell.backgroundColor = UIColor.randomColor()
        return cell
    }
}

extension ViewController : LXPageCollectionViewDelegate {
    
    func pageCollectionView(_ pageCollectionView: LXPageCollectionView, sectionChangedAt section: Int) {
        segmentTitleView.selectedIndex = section
    }
    
    func pageCollectionView(_ pageCollectionView: LXPageCollectionView, didSelectItemAt indexPath: IndexPath) {
        print("\(indexPath)")
    }
}

extension ViewController : LXSegmentTitleViewDelegate {
    
    func segmentTitleView(_ segmentView: LXSegmentTitleView!, selectedIndex: Int, lastSelectedIndex: Int) {
        pageCollectionView.scrollToSection(selectedIndex)
    }
}



