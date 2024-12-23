//
//  UIScrollView+Scroll.swift
//  SegementSlide
//
//  Created by Jiar on 2020/9/13.
//

import UIKit

private var forceFixedContentOffsetYKey: Void?
private var isHandlingContentOffsetChangeKey: Void?

extension UIScrollView {

  var forceFixedContentOffsetY: CGFloat? {
    get {
      return objc_getAssociatedObject(self, &forceFixedContentOffsetYKey) as? CGFloat
    }
    set {
      if let newValue = newValue, contentOffset.y != newValue {
        objc_setAssociatedObject(
          self, &forceFixedContentOffsetYKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        setContentOffset(CGPoint(x: contentOffset.x, y: newValue), animated: false)
      } else {
        objc_setAssociatedObject(
          self, &forceFixedContentOffsetYKey, nil, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
      }
    }
  }

  var isHandlingContentOffsetChange: Bool {
    get {
      return objc_getAssociatedObject(self, &isHandlingContentOffsetChangeKey) as? Bool ?? false
    }
    set {
      objc_setAssociatedObject(
        self, &isHandlingContentOffsetChangeKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
  }

  func forceStopScroll() {
    var offset = contentOffset
    offset.x -= 1
    offset.y -= 1
    setContentOffset(offset, animated: false)
    offset.x += 1
    offset.y += 1
    setContentOffset(offset, animated: false)
  }

}
