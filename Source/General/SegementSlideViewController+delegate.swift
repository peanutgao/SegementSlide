//
//  SegementSlideViewController+delegate.swift
//  SegementSlide
//
//  Created by Jiar on 2019/1/16.
//  Copyright © 2019 Jiar. All rights reserved.
//

import UIKit

// MARK: - SegementSlideViewController + UIScrollViewDelegate

extension SegementSlideViewController: UIScrollViewDelegate {
    public func scrollViewShouldScrollToTop(_: UIScrollView) -> Bool {
        resetScrollViewStatus()
        resetCurrentChildViewControllerContentOffsetY()
        return true
    }
}

// MARK: - SegementSlideViewController + SegementSlideContentDelegate

extension SegementSlideViewController: SegementSlideContentDelegate {
    public var segementSlideContentScrollViewCount: Int {
        switcherView.ssDataSource?.titles.count ?? 0
    }

    public func segementSlideContentScrollView(at index: Int) -> SegementSlideContentScrollViewDelegate? {
        segementSlideContentViewController(at: index)
    }

    public func segementSlideContentView(
        _ segementSlideContentView: SegementSlideContentView,
        didSelectAtIndex index: Int,
        animated: Bool
    ) {
        guard index >= 0, index < segementSlideContentScrollViewCount else {
            print("Invalid index selected: \(index)")
            return
        }

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

        var isObserving = false

        let keyValueObservation = childScrollView.observe(\.contentOffset, options: [
            .new,
            .old
        ]) { [weak self] scrollView, change in
            guard let self else {
                return
            }
            guard !isObserving else {
                return
            }
            guard change.newValue != change.oldValue else {
                return
            }

            isObserving = true
            defer {
                isObserving = false
            }

            if let contentOffsetY = scrollView.forceFixedContentOffsetY {
                scrollView.forceFixedContentOffsetY = nil
                scrollView.contentOffset.y = contentOffsetY
                return
            }
            guard index == currentIndex else {
                return
            }
            childScrollViewDidScroll(scrollView)
        }
        childKeyValueObservations[key] = keyValueObservation
    }

    public func cleanupKVOForScrollView(_ scrollView: UIScrollView) {
        let key = String(format: "%p", scrollView)
        childKeyValueObservations[key]?.invalidate()
        childKeyValueObservations.removeValue(forKey: key)
    }
}
