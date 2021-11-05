//
//  BasicBarChart.swift
//  BarChart
//


import UIKit

class BarChart: UIView {
    
    enum ChartType {
        case week
        case year
    }
    
    private let scrollView: UIScrollView = UIScrollView()
    
    /// space at the bottom of the bar to show the title
    private let bottomSpace: CGFloat = 60.0
    
    /// space at the top of each bar to show the value
    private let topSpace: CGFloat = 66.0
    
    private var leftView = PageView()
    private var midleView = PageView()
    private var rightView = PageView()
    
    private var currentPageIndex = 0
    private var previousPageIndex = 0
    
    private var pages: [[DataEntry]] = []
    
    var chartType: ChartType = .week {
        didSet {
            updateDate()
        }
    }
    
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
        scrollView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 60).isActive = true
        scrollView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        scrollView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        
        scrollView.addSubview(leftView)
        scrollView.addSubview(midleView)
        scrollView.addSubview(rightView)
        
        addYAsisTitles()
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
        updateDate()
    }
    
    func updateDate() {
        leftView.updateDataEntries(dataEntries: leftView.presenter.dataEntries, chartType: chartType, animated: false)
        midleView.updateDataEntries(dataEntries: midleView.presenter.dataEntries, chartType: chartType, animated: false)
        rightView.updateDataEntries(dataEntries: rightView.presenter.dataEntries, chartType: chartType, animated: false)
        
        addYAsisTitles()
    }
    
    func setPages(pages: [[DataEntry]]) {
        self.pages = pages
        if pages.count > 0 {
            rightView.updateDataEntries(dataEntries: pages[0], chartType: chartType, animated: true)
        }
        
        if pages.count > 1 {
            midleView.updateDataEntries(dataEntries: pages[1], chartType: chartType, animated: true)
        }
        
        if pages.count > 2 {
            leftView.updateDataEntries(dataEntries: pages[2], chartType: chartType, animated: true)
        }
    }
    
    func addPages(pages: [[DataEntry]]) {
        self.pages.append(contentsOf: pages)
    }
    
    func addYAsisTitles() {
        
        subviews.forEach { view in
            if view is UILabel {
                view.removeFromSuperview()
            }
        }
        
        for index in 0...8 {
            let label = UILabel()
            label.textColor = UIColor(red: 0.235, green: 0.235, blue: 0.231, alpha: 0.6)

            label.font = UIFont(name: "Helvetica-Regular", size: 10)
            label.text = "\(index)"
            label.sizeToFit()
            label.frame = CGRect(x: 20, y: frame.size.height - bottomSpace - label.frame.size.height / 2 - CGFloat(index) * ((frame.size.height - bottomSpace - topSpace) / 8), width: label.frame.size.width, height: label.frame.size.height)
            addSubview(label)
        }
    }
}


extension BarChart: UIScrollViewDelegate {
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
            
            leftView.updateDataEntries(dataEntries: pages[currentPageIndex - 1], chartType: chartType, animated: false)
            
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
            
            rightView.updateDataEntries(dataEntries: pages[currentPageIndex + 1], chartType: chartType, animated: false)
            
            previousPageIndex = 1
        }
    }
}
