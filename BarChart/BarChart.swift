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
    private let horisontalLinesCount = 8
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
    
    private var entries: [DataEntry] = []
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
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        
        scrollView.delegate = self
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 60).isActive = true
        scrollView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        scrollView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        
        scrollView.addSubview(leftView)
        scrollView.addSubview(midleView)
        scrollView.addSubview(rightView)
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updatePages()
    }
    
    func updateDate() {
        let maxVal = calculateYAxiseMaxValue()
        leftView.updateDataEntries(pageIndex: leftView.pageIndex, dataEntries: leftView.presenter.dataEntries, maxValue: maxVal, chartType: chartType, animated: false)
        midleView.updateDataEntries(pageIndex: midleView.pageIndex, dataEntries: midleView.presenter.dataEntries, maxValue: maxVal, chartType: chartType, animated: false)
        rightView.updateDataEntries(pageIndex: rightView.pageIndex, dataEntries: rightView.presenter.dataEntries, maxValue: maxVal, chartType: chartType, animated: false)
    }
    
    func addEntries(_ entr: [DataEntry]) {
        self.entries.append(contentsOf: entr)
        
        switch chartType {
        case .week:
            let calendar = Calendar.current
            if let firstDay = self.entries.first?.date {
                let lastDay = calendar.startOfDay(for: firstDay)
                let dayOfWeek = calendar.component(.weekday, from: lastDay)
                let div = 7 - dayOfWeek
                if div > 0 {
                    for n in 1...div {
                        if let date = calendar.date(byAdding: .day, value: n, to: lastDay) {
                            self.entries.insert(DataEntry(date: date, value: 0), at: 0)
                        }
                    }
                }
            }
        case .year:
            let calendar = Calendar.current
            if let firstDay = self.entries.first?.date {
                let lastDay = calendar.startOfDay(for: firstDay)
                let monthOfYear = calendar.component(.month, from: lastDay)
                let div = 12 - monthOfYear
                if div > 0 {
                    for n in 1...div {
                        if let date = calendar.date(byAdding: .month, value: n, to: lastDay) {
                            self.entries.insert(DataEntry(date: date, value: 0), at: 0)
                        }
                    }
                }
            }
        }
        
        calulatePages()
        updatePages()
        
    }
    
    func calulatePages() {
        var page = [DataEntry]()
        pages = []
        
        for (index, element) in self.entries.enumerated() {
            if index % (chartType == .week ? 7 : 12) == 0 {
                if !page.isEmpty {
                    pages.append(page.reversed())
                }
                page = [DataEntry]()
            }
            page.append(element)
        }
    }
    
    func calculateYAxiseMaxValue() -> Int {
        // find max value
        
        guard pages.count > currentPageIndex else {return 0}
        let maxValue = pages[currentPageIndex].map{$0.value}.max() ?? 0
        
        let coef =  maxValue / horisontalLinesCount + ((maxValue % horisontalLinesCount) > 0 ? 1 : 0)
        
        return coef * horisontalLinesCount
    }
    
    func updatePages() {
        guard !pages.isEmpty else {return}
        
        let maxValue = calculateYAxiseMaxValue()
        
        if currentPageIndex < (pages.count - 1) && currentPageIndex > 0 { // if >=3 page, current page at the middle
            scrollView.contentSize = CGSize(width: scrollView.frame.size.width * 3, height: scrollView.frame.size.height)
            scrollView.contentOffset = CGPoint(x: scrollView.frame.size.width, y: 0)
            
            if currentPageIndex > midleView.pageIndex {
                let tempView = rightView
                rightView = midleView
                midleView = leftView
                leftView = tempView
                
                leftView.frame = CGRect(x: 0, y: 0, width: scrollView.frame.size.width, height: scrollView.frame.size.height)
                midleView.frame = CGRect(x: scrollView.frame.size.width, y: 0, width: scrollView.frame.size.width, height: scrollView.frame.size.height)
                rightView.frame = CGRect(x: scrollView.frame.size.width * 2, y: 0, width: scrollView.frame.size.width, height: scrollView.frame.size.height)
                
                leftView.updateDataEntries(pageIndex: currentPageIndex + 1, dataEntries: pages[currentPageIndex + 1], maxValue: maxValue, chartType: chartType, animated: false)
            } else if currentPageIndex < midleView.pageIndex {
                let tempView = leftView
                leftView = midleView
                midleView = rightView
                rightView = tempView
                
                leftView.frame = CGRect(x: 0, y: 0, width: scrollView.frame.size.width, height: scrollView.frame.size.height)
                midleView.frame = CGRect(x: scrollView.frame.size.width, y: 0, width: scrollView.frame.size.width, height: scrollView.frame.size.height)
                rightView.frame = CGRect(x: scrollView.frame.size.width * 2, y: 0, width: scrollView.frame.size.width, height: scrollView.frame.size.height)
                
                rightView.updateDataEntries(pageIndex: currentPageIndex - 1, dataEntries: pages[currentPageIndex - 1], maxValue: maxValue, chartType: chartType, animated: false)
            }
            
            midleView.updateDataEntries(pageIndex: currentPageIndex, dataEntries: pages[currentPageIndex], maxValue: maxValue, chartType: chartType, animated: false)
            
            leftView.isHidden = false
            midleView.isHidden = false
            rightView.isHidden = false
            
        } else if currentPageIndex == (pages.count - 1) && pages.count > 1 { // if >=3 page, current page at the left
            scrollView.contentSize = CGSize(width: scrollView.frame.size.width * 2, height: scrollView.frame.size.height)
            scrollView.contentOffset = CGPoint(x: 0, y: 0)


            leftView.frame = CGRect(x: 0, y: 0, width: scrollView.frame.size.width, height: scrollView.frame.size.height)
            midleView.frame = CGRect(x: scrollView.frame.size.width, y: 0, width: scrollView.frame.size.width, height: scrollView.frame.size.height)
            rightView.frame = CGRect(x: scrollView.frame.size.width * 2, y: 0, width: scrollView.frame.size.width, height: scrollView.frame.size.height)
            if midleView.pageIndex != (currentPageIndex - 1) {
                midleView.updateDataEntries(pageIndex: currentPageIndex - 1, dataEntries: pages[currentPageIndex - 1], maxValue: maxValue, chartType: chartType, animated: false)
            }
            
            leftView.updateDataEntries(pageIndex: currentPageIndex, dataEntries: pages[currentPageIndex], maxValue: maxValue, chartType: chartType, animated: false)
            
            leftView.isHidden = false
            midleView.isHidden = false
            rightView.isHidden = true

        } else if pages.count >= 3 {
            if currentPageIndex == 0 {// if >=3 page, current page at the right
                scrollView.contentSize = CGSize(width: scrollView.frame.size.width * 3, height: scrollView.frame.size.height)
                scrollView.contentOffset = CGPoint(x: scrollView.frame.size.width * 2, y: 0)
                
                
                leftView.frame = CGRect(x: 0, y: 0, width: scrollView.frame.size.width, height: scrollView.frame.size.height)
                midleView.frame = CGRect(x: scrollView.frame.size.width, y: 0, width: scrollView.frame.size.width, height: scrollView.frame.size.height)
                rightView.frame = CGRect(x: scrollView.frame.size.width * 2, y: 0, width: scrollView.frame.size.width, height: scrollView.frame.size.height)
                
                if (currentPageIndex + 1) != midleView.pageIndex {
                    midleView.updateDataEntries(pageIndex: (currentPageIndex + 1), dataEntries: pages[(currentPageIndex + 1)], maxValue: maxValue, chartType: chartType, animated: false)
                }

                if (currentPageIndex + 2) != leftView.pageIndex {
                    leftView.updateDataEntries(pageIndex: (currentPageIndex + 2), dataEntries: pages[(currentPageIndex + 2)], maxValue: maxValue, chartType: chartType, animated: false)
                }
                
                rightView.updateDataEntries(pageIndex: currentPageIndex, dataEntries: pages[currentPageIndex], maxValue: maxValue, chartType: chartType, animated: false)
                
                leftView.isHidden = false
                midleView.isHidden = false
                rightView.isHidden = false
            } else if currentPageIndex == (pages.count - 1) { // if >=3 page, current page at the left
                scrollView.contentSize = CGSize(width: scrollView.frame.size.width * 3, height: scrollView.frame.size.height)
                scrollView.contentOffset = CGPoint(x: 0, y: 0)
                
                leftView.frame = CGRect(x: 0, y: 0, width: scrollView.frame.size.width, height: scrollView.frame.size.height)
                midleView.frame = CGRect(x: scrollView.frame.size.width, y: 0, width: scrollView.frame.size.width, height: scrollView.frame.size.height)
                rightView.frame = CGRect(x: scrollView.frame.size.width * 2, y: 0, width: scrollView.frame.size.width, height: scrollView.frame.size.height)
                
                if (currentPageIndex - 1) != midleView.pageIndex {
                    midleView.updateDataEntries(pageIndex: (currentPageIndex - 1), dataEntries: pages[(currentPageIndex - 1)], maxValue: maxValue, chartType: chartType, animated: false)
                }

                if (currentPageIndex - 2) != rightView.pageIndex {
                    rightView.updateDataEntries(pageIndex: (currentPageIndex - 2), dataEntries: pages[(currentPageIndex - 2)], maxValue: maxValue, chartType: chartType, animated: false)
                }
                
                
                leftView.updateDataEntries(pageIndex: currentPageIndex, dataEntries: pages[currentPageIndex], maxValue: maxValue, chartType: chartType, animated: false)
                
                leftView.isHidden = false
                midleView.isHidden = false
                rightView.isHidden = false
            }
            
        } else if currentPageIndex == 0 && pages.count == 2 { // if 2 page left is current
            scrollView.contentSize = CGSize(width: scrollView.frame.size.width * 2, height: scrollView.frame.size.height)
            scrollView.contentOffset = CGPoint(x: scrollView.frame.size.width, y: 0)
            

            leftView.frame = CGRect(x: 0, y: 0, width: scrollView.frame.size.width, height: scrollView.frame.size.height)
            midleView.frame = CGRect(x: scrollView.frame.size.width, y: 0, width: scrollView.frame.size.width, height: scrollView.frame.size.height)
            rightView.frame = CGRect(x: scrollView.frame.size.width * 2, y: 0, width: scrollView.frame.size.width, height: scrollView.frame.size.height)
            
            leftView.isHidden = false
            midleView.isHidden = false
            rightView.isHidden = true
            
            if leftView.pageIndex != (currentPageIndex + 1) {
                leftView.updateDataEntries(pageIndex: currentPageIndex + 1, dataEntries: pages[currentPageIndex + 1], maxValue: maxValue, chartType: chartType, animated: false)
            }
            
            midleView.updateDataEntries(pageIndex: currentPageIndex, dataEntries: pages[currentPageIndex], maxValue: maxValue, chartType: chartType, animated: false)

        } else if currentPageIndex == 1 && pages.count == 2 { // if 2 page right is current
            scrollView.contentSize = CGSize(width: scrollView.frame.size.width * 2, height: scrollView.frame.size.height)
            scrollView.contentOffset = CGPoint(x: 0, y: 0)
            

            leftView.frame = CGRect(x: 0, y: 0, width: scrollView.frame.size.width, height: scrollView.frame.size.height)
            midleView.frame = CGRect(x: scrollView.frame.size.width, y: 0, width: scrollView.frame.size.width, height: scrollView.frame.size.height)
            rightView.frame = CGRect(x: scrollView.frame.size.width * 2, y: 0, width: scrollView.frame.size.width, height: scrollView.frame.size.height)
            
            leftView.isHidden = false
            midleView.isHidden = false
            rightView.isHidden = true
            
            leftView.updateDataEntries(pageIndex: currentPageIndex + 1, dataEntries: pages[currentPageIndex + 1], maxValue: maxValue, chartType: chartType, animated: false)
            
            if midleView.pageIndex != (currentPageIndex) {
                midleView.updateDataEntries(pageIndex: currentPageIndex, dataEntries: pages[currentPageIndex], maxValue: maxValue, chartType: chartType, animated: false)
            }

        } else { // if 1 page
            scrollView.contentSize = CGSize(width: scrollView.frame.size.width, height: scrollView.frame.size.height)
            scrollView.contentOffset = CGPoint(x: 0, y: 0)
            
            leftView.isHidden = true
            midleView.isHidden = false
            rightView.isHidden = true
            
            midleView.frame = CGRect(x: 0, y: 0, width: scrollView.frame.size.width, height: scrollView.frame.size.height)
            midleView.updateDataEntries(pageIndex: currentPageIndex, dataEntries: pages[currentPageIndex], maxValue: maxValue, chartType: chartType, animated: false)
        }
        
        updateYAsisTitles()
    }
    
    func updateYAsisTitles() {
        
        subviews.forEach { view in
            if view is UILabel {
                view.removeFromSuperview()
            }
        }
        
        let yAxiseMaxValue = calculateYAxiseMaxValue()
        
        for index in 0...horisontalLinesCount {
            let label = UILabel()
            label.textColor = UIColor(red: 0.235, green: 0.235, blue: 0.231, alpha: 0.6)

            label.font = UIFont(name: "Helvetica-Regular", size: 10)
            label.text = "\(index * (yAxiseMaxValue / horisontalLinesCount))"
            label.sizeToFit()
            label.frame = CGRect(x: 20, y: frame.size.height - bottomSpace - label.frame.size.height / 2 - CGFloat(index) * ((frame.size.height - bottomSpace - topSpace) / 8), width: label.frame.size.width, height: label.frame.size.height)
            addSubview(label)
        }
    }
}


extension BarChart: UIScrollViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        if scrollView.bounds.contains(leftView.center) {
            currentPageIndex = leftView.pageIndex
        } else if scrollView.bounds.contains(midleView.center) {
            currentPageIndex = midleView.pageIndex
        } else if scrollView.bounds.contains(rightView.center) {
            currentPageIndex = rightView.pageIndex
        }
        leftView.selectedBarEntry = nil
        midleView.selectedBarEntry = nil
        rightView.selectedBarEntry = nil
        updatePages()
    }
}
