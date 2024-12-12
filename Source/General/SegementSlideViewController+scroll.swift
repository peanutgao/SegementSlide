//
//  SegementSlideViewController+scroll.swift
//  SegementSlide
//
//  Created by Jiar on 2019/1/16.
//  Copyright © 2019 Jiar. All rights reserved.
//
import UIKit
extension SegementSlideViewController {
    
    internal func parentScrollViewDidScroll(_ parentScrollView: UIScrollView) {
        // Add scroll state protection
        guard !isScrolling else { return }
        isScrolling = true
        defer {
            DispatchQueue.main.async {
                self.isScrolling = false
                self.scrollViewDidScroll(parentScrollView, isParent: true)
            }
        }
        
        let parentContentOffsetY = parentScrollView.contentOffset.y
        
        // Simplify scroll logic
        switch innerBouncesType {
        case .parent:
            handleParentScroll(parentScrollView, offsetY: parentContentOffsetY)
        case .child:
            handleChildScroll(parentScrollView, offsetY: parentContentOffsetY)
        }
    }
    
    private func handleParentScroll(_ scrollView: UIScrollView, offsetY: CGFloat) {
        if !canParentViewScroll {
            scrollView.contentOffset.y = headerStickyHeight
            canChildViewScroll = true
        } else if offsetY >= headerStickyHeight {
            scrollView.contentOffset.y = headerStickyHeight
            canParentViewScroll = false
            canChildViewScroll = true
        } else {
            resetOtherCachedChildViewControllerContentOffsetY()
        }
    }
    
    private func handleChildScroll(_ scrollView: UIScrollView, offsetY: CGFloat) {
        if !canParentViewScroll {
            scrollView.contentOffset.y = headerStickyHeight
            canChildViewScroll = true
            return
        }
        
        if offsetY >= headerStickyHeight {
            scrollView.contentOffset.y = headerStickyHeight
            canParentViewScroll = false
            canChildViewScroll = true
        } else if offsetY <= 0 {
            scrollView.contentOffset.y = 0
            canChildViewScroll = true
            resetOtherCachedChildViewControllerContentOffsetY()
        }
    }
    
    internal func childScrollViewDidScroll(_ childScrollView: UIScrollView) {
        defer {
            scrollViewDidScroll(childScrollView, isParent: false)
        }
        let parentContentOffsetY = scrollView.contentOffset.y
        let childContentOffsetY = childScrollView.contentOffset.y
        switch innerBouncesType {
        case .parent:
            if !canChildViewScroll {
                childScrollView.contentOffset.y = 0
            } else if childContentOffsetY <= 0 {
                canChildViewScroll = false
                canParentViewScroll = true
            }
        case .child:
            if !canChildViewScroll {
                childScrollView.contentOffset.y = 0
            } else if childContentOffsetY <= 0 {
                if parentContentOffsetY <= 0 {
                    canChildViewScroll = true
                }
                canParentViewScroll = true
            } else {
                if parentContentOffsetY > 0 && parentContentOffsetY < headerStickyHeight {
                    canChildViewScroll = false
                }
            }
        }
    }
    
}
