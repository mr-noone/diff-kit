//
//  Section.swift
//  diff-kit
//
//  Created by Aleksey Zgurskiy on 27.01.2020.
//  Copyright © 2020 mr.noone. All rights reserved.
//

import Foundation

public protocol Section {
  associatedtype Header
  associatedtype Footer
  associatedtype Item
  
  var header: Header? { get set }
  var footer: Footer? { get set }
  var items: [Item] { get set }
}
