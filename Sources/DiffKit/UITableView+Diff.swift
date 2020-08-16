//
//  UITableView+Diff.swift
//  diff-kit
//
//  Created by Aleksey Zgurskiy on 29.01.2020.
//  Copyright © 2020 mr.noone. All rights reserved.
//

import UIKit

public extension UITableView {
  func apply<Item>(diff: SectionDiff<Int, Item>, with animation: UITableView.RowAnimation) {
    var insSections = [Int]()
    var delSections = [Int]()
    
    var delItems = [IndexPath]()
    var insItems = [IndexPath]()
    
    diff.removed.forEach { section in
      if section.element.count == numberOfRows(inSection: section.index) {
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
    
    beginUpdates()
    deleteRows(at: delItems, with: animation)
    deleteSections(IndexSet(delSections), with: animation)
    insertRows(at: insItems, with: animation)
    insertSections(IndexSet(insSections), with: animation)
    endUpdates()
  }
}
