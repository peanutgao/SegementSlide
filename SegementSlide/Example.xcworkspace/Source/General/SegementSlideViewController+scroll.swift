import UIKit

protocol SegementSlideScrollDelegate: AnyObject {
  func segementSlideDidScroll(_ scrollView: UIScrollView, isParent: Bool)
  func segementSlideContentDidScroll(_ contentScrollView: UIScrollView)
}

extension SegementSlideViewController {

  internal func parentScrollViewDidScroll(_ parentScrollView: UIScrollView) {
    defer {
      scrollDelegate?.segementSlideDidScroll(parentScrollView, isParent: true)
    }
    let parentContentOffsetY = parentScrollView.contentOffset.y
    switch innerBouncesType {
    case .parent:
      if !canParentViewScroll {
        parentScrollView.setContentOffset(CGPoint(x: 0, y: headerStickyHeight), animated: false)
        canChildViewScroll = true
      } else if parentContentOffsetY >= headerStickyHeight {
        parentScrollView.setContentOffset(CGPoint(x: 0, y: headerStickyHeight), animated: false)
        canParentViewScroll = false
        canChildViewScroll = true
      } else {
        resetOtherCachedChildViewControllerContentOffsetY()
      }
    case .child:
      let childBouncesTranslationY = -parentScrollView.panGestureRecognizer.translation(
        in: parentScrollView
      ).y.rounded(.up)
      defer {
        lastChildBouncesTranslationY = childBouncesTranslationY
      }
      if !canParentViewScroll {
        parentScrollView.setContentOffset(CGPoint(x: 0, y: headerStickyHeight), animated: false)
        canChildViewScroll = true
      } else if parentContentOffsetY >= headerStickyHeight {
        parentScrollView.setContentOffset(CGPoint(x: 0, y: headerStickyHeight), animated: false)
        canParentViewScroll = false
        canChildViewScroll = true
      } else if parentContentOffsetY <= 0 {
        parentScrollView.setContentOffset(.zero, animated: false)
        canChildViewScroll = true
        resetOtherCachedChildViewControllerContentOffsetY()
      } else {
        guard let childScrollView = currentSegementSlideContentViewController?.scrollView else {
          resetOtherCachedChildViewControllerContentOffsetY()
          return
        }
        if childScrollView.contentOffset.y < 0 {
          if childBouncesTranslationY > lastChildBouncesTranslationY {
            scrollView.setContentOffset(.zero, animated: false)
            canChildViewScroll = true
          } else {
            canChildViewScroll = false
          }
        } else {
          canChildViewScroll = false
        }
        resetOtherCachedChildViewControllerContentOffsetY()
      }
    }
  }

  internal func childScrollViewDidScroll(_ childScrollView: UIScrollView) {
    defer {
      scrollDelegate?.segementSlideContentDidScroll(childScrollView)
    }
    let parentContentOffsetY = scrollView.contentOffset.y
    let childContentOffsetY = childScrollView.contentOffset.y
    switch innerBouncesType {
    case .parent:
      if !canChildViewScroll {
        childScrollView.setContentOffset(.zero, animated: false)
      } else if childContentOffsetY <= 0 {
        canChildViewScroll = false
        canParentViewScroll = true
      }
    case .child:
      if !canChildViewScroll {
        childScrollView.setContentOffset(.zero, animated: false)
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

// MARK: - UIScrollViewDelegate
extension SegementSlideViewController: UIScrollViewDelegate {
  public func scrollViewDidScroll(_ scrollView: UIScrollView) {
    if scrollView === self.scrollView {
      parentScrollViewDidScroll(scrollView)
    } else if let childScrollView = currentSegementSlideContentViewController?.scrollView,
      scrollView === childScrollView
    {
      childScrollViewDidScroll(scrollView)
    }
  }
}
