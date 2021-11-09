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
        
        addYAsisTitles()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
//        scrollView.contentSize = CGSize(width: scrollView.frame.size.width * 3, height: scrollView.frame.size.height)
//        if currentPageIndex == 0 {
//            scrollView.contentOffset = CGPoint(x: scrollView.frame.size.width * 2, y: 0)
//            previousPageIndex = 2
//        }
//        leftView.frame = CGRect(x: 0, y: 0, width: scrollView.frame.size.width, height: scrollView.frame.size.height)
//        midleView.frame = CGRect(x: scrollView.frame.size.width, y: 0, width: scrollView.frame.size.width, height: scrollView.frame.size.height)
//        rightView.frame = CGRect(x: scrollView.frame.size.width * 2, y: 0, width: scrollView.frame.size.width, height: scrollView.frame.size.height)
//        updateDate()
        updatePages()
    }
    
    func updateDate() {
        leftView.updateDataEntries(pageIndex: leftView.pageIndex, dataEntries: leftView.presenter.dataEntries, chartType: chartType, animated: false)
        midleView.updateDataEntries(pageIndex: midleView.pageIndex, dataEntries: midleView.presenter.dataEntries, chartType: chartType, animated: false)
        rightView.updateDataEntries(pageIndex: rightView.pageIndex, dataEntries: rightView.presenter.dataEntries, chartType: chartType, animated: false)
        
        addYAsisTitles()
    }
    
    func addEntries(_ entr: [DataEntry]) {
        let needUpdatePages = pages.isEmpty
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
                            self.entries.insert(DataEntry(height: 0, date: date, value: 0), at: 0)
                        }
                    }
                }

                
            }
        case .year:
            ()
        }
        
        calulatePages()
        if needUpdatePages {
            updatePages()
        }
        
    }
    
    func calulatePages() {
        var page = [DataEntry]()
        pages = []
        for (index, element) in self.entries.enumerated() {
            if index % 7 == 0 {
                if !page.isEmpty {
                    pages.append(page.reversed())
                }
                page = [DataEntry]()
            }
            page.append(element)
        }
    }
    
    func setPages(pages: [[DataEntry]]) {
        self.pages = pages
        if pages.count > 0 {
            rightView.updateDataEntries(pageIndex: 0, dataEntries: pages[0], chartType: chartType, animated: true)
        }
        
        if pages.count > 1 {
            midleView.updateDataEntries(pageIndex: 1, dataEntries: pages[1], chartType: chartType, animated: true)
        }
        
        if pages.count > 2 {
            leftView.updateDataEntries(pageIndex: 2, dataEntries: pages[2], chartType: chartType, animated: true)
        }
    }
    
    func updatePages() {
        guard !pages.isEmpty else {return}
        if currentPageIndex < (pages.count - 1) && currentPageIndex > 0 {
            scrollView.contentSize = CGSize(width: scrollView.frame.size.width * 3, height: scrollView.frame.size.height)
            scrollView.contentOffset = CGPoint(x: scrollView.frame.size.width, y: 0)
            
            if currentPageIndex > midleView.pageIndex {
                let tempView = rightView
                rightView = midleView
                midleView = leftView
                leftView = tempView
                leftView.updateDataEntries(pageIndex: currentPageIndex + 1, dataEntries: pages[currentPageIndex + 1], chartType: chartType, animated: false)
            } else if currentPageIndex < midleView.pageIndex {
                let tempView = leftView
                leftView = midleView
                midleView = rightView
                rightView = tempView
                rightView.updateDataEntries(pageIndex: currentPageIndex - 1, dataEntries: pages[currentPageIndex - 1], chartType: chartType, animated: false)
            }

            leftView.frame = CGRect(x: 0, y: 0, width: scrollView.frame.size.width, height: scrollView.frame.size.height)
            midleView.frame = CGRect(x: scrollView.frame.size.width, y: 0, width: scrollView.frame.size.width, height: scrollView.frame.size.height)
            rightView.frame = CGRect(x: scrollView.frame.size.width * 2, y: 0, width: scrollView.frame.size.width, height: scrollView.frame.size.height)
            
            leftView.isHidden = false
            midleView.isHidden = false
            rightView.isHidden = false
            
        } else if currentPageIndex == (pages.count - 1) && pages.count > 1 {
            scrollView.contentSize = CGSize(width: scrollView.frame.size.width * 2, height: scrollView.frame.size.height)
            scrollView.contentOffset = CGPoint(x: 0, y: 0)
            
//            if currentPageIndex > midleView.pageIndex {
//                let tempView = rightView
//                rightView = midleView
//                midleView = leftView
//                leftView = tempView
//                leftView.updateDataEntries(pageIndex: currentPageIndex + 1, dataEntries: pages[currentPageIndex + 1], chartType: chartType, animated: false)
//            }

            if leftView.pageIndex != (pages.count - 1) {
                leftView.updateDataEntries(pageIndex: currentPageIndex, dataEntries: pages[currentPageIndex], chartType: chartType, animated: false)
            }
            
            if midleView.pageIndex != (currentPageIndex - 1) {
                leftView.updateDataEntries(pageIndex: currentPageIndex, dataEntries: pages[currentPageIndex - 1], chartType: chartType, animated: false)
            }
            
            leftView.frame = CGRect(x: 0, y: 0, width: scrollView.frame.size.width, height: scrollView.frame.size.height)
            midleView.frame = CGRect(x: scrollView.frame.size.width, y: 0, width: scrollView.frame.size.width, height: scrollView.frame.size.height)
            rightView.frame = CGRect(x: scrollView.frame.size.width * 2, y: 0, width: scrollView.frame.size.width, height: scrollView.frame.size.height)
            
            
            
            leftView.isHidden = false
            midleView.isHidden = false
            rightView.isHidden = true

        } else if pages.count >= 3 {
            if currentPageIndex == 0 {
                scrollView.contentSize = CGSize(width: scrollView.frame.size.width * 3, height: scrollView.frame.size.height)
                scrollView.contentOffset = CGPoint(x: scrollView.frame.size.width * 2, y: 0)
                
                if currentPageIndex != rightView.pageIndex {
                    rightView.updateDataEntries(pageIndex: currentPageIndex, dataEntries: pages[currentPageIndex], chartType: chartType, animated: false)
                }
                
                if (currentPageIndex + 1) != midleView.pageIndex {
                    midleView.updateDataEntries(pageIndex: (currentPageIndex + 1), dataEntries: pages[(currentPageIndex + 1)], chartType: chartType, animated: false)
                }

                if (currentPageIndex + 2) != leftView.pageIndex {
                    leftView.updateDataEntries(pageIndex: (currentPageIndex + 2), dataEntries: pages[(currentPageIndex + 2)], chartType: chartType, animated: false)
                }
                
                leftView.frame = CGRect(x: 0, y: 0, width: scrollView.frame.size.width, height: scrollView.frame.size.height)
                midleView.frame = CGRect(x: scrollView.frame.size.width, y: 0, width: scrollView.frame.size.width, height: scrollView.frame.size.height)
                rightView.frame = CGRect(x: scrollView.frame.size.width * 2, y: 0, width: scrollView.frame.size.width, height: scrollView.frame.size.height)
                
                leftView.isHidden = false
                midleView.isHidden = false
                rightView.isHidden = false
            } else if currentPageIndex == (pages.count - 1) {
                scrollView.contentSize = CGSize(width: scrollView.frame.size.width * 3, height: scrollView.frame.size.height)
                scrollView.contentOffset = CGPoint(x: 0, y: 0)
                
                if currentPageIndex != leftView.pageIndex {
                    leftView.updateDataEntries(pageIndex: currentPageIndex, dataEntries: pages[currentPageIndex], chartType: chartType, animated: false)
                }
                
                if (currentPageIndex - 1) != midleView.pageIndex {
                    midleView.updateDataEntries(pageIndex: (currentPageIndex - 1), dataEntries: pages[(currentPageIndex - 1)], chartType: chartType, animated: false)
                }

                if (currentPageIndex - 2) != rightView.pageIndex {
                    rightView.updateDataEntries(pageIndex: (currentPageIndex - 2), dataEntries: pages[(currentPageIndex - 2)], chartType: chartType, animated: false)
                }
                
                leftView.frame = CGRect(x: 0, y: 0, width: scrollView.frame.size.width, height: scrollView.frame.size.height)
                midleView.frame = CGRect(x: scrollView.frame.size.width, y: 0, width: scrollView.frame.size.width, height: scrollView.frame.size.height)
                rightView.frame = CGRect(x: scrollView.frame.size.width * 2, y: 0, width: scrollView.frame.size.width, height: scrollView.frame.size.height)
                
                leftView.isHidden = false
                midleView.isHidden = false
                rightView.isHidden = false
            }
            
        } else if currentPageIndex == 0 && pages.count == 2 {
            scrollView.contentSize = CGSize(width: scrollView.frame.size.width * 2, height: scrollView.frame.size.height)
            scrollView.contentOffset = CGPoint(x: scrollView.frame.size.width, y: 0)
            
//            if currentPageIndex > midleView.pageIndex {
//                let tempView = rightView
//                rightView = midleView
//                midleView = leftView
//                leftView = tempView
//                leftView.updateDataEntries(pageIndex: currentPageIndex + 1, dataEntries: pages[currentPageIndex + 1], chartType: chartType, animated: false)
//            } else if currentPageIndex < midleView.pageIndex {
//                let tempView = leftView
//                leftView = midleView
//                midleView = rightView
//                rightView = tempView
//                rightView.updateDataEntries(pageIndex: currentPageIndex - 1, dataEntries: pages[currentPageIndex - 1], chartType: chartType, animated: false)
//            } else {
//                if (currentPageIndex + 1) < pages.count {
//                    leftView.updateDataEntries(pageIndex: currentPageIndex + 1, dataEntries: pages[currentPageIndex + 1], chartType: chartType, animated: false)
//                }
//
//                if (currentPageIndex - 1) >= 0 {
//                    rightView.updateDataEntries(pageIndex: currentPageIndex - 1, dataEntries: pages[currentPageIndex - 1], chartType: chartType, animated: false)
//                }
//            }

            if leftView.pageIndex != (currentPageIndex + 1) {
                leftView.updateDataEntries(pageIndex: currentPageIndex + 1, dataEntries: pages[currentPageIndex + 1], chartType: chartType, animated: false)
            }
            
            if midleView.pageIndex != (currentPageIndex) {
                midleView.updateDataEntries(pageIndex: currentPageIndex, dataEntries: pages[currentPageIndex], chartType: chartType, animated: false)
            }


            
            leftView.frame = CGRect(x: 0, y: 0, width: scrollView.frame.size.width, height: scrollView.frame.size.height)
            midleView.frame = CGRect(x: scrollView.frame.size.width, y: 0, width: scrollView.frame.size.width, height: scrollView.frame.size.height)
            rightView.frame = CGRect(x: scrollView.frame.size.width * 2, y: 0, width: scrollView.frame.size.width, height: scrollView.frame.size.height)
            
            leftView.isHidden = false
            midleView.isHidden = false
            rightView.isHidden = true

        } else {
            scrollView.contentSize = CGSize(width: scrollView.frame.size.width, height: scrollView.frame.size.height)
            scrollView.contentOffset = CGPoint(x: 0, y: 0)
            
            leftView.isHidden = true
            midleView.isHidden = false
            rightView.isHidden = true
            
            midleView.frame = CGRect(x: 0, y: 0, width: scrollView.frame.size.width, height: scrollView.frame.size.height)
            midleView.updateDataEntries(pageIndex: currentPageIndex, dataEntries: pages[currentPageIndex], chartType: chartType, animated: false)
        }
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
        
        if scrollView.bounds.contains(rightView.center) {
            currentPageIndex = rightView.pageIndex
        } else if scrollView.bounds.contains(midleView.center) {
            currentPageIndex = midleView.pageIndex
        } else if scrollView.bounds.contains(rightView.center) {
            currentPageIndex = rightView.pageIndex
        }
        
//        previousPageIndex = 1
//        let index = Int(scrollView.contentOffset.x / scrollView.bounds.size.width)
//
//        if (previousPageIndex - index) > 0 && currentPageIndex < (pages.count - 1) {
//            currentPageIndex += 1
//        } else if (previousPageIndex - index) < 0 && currentPageIndex > 0 {
//            currentPageIndex -= 1
//        }
//
//        previousPageIndex = 1
//        updatePages()
        
        
//        if index == 0 && currentPageIndex < (pages.count - 1) {
//            let firstView = rightView
//            let secondView = leftView
//            let thirdView = midleView
//            scrollView.contentOffset = CGPoint(x: scrollView.frame.size.width, y: 0)
//            firstView.frame = CGRect(x: 0, y: 0, width: scrollView.frame.size.width, height: scrollView.frame.size.height)
//            secondView.frame = CGRect(x: scrollView.frame.size.width, y: 0, width: scrollView.frame.size.width, height: scrollView.frame.size.height)
//            thirdView.frame = CGRect(x: scrollView.frame.size.width * 2, y: 0, width: scrollView.frame.size.width, height: scrollView.frame.size.height)
//            leftView = firstView
//            midleView = secondView
//            rightView = thirdView
//
//            leftView.updateDataEntries(dataEntries: pages[currentPageIndex - 1], chartType: chartType, animated: false)
//
//            previousPageIndex = 1
//        } else if index == 2 && currentPageIndex > 0 {
//            let firstView = midleView
//            let secondView = rightView
//            let thirdView = leftView
//            scrollView.contentOffset = CGPoint(x: scrollView.frame.size.width, y: 0)
//            firstView.frame = CGRect(x: 0, y: 0, width: scrollView.frame.size.width, height: scrollView.frame.size.height)
//            secondView.frame = CGRect(x: scrollView.frame.size.width, y: 0, width: scrollView.frame.size.width, height: scrollView.frame.size.height)
//            thirdView.frame = CGRect(x: scrollView.frame.size.width * 2, y: 0, width: scrollView.frame.size.width, height: scrollView.frame.size.height)
//            leftView = firstView
//            midleView = secondView
//            rightView = thirdView
//
//            rightView.updateDataEntries(dataEntries: pages[currentPageIndex + 1], chartType: chartType, animated: false)
//
//            previousPageIndex = 1
//        }
    }
}
