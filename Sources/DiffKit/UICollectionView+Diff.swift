//
//  UICollectionView+Diff.swift
//  diff-kit
//
//  Created by Aleksey Zgurskiy on 24.10.2020.
//  Copyright © 2020 mr.noone. All rights reserved.
//

import UIKit

public extension UICollectionView {
  func apply<Item>(diff: SectionDiff<Int, Item>) {
    var insSections = [Int]()
    var delSections = [Int]()
    
    var delItems = [IndexPath]()
    var insItems = [IndexPath]()
    
    diff.removed.forEach { section in
      if section.element.count == numberOfItems(inSection: section.index) {
        delSections.append(section.index)
      } else {
        section.element.forEach { item in
          delItems.append(IndexPath(item: item.index, section: section.index))
        }
      }
    }
    
    diff.inserted.forEach { section in
      if delSections.contains(section.index) || numberOfSections <= section.index {
        insSections.append(section.index)
      } else {
        section.element.forEach { item in
          insItems.append(IndexPath(item: item.index, section: section.index))
        }
      }
    }
    
    performBatchUpdates {
      deleteItems(at: delItems)
      deleteSections(IndexSet(delSections))
      insertItems(at: insItems)
      deleteSections(IndexSet(insSections))
    } completion: { _ in }
  }
}
