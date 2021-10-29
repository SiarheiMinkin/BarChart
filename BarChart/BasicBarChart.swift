//
//  BasicBarChart.swift
//  BarChart
//


import UIKit

class BasicBarChart: UIView {
    private let scrollView: UIScrollView = UIScrollView()
    
    private var leftView = PageView()
    private var midleView = PageView()
    private var rightView = PageView()
    
    private var currentPageIndex = 0
    private var previousPageIndex = 0
    
    private var pages: [[DataEntry]] = []
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    private func setupView() {
        //scrollView.layer.addSublayer(mainLayer)
        self.addSubview(scrollView)
        scrollView.isPagingEnabled = true
        scrollView.delegate = self
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        scrollView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        scrollView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        
        scrollView.addSubview(leftView)
        scrollView.addSubview(midleView)
        scrollView.addSubview(rightView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        scrollView.contentSize = CGSize(width: scrollView.frame.size.width * 3, height: scrollView.frame.size.height)
        if currentPageIndex == 0 {
            scrollView.contentOffset = CGPoint(x: scrollView.frame.size.width * 2, y: 0)
            previousPageIndex = 2
        }
        leftView.frame = CGRect(x: 0, y: 0, width: scrollView.frame.size.width, height: scrollView.frame.size.height)
        midleView.frame = CGRect(x: scrollView.frame.size.width, y: 0, width: scrollView.frame.size.width, height: scrollView.frame.size.height)
        rightView.frame = CGRect(x: scrollView.frame.size.width * 2, y: 0, width: scrollView.frame.size.width, height: scrollView.frame.size.height)
        
        
        leftView.updateDataEntries(dataEntries: leftView.presenter.dataEntries, animated: false)
        midleView.updateDataEntries(dataEntries: midleView.presenter.dataEntries, animated: false)
        rightView.updateDataEntries(dataEntries: rightView.presenter.dataEntries, animated: false)
    }
    
    func setPages(pages: [[DataEntry]]) {
        self.pages = pages
        if pages.count > 0 {
            rightView.updateDataEntries(dataEntries: pages[0], animated: true)
        }
        
        if pages.count > 1 {
            midleView.updateDataEntries(dataEntries: pages[1], animated: true)
        }
        
        if pages.count > 2 {
            leftView.updateDataEntries(dataEntries: pages[2], animated: true)
        }
    }
    
    func addPages(pages: [[DataEntry]]) {
        self.pages.append(contentsOf: pages)
    }
}


extension BasicBarChart: UIScrollViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let index = Int(scrollView.contentOffset.x / scrollView.bounds.size.width)
        currentPageIndex = currentPageIndex + previousPageIndex - index
        previousPageIndex = index
        if index == 0 && currentPageIndex < (pages.count - 1) {
            let firstView = rightView
            let secondView = leftView
            let thirdView = midleView
            scrollView.contentOffset = CGPoint(x: scrollView.frame.size.width, y: 0)
            firstView.frame = CGRect(x: 0, y: 0, width: scrollView.frame.size.width, height: scrollView.frame.size.height)
            secondView.frame = CGRect(x: scrollView.frame.size.width, y: 0, width: scrollView.frame.size.width, height: scrollView.frame.size.height)
            thirdView.frame = CGRect(x: scrollView.frame.size.width * 2, y: 0, width: scrollView.frame.size.width, height: scrollView.frame.size.height)
            leftView = firstView
            midleView = secondView
            rightView = thirdView
            
            leftView.updateDataEntries(dataEntries: pages[currentPageIndex - 1], animated: false)
            
            previousPageIndex = 1
        } else if index == 2 && currentPageIndex > 0 {
            let firstView = midleView
            let secondView = rightView
            let thirdView = leftView
            scrollView.contentOffset = CGPoint(x: scrollView.frame.size.width, y: 0)
            firstView.frame = CGRect(x: 0, y: 0, width: scrollView.frame.size.width, height: scrollView.frame.size.height)
            secondView.frame = CGRect(x: scrollView.frame.size.width, y: 0, width: scrollView.frame.size.width, height: scrollView.frame.size.height)
            thirdView.frame = CGRect(x: scrollView.frame.size.width * 2, y: 0, width: scrollView.frame.size.width, height: scrollView.frame.size.height)
            leftView = firstView
            midleView = secondView
            rightView = thirdView
            
            rightView.updateDataEntries(dataEntries: pages[currentPageIndex + 1], animated: false)
            
            previousPageIndex = 1
        }
    }
}
