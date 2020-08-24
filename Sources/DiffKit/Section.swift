//
//  Section.swift
//  diff-kit
//
//  Created by Aleksey Zgurskiy on 27.01.2020.
//  Copyright © 2020 mr.noone. All rights reserved.
//

import Foundation

public protocol AnySection {
  associatedtype Item
  
  var items: [Item] { get set }
}

public protocol Section: AnySection {
  associatedtype Header
  associatedtype Footer
  
  var header: Header? { get set }
  var footer: Footer? { get set }
}
