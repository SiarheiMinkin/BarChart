//
//  BasicBarChartPresenter.swift
//  BarChart
//


import Foundation
import CoreGraphics.CGGeometry

class PageViewPresenter {
    /// the width of each bar
    let barWidth: CGFloat
    
    /// the space between bars
    var space: CGFloat = 0
    
    /// space at the bottom of the bar to show the title
    private let bottomSpace: CGFloat = 60.0
    
    /// space at the top of each bar to show the value
    private let topSpace: CGFloat = 66.0
    
    var dataEntries: [DataEntry] = []
    
    init(barWidth: CGFloat = 20) {
        self.barWidth = barWidth
    }
    
    func computeContentWidth() -> CGFloat {
        return (barWidth + space) * CGFloat(dataEntries.count)
    }
    
    func computeBarEntries(chartFrame: CGRect, maxValue: Int) -> [BarEntry] {
        space = (chartFrame.width - barWidth * CGFloat(dataEntries.count)) / CGFloat(dataEntries.count)
        var result: [BarEntry] = []
        for (index, entry) in dataEntries.enumerated() {
            let entryHeight = (chartFrame.height - bottomSpace - topSpace) / CGFloat(maxValue) * CGFloat(entry.value)
            let xPosition: CGFloat = space / 2 + CGFloat(index) * (barWidth + space)
            let yPosition = chartFrame.height - bottomSpace - entryHeight
            let origin = CGPoint(x: xPosition, y: yPosition)
            
            let barEntry = BarEntry(origin: origin, barWidth: barWidth, barHeight: entryHeight, space: space, data: entry)
            
            result.append(barEntry)
        }
        return result
    }
    
    func computeHorizontalLines(viewHeight: CGFloat) -> [HorizontalLine] {
        var result: [HorizontalLine] = []
        let step = 1.0 / 8.0
        let horizontalLineInfos = [
            (value: CGFloat(0.0), isDashed: false),
            (value: CGFloat(step * 1), isDashed: false),
            (value: CGFloat(step * 2), isDashed: false),
            (value: CGFloat(step * 3), isDashed: false),
            (value: CGFloat(step * 4), isDashed: false),
            (value: CGFloat(step * 5), isDashed: false),
            (value: CGFloat(step * 6), isDashed: false),
            (value: CGFloat(step * 7), isDashed: false),
            (value: CGFloat(step * 8), isDashed: false)
        ]
        
        for lineInfo in horizontalLineInfos {
            let yPosition = viewHeight - bottomSpace -  lineInfo.value * (viewHeight - bottomSpace - topSpace)
            
            let length = self.computeContentWidth()
            let lineSegment = LineSegment(
                startPoint: CGPoint(x: 0, y: yPosition),
                endPoint: CGPoint(x: length, y: yPosition)
            )
            let line = HorizontalLine(
                segment: lineSegment,
                isDashed: lineInfo.isDashed,
                width: 1)
            result.append(line)
        }
        
        return result
    }
}
