//
//  LXPageCollectionViewLayout.swift
//  LXPageCollectionView
//
//  Created by 刘行 on 2017/5/4.
//  Copyright © 2017年 刘行. All rights reserved.
//

import UIKit

class LXPageCollectionViewLayout: UICollectionViewLayout {
    
    var edgeInsets : UIEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10) {
        didSet{
            self.invalidateLayout()
        }
    }
    
    var columnCount : Int = 8 {
        didSet{
            self.invalidateLayout()
        }
    }
    
    var rowCount : Int = 3 {
        didSet{
            self.invalidateLayout()
        }
    }
    
    var columnMargin : CGFloat = 0 {
        didSet{
            invalidateLayout()
        }
    }
    
    var rowMargin : CGFloat = 0 {
        didSet{
            invalidateLayout()
        }
    }
    
    fileprivate lazy var layoutAttributes : [UICollectionViewLayoutAttributes] = {
        let layoutAttributes = [UICollectionViewLayoutAttributes]()
        return layoutAttributes
    }()
    
    fileprivate var totalPage = 0
    
}

//MARK:- 准备布局
extension LXPageCollectionViewLayout {
    
    override func prepare() {
        super.prepare()
        layoutAttributes.removeAll()
        let sectionsCount = collectionView!.numberOfSections;
        let cellW : CGFloat = (collectionView!.bounds.width - edgeInsets.left - edgeInsets.right - CGFloat(columnCount - 1) * columnMargin) / CGFloat(columnCount)
        let cellH : CGFloat = (collectionView!.bounds.height - edgeInsets.top - edgeInsets.bottom - CGFloat(rowCount - 1) * rowMargin) / CGFloat(rowCount)
        totalPage = 0
        for i in 0..<sectionsCount {
            let itemsCount = collectionView!.numberOfItems(inSection: i)
            for j in 0..<itemsCount {
                let indexPath = IndexPath(row: j, section: i)
                let layoutAttribute = UICollectionViewLayoutAttributes(forCellWith: indexPath)
                let page = j / (columnCount * rowCount)
                let cellX : CGFloat = edgeInsets.left + CGFloat(totalPage + page) * collectionView!.bounds.width + CGFloat(j % columnCount) * (cellW + columnMargin)
                let cellY : CGFloat = edgeInsets.top + CGFloat((j - page * (columnCount * rowCount)) / columnCount) * (cellH + rowMargin)
                layoutAttribute.frame = CGRect(x: cellX, y: cellY, width: cellW, height: cellH)
                layoutAttributes.append(layoutAttribute)
            }
            totalPage += (itemsCount - 1) / (columnCount * rowCount) + 1
        }
    }
}

//MARK:- 返回CollectionView的ContentSize
extension LXPageCollectionViewLayout {
    
    override var collectionViewContentSize: CGSize{
        return CGSize(width: CGFloat(totalPage) * collectionView!.bounds.width, height: 0)
    }
    
}

//MARK:- 返回cell布局属性
extension LXPageCollectionViewLayout {
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return layoutAttributes
    }
    
}
