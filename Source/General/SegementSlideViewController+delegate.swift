//
//  SegementSlideViewController+delegate.swift
//  SegementSlide
//
//  Created by Jiar on 2019/1/16.
//  Copyright © 2019 Jiar. All rights reserved.
//

import UIKit

extension SegementSlideViewController: UIScrollViewDelegate {
    
    public func scrollViewShouldScrollToTop(_ scrollView: UIScrollView) -> Bool {
        resetScrollViewStatus()
        resetCurrentChildViewControllerContentOffsetY()
        return true
    }
    
}

extension SegementSlideViewController: SegementSlideContentDelegate {
    
    public var segementSlideContentScrollViewCount: Int {
        return switcherView.ssDataSource?.titles.count ?? 0
    }
    
    public func segementSlideContentScrollView(at index: Int) -> SegementSlideContentScrollViewDelegate? {
        return segementSlideContentViewController(at: index)
    }
    
    public func segementSlideContentView(_ segementSlideContentView: SegementSlideContentView, didSelectAtIndex index: Int, animated: Bool) {
        cachedChildViewControllerIndex.insert(index)
        if switcherView.ssSelectedIndex != index {
            switcherView.selectItem(at: index, animated: animated)
        }
        guard let childViewController = segementSlideContentView.dequeueReusableViewController(at: index) else {
            return
        }
        defer {
            didSelectContentViewController(at: index)
        }
        guard let childScrollView = childViewController.scrollView else {
            return
        }
        let key = String(format: "%p", childScrollView)
        guard !childKeyValueObservations.keys.contains(key) else {
            return
        }

        let keyValueObservation = childScrollView.observe(\.contentOffset, options: [.new, .old]) { [weak self] (scrollView, change) in
            guard let self = self else {
                return
            }
            
            if !Thread.isMainThread {
                DispatchQueue.main.async {
                    self.handleChildScrollViewChange(scrollView, change: change, index: index)
                }
                return
            }
            
            self.handleChildScrollViewChange(scrollView, change: change, index: index)
        }
        
        childKeyValueObservations[key] = keyValueObservation
    }
    
    private func handleChildScrollViewChange(_ scrollView: UIScrollView, change: NSKeyValueObservedChange<CGPoint>, index: Int) {
        guard change.newValue != change.oldValue else {
            return
        }
        
        if let contentOffsetY = scrollView.forceFixedContentOffsetY {
            scrollView.forceFixedContentOffsetY = nil
            if scrollView.contentOffset.y != contentOffsetY {
                scrollView.contentOffset.y = contentOffsetY
            }
            return
        }
        
        guard index == currentIndex else {
            return
        }
        
        if scrollView.isDecelerating || (!scrollView.isDragging && !scrollView.isTracking) {
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            childScrollViewDidScroll(scrollView)
            CATransaction.commit()
        } else {
            childScrollViewDidScroll(scrollView)
        }
    }
    
}
