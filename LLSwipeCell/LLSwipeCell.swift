//
//  SlideTableCell.swift
//
//  Created by Eugen Ovchynnykov on 2/22/16.
//  Copyright © 2016 VoidCore. All rights reserved.
//

import UIKit

extension UIView {
    internal func parentViewOfClass<T>(type: T.Type) -> T? {
        if let view = superview as? T {
            return view
        }
        
        return superview?.parentViewOfClass(type)
    }
}

internal class OverlayView: UIView {
    weak var targetView: UIView?
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesBegan(touches, withEvent: event)
        targetView?.touchesBegan(touches, withEvent: event)
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesMoved(touches, withEvent: event)
        targetView?.touchesCancelled(touches, withEvent: event) // its important to cancel touch to proper unhighlight cell
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesEnded(touches, withEvent: event)
        targetView?.touchesEnded(touches, withEvent: event)
    }
    
    override func touchesCancelled(touches: Set<UITouch>?, withEvent event: UIEvent?) {
        super.touchesCancelled(touches, withEvent: event)
        targetView?.touchesCancelled(touches, withEvent: event)
    }
}

internal class SlideTableCellScrollView: UIScrollView, UIGestureRecognizerDelegate {
    weak var tableView: UITableView?
    
    init() {
        super.init(frame: CGRectZero)
        scrollsToTop = false
        showsHorizontalScrollIndicator = false
        showsVerticalScrollIndicator = false
        delaysContentTouches = true
        directionalLockEnabled = true
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }
}

internal class SlideButtonsGroupView: UIView {
    enum Side {
        case Left
        case Right
    }
    
    private var buttonsConstraints: [NSLayoutConstraint] = []
    private var widthConstraint: NSLayoutConstraint!
    
    private var side: Side = .Right
    
    var buttons: [UIView] = [] {
        didSet {
            setupButton()
        }
    }
    
    init(side: Side) {
        self.side = side
        super.init(frame: CGRectZero)
        
        widthConstraint = NSLayoutConstraint(item: self, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: 0)
        addConstraint(widthConstraint)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var progress: CGFloat = 0.0 {
        didSet {
           updateButtonConstraints()
        }
    }
    
    func updateButtonConstraints() {
        for (index, constraint) in buttonsConstraints.enumerate() {
            let offset = buttonOffsetForIndex(index)
            constraint.constant = offset*CGFloat(progress)
        }
    }
    
    func buttonOffsetForIndex(index: Int) -> CGFloat {
        var allButtons = buttons[buttons.startIndex..<buttons.startIndex.advancedBy(index)]
        if side == .Left {
            allButtons = buttons[buttons.startIndex.advancedBy(index + 1)..<buttons.endIndex]
        }
        
        let offset = allButtons.reduce(0.0) { sum, control in
            return sum + control.bounds.size.width
        }
        
        return side == .Right ? offset : -offset
    }
    
    private func removeOldButtons() {
        for subview in subviews {
            subview.removeFromSuperview()
        }
        buttonsConstraints.removeAll()
    }
    
    func setupButton() {
        removeOldButtons()
        
        for button in buttons {
            button.translatesAutoresizingMaskIntoConstraints = false
            
            if side == .Right {
                addSubview(button)
            } else {
                insertSubview(button, atIndex: 0)
            }
            
            let buttonWidth = button.bounds.size.width
            
            let buttonWidthConstraint = NSLayoutConstraint(item: button, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: buttonWidth)
            button.addConstraint(buttonWidthConstraint)
            
            let views = ["button": button]
            let buttonVertConstraint = NSLayoutConstraint.constraintsWithVisualFormat("V:|-0-[button]-0-|", options: [], metrics: nil, views: views)
            addConstraints(buttonVertConstraint)
            
            let attr: NSLayoutAttribute = side == .Right ? .Leading : .Trailing
            
            let cons = NSLayoutConstraint(item: button, attribute: attr, relatedBy: .Equal, toItem: self, attribute: attr, multiplier: 1, constant: 0)
            addConstraint(cons)
            buttonsConstraints.append(cons)
        }
        
        widthConstraint.constant = buttons.reduce(0) { (sum, control)  in
            return sum + control.bounds.size.width
        }
    }
}


public class LLSwipeCell: UITableViewCell, UIScrollViewDelegate {
    private let cellScrollView = SlideTableCellScrollView()
    private weak var currentTableView: UITableView?
    @IBOutlet public weak var slideContentView: UIView!
    
    var leftXOffset: CGFloat {
        return leftButtonsContainerView.bounds.size.width
    }
    
