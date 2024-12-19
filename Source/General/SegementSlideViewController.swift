//
//  SegementSlideViewController.swift
//  SegementSlide
//
//  Created by Jiar on 2018/12/7.
//  Copyright © 2018 Jiar. All rights reserved.
//

import UIKit

// MARK: - BouncesType

public enum BouncesType {
    case parent
    case child
}

// MARK: - SegementSlideViewController

open class SegementSlideViewController: UIViewController {
    public internal(set) var scrollView: SegementSlideScrollView!
    public internal(set) var headerView: SegementSlideHeaderView!
    public internal(set) var contentView: SegementSlideContentView!
    public internal(set) var switcherView: SegementSlideSwitcherDelegate!
    var innerHeaderView: UIView?

    var safeAreaTopConstraint: NSLayoutConstraint?
    var parentKeyValueObservation: NSKeyValueObservation?
    var childKeyValueObservations: [String: NSKeyValueObservation] = [:]
    var innerBouncesType: BouncesType = .parent
    var canParentViewScroll: Bool = true
    var canChildViewScroll: Bool = false
    var lastChildBouncesTranslationY: CGFloat = 0
    var cachedChildViewControllerIndex: Set<Int> = Set()

    private var extraHeight: CGFloat {
        switcherView.ssDataSource?.extraHeight ?? 0
    }

    public var headerStickyHeight: CGFloat {
        let headerHeight = headerView.frame.height.rounded(.up)
        if edgesForExtendedLayout.contains(.top) {
            return headerHeight - topLayoutLength - extraHeight
        } else {
            return headerHeight - extraHeight
        }
    }

    public var switcherHeight: CGFloat {
        switcherView.ssDataSource?.height ?? 44
    }

    public var contentViewHeight: CGFloat {
        view.bounds.height - topLayoutLength - switcherHeight - extraHeight
    }

    public var currentIndex: Int? {
        switcherView.ssSelectedIndex
    }

    public var currentSegementSlideContentViewController: SegementSlideContentScrollViewDelegate? {
        guard let currentIndex else {
            return nil
        }
        return contentView.dequeueReusableViewController(at: currentIndex)
    }

    /// you should call `reloadData()` after set this property.
    open var defaultSelectedIndex: Int? {
        didSet {
            switcherView.ssDefaultSelectedIndex = defaultSelectedIndex
            contentView.defaultSelectedIndex = defaultSelectedIndex
        }
    }

    open var bouncesType: BouncesType {
        .parent
    }

    open func segementSlideHeaderView() -> UIView? {
        if edgesForExtendedLayout.contains(.top) {
            #if DEBUG
                assertionFailure("must override this variable")
            #endif
            return nil
        } else {
            return nil
        }
    }

    open func segementSlideSwitcherView() -> SegementSlideSwitcherDelegate {
        #if DEBUG
            assertionFailure("must override this variable")
        #endif
        return SegementSlideSwitcherEmptyView()
    }

    open func segementSlideContentViewController(at _: Int) -> SegementSlideContentScrollViewDelegate? {
        #if DEBUG
            assertionFailure("must override this function")
        #endif
        return nil
    }

    open func scrollViewDidScroll(_: UIScrollView, isParent _: Bool) {}

    open func didSelectContentViewController(at _: Int) {}

    open func setupHeader() {
        innerHeaderView = segementSlideHeaderView()
    }

    open func setupSwitcher() {}

    open func setupContent() {
        cachedChildViewControllerIndex.removeAll()
    }

    override open func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        layoutSegementSlideScrollView()
    }

    override open func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }

    /// reload headerView, SwitcherView and ContentView
    ///
    /// you should set `defaultSelectedIndex` before call this method.
    /// otherwise, no item will be selected.
    /// however, if an item was previously selected, it will be reSelected.
    public func reloadData() {
        setupBounces()
        setupHeader()
        setupSwitcher()
        setupContent()
        contentView.reloadData()
        switcherView.reloadData()
        layoutSegementSlideScrollView()
    }

    /// reload headerView
    public func reloadHeader() {
        setupHeader()
        layoutSegementSlideScrollView()
    }

    /// reload SwitcherView
    public func reloadSwitcher() {
        setupSwitcher()
        switcherView.reloadData()
        layoutSegementSlideScrollView()
    }

    /// reload ContentView
    public func reloadContent() {
        setupContent()
        contentView.reloadData()
    }

    /// select one item by index
    public func selectItem(at index: Int, animated: Bool) {
        switcherView.selectItem(at: index, animated: animated)
    }

    /// reuse the `SegementSlideContentScrollViewDelegate`
    public func dequeueReusableViewController(at index: Int) -> SegementSlideContentScrollViewDelegate? {
        contentView.dequeueReusableViewController(at: index)
    }

    deinit {
        parentKeyValueObservation?.invalidate()
        cleanUpChildKeyValueObservations()
        NotificationCenter.default.removeObserver(
            self,
            name: SegementSlideContentView.willCleanUpAllReusableViewControllersNotification,
            object: nil
        )
        #if DEBUG
            debugPrint("\(type(of: self)) deinit")
        #endif
    }
}