    var rightXOffset: CGFloat {
        return rightButtonsContainerView.bounds.size.width
    }
    
    var startOffset: CGPoint {
        let leftOffset = leftButtonsContainerView.bounds.size.width
        return CGPoint(x: leftOffset, y: 0)
    }
    
    public var rightButtons: [UIView] = [] {
        didSet {
            appendButtons()
        }
    }
    public var leftButtons: [UIView] = [] {
        didSet {
            appendButtons()
        }
    }
    
    var rightTriggerOffset = 50
    var leftTriggerOffset = 50
    
    private let rightButtonsContainerView = SlideButtonsGroupView(side: .Right)
    private let leftButtonsContainerView = SlideButtonsGroupView(side: .Left)
    
    public var canOpenLeftButtons = true
    public var canOpenRightButtons = true
    
    public private(set) var showsLeftButtons = false
    public private(set) var showsRightButtons = false
    
    private func setupScrollView() {
        cellScrollView.delegate = self
        
        cellScrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(cellScrollView)
        
        let views = ["cellScrollView": cellScrollView]
        let vertCons = NSLayoutConstraint.constraintsWithVisualFormat("V:|-0-[cellScrollView]-0-|", options: [], metrics: nil, views: views)
        contentView.addConstraints(vertCons)
        let horizCons = NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[cellScrollView]-0-|", options: [], metrics: nil, views: views)
        contentView.addConstraints(horizCons)
    }
    
    private func setupSlideContentView() {
        slideContentView.removeFromSuperview()
        cellScrollView.addSubview(slideContentView)
        slideContentView.translatesAutoresizingMaskIntoConstraints = false
        
        let views = ["slideContentView": slideContentView]
        let vertCons = NSLayoutConstraint.constraintsWithVisualFormat("V:|-0-[slideContentView]-0-|", options: [], metrics: nil, views: views)
        cellScrollView.addConstraints(vertCons)
        
        let heightConstraint = NSLayoutConstraint(item: slideContentView, attribute: .Height, relatedBy: .Equal, toItem: cellScrollView, attribute: .Height, multiplier: 1, constant: 0)
        cellScrollView.addConstraint(heightConstraint)
        
        let widthConstraint = NSLayoutConstraint(item: slideContentView, attribute: .Width, relatedBy: .Equal, toItem: cellScrollView, attribute: .Width, multiplier: 1, constant: 0)
        cellScrollView.addConstraint(widthConstraint)
    }
    
    
    private func setupOverlayView() {
        let overlay = OverlayView()
        overlay.translatesAutoresizingMaskIntoConstraints = false
        overlay.backgroundColor = UIColor.clearColor()
        overlay.targetView = contentView
        slideContentView.insertSubview(overlay, atIndex: 0)
        
        let views = ["overlayView": overlay]
        let vertCons = NSLayoutConstraint.constraintsWithVisualFormat("V:|-0-[overlayView]-0-|", options: [], metrics: nil, views: views)
        slideContentView.addConstraints(vertCons)

        let hotizontalCons = NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[overlayView]-0-|", options: [], metrics: nil, views: views)
        slideContentView.addConstraints(hotizontalCons)
    }
    
    private func setupLeftGroupView() {
        cellScrollView.addSubview(leftButtonsContainerView)
        leftButtonsContainerView.translatesAutoresizingMaskIntoConstraints = false
        
        let views = [
            "leftButtonsContainerView": leftButtonsContainerView,
            "slideContentView": slideContentView
        ]
        
        let vertCons = NSLayoutConstraint.constraintsWithVisualFormat("V:|-0-[leftButtonsContainerView]-0-|", options: [], metrics: nil, views: views)
        cellScrollView.addConstraints(vertCons)
        
        let hotizontalCons = NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[leftButtonsContainerView]-0-[slideContentView]", options: [], metrics: nil, views: views)
        cellScrollView.addConstraints(hotizontalCons)
    }
    
    private func setupRightGroupView() {
        cellScrollView.addSubview(rightButtonsContainerView)
        rightButtonsContainerView.translatesAutoresizingMaskIntoConstraints = false
        
        let views = [
            "rightButtonsContainerView": rightButtonsContainerView,
            "slideContentView": slideContentView
        ]
        
        let vertCons = NSLayoutConstraint.constraintsWithVisualFormat("V:|-0-[rightButtonsContainerView]-0-|", options: [], metrics: nil, views: views)
        cellScrollView.addConstraints(vertCons)
        
        let hotizontalCons = NSLayoutConstraint.constraintsWithVisualFormat("H:[slideContentView]-0-[rightButtonsContainerView]-0-|", options: [], metrics: nil, views: views)
        cellScrollView.addConstraints(hotizontalCons)
    }
    
    private func setup() {
        setupScrollView()
        setupSlideContentView()
        setupOverlayView()
        setupLeftGroupView()
        setupRightGroupView()
    }
    
    public func expandLeftButtons(animated: Bool = true) {
        cellScrollView.setContentOffset(CGPointZero, animated: animated)
    }
    
    public func toggleLeftButtons(animated: Bool = true) {
        if showsLeftButtons {
            hideSwipeOptions(animated)
        } else {
            expandLeftButtons(animated)
        }
    }
    
    public func expandRightButtons(animated: Bool = true) {
        let rightOffset = rightButtonsContainerView.bounds.size.width
        let offset = CGPoint(x: startOffset.x + rightOffset, y: 0)
        cellScrollView.setContentOffset(offset, animated: animated)
    }
    
    public func toggleRightButtons(animated: Bool = true) {
        if showsRightButtons {
            hideSwipeOptions(animated)
        } else {
            expandRightButtons(animated)
        }
    }
    
    private func appendButtons() {
        rightButtonsContainerView.buttons = rightButtons
        leftButtonsContainerView.buttons = leftButtons
        
        cellScrollView.layoutIfNeeded()
        
        hideSwipeOptions(false)
    }
    
    
    override public func willMoveToSuperview(newSuperview: UIView?) {
        super.willMoveToSuperview(newSuperview)
        
        currentTableView?.panGestureRecognizer.removeTarget(self, action: "didPanTableView:")
        
        currentTableView = newSuperview?.parentViewOfClass(UITableView.self)
        currentTableView?.directionalLockEnabled = true
        cellScrollView.tableView = currentTableView
        
        currentTableView?.panGestureRecognizer.addTarget(self, action: "didPanTableView:")
    }
    
    private func didPanTableView(rec: UIPanGestureRecognizer) {
        hideSwipeOptions()
    }
    
    override public func awakeFromNib() {
        super.awakeFromNib()
        
        setup()
    }
    
    override public func prepareForReuse() {
        super.prepareForReuse()
        hideSwipeOptions(false)
    }
    
    public override func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    internal func hideSwipeOptions(animated: Bool = true) {
        let leftOffset = leftButtonsContainerView.bounds.size.width
        cellScrollView.setContentOffset(CGPoint(x: leftOffset, y: 0), animated: animated)
    }
    
    internal func targetOffset(currentOffset: CGPoint) -> CGPoint {
        if (currentOffset.x > leftXOffset + CGFloat(rightTriggerOffset)) {
            return CGPoint(x: leftXOffset + rightXOffset, y: 0)
        } else if (currentOffset.x < CGFloat(leftTriggerOffset)) {
            return CGPointZero
        }
        
        return CGPoint(x: leftXOffset, y: 0)
    }
    
    public func scrollViewWillEndDragging(scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        
        let offset = targetOffset(scrollView.contentOffset)
        targetContentOffset.memory = offset
        
        if abs(velocity.x) > 0.1 {
            dispatch_async(dispatch_get_main_queue()) {
                scrollView.setContentOffset(offset, animated: true)
            }
        }
    }
    
    private func updateGroupViewProgres() {
        let rightScrollOffset = cellScrollView.contentOffset.x - startOffset.x
        var rightProgress = rightScrollOffset > 0.0 ? rightScrollOffset / rightXOffset : 0.0
        
        rightProgress = min(1.0, max(0, rightProgress))
        rightButtonsContainerView.progress = rightProgress
        
        let leftScrollOffset = cellScrollView.contentOffset.x
        var leftProgress = leftScrollOffset > 0.0 ? leftScrollOffset / leftXOffset : 0.0
        
        leftProgress = min(1.0, max(0, 1-leftProgress))
        leftButtonsContainerView.progress = leftProgress
    }
    
    public func scrollViewDidScroll(scrollView: UIScrollView) {
        updateGroupViewProgres()
        
        if (cellScrollView.dragging && !canOpenRightButtons
            && scrollView.contentOffset.x > leftXOffset
            && !showsRightButtons) {
            hideSwipeOptions(false)
        }
        
        if (cellScrollView.dragging && !canOpenLeftButtons && scrollView.contentOffset.x < leftXOffset && !showsLeftButtons) {
            hideSwipeOptions(false)
        }
        
        showsRightButtons = scrollView.contentOffset.x > startOffset.x
        showsLeftButtons = scrollView.contentOffset.x < startOffset.x
    }
}
