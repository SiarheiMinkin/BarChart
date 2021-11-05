//
//  PageView.swift
//  BarChart
//

import UIKit

let mainColor = UIColor(red: 65.0/255.0, green: 142.0/255.0, blue: 145.0/255.0, alpha: 1)

class PinnerView: UIView {
    var dateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Helvetica", size: 10)
        label.textColor = UIColor(red: 0.173, green: 0.173, blue: 0.173, alpha: 0.7)
        return label
    }()
    var valueLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Helvetica", size: 16)
        label.textColor = UIColor(red: 0.173, green: 0.173, blue: 0.173, alpha: 1)
        return label
    }()
    
    var chartType: BarChart.ChartType = .week
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(self.dateLabel)
        self.addSubview(self.valueLabel)
        let margin: CGFloat = 8
        dateLabel.frame = CGRect(x: margin, y: margin / 2, width: frame.width - margin * 2, height: frame.height / 2 - margin)
        valueLabel.frame = CGRect(x: margin, y: (frame.height) / 2, width: frame.width - margin * 2, height: frame.height / 2 - margin)
        backgroundColor = mainColor.withAlphaComponent(0.2)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class PageView: UIView {
    // contain all layers of the chart
    private let mainLayer: CALayer = CALayer()

    /// A flag to indicate whether or not to animate the bar chart when its data entries changed
    private var animated = false
    
    /// Responsible for compute all positions and frames of all elements represent on the bar chart
    let presenter = PageViewPresenter()
    
    /// An array of bar entries. Each BasicBarEntry contain information about line segments, curved line segments, positions and frames of all elements on a bar.
    private var barEntries: [BarEntry] = [] {
        didSet {
            mainLayer.sublayers?.forEach({$0.removeFromSuperlayer()})
            
            mainLayer.frame = CGRect(x: 0, y: 0, width: frame.width, height: frame.height)
            showHorizontalLines()
            
            for (index, entry) in barEntries.enumerated() {
                barEntries[index].barLayer = showEntry(index: index, entry: entry, animated: animated, oldEntry: oldValue.safeValue(at: index))
            }
        }
    }
    
    private var chartType: BarChart.ChartType = .week
    
    private var pinnerView: PinnerView = {
       let view = PinnerView(frame: CGRect(x: 0, y: 7, width: 112, height: 46))
        view.layer.cornerRadius = 5
        return view
    }()
    
    var lineView: UIView = {
       let view = UIView()
        view.backgroundColor = mainColor.withAlphaComponent(0.2)
        return view
    }()
    
    private var selectedBarEntry: BarEntry? {
        didSet {
            pinnerView.isHidden = false
            self.deselectAll()
            if let selectedBarEntry = selectedBarEntry, let barLayer = selectedBarEntry.barLayer {
                barLayer.shadowColor = mainColor.withAlphaComponent(0.2).cgColor
                
                let shadowPath = UIBezierPath(roundedRect: CGRect(x: -2, y: -2, width: barLayer.frame.width + 4, height: barLayer.frame.height + 4), cornerRadius: 5)
                barLayer.shadowPath = shadowPath.cgPath

                barLayer.shadowOffset = .zero
                barLayer.shadowRadius = 0
                barLayer.shadowOpacity = 1
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "MMMM, yyyy"
                pinnerView.dateLabel.text = dateFormatter.string(from: selectedBarEntry.data.date)
                pinnerView.valueLabel.text = "\(selectedBarEntry.data.value)"
                
                var pinnerFrame = pinnerView.frame
                if let barLayerFrame = selectedBarEntry.barLayer?.frame {
                    let centerX = barLayerFrame.origin.x + barLayerFrame.width / 2
                    if (centerX - pinnerView.frame.size.width) < 0 {
                        pinnerFrame.origin.x = 0
                    } else if (centerX + pinnerView.frame.size.width) > frame.size.width {
                        pinnerFrame.origin.x = frame.size.width - pinnerFrame.width
                    } else {
                        pinnerFrame.origin.x = centerX - pinnerFrame.width / 2
                    }
                    pinnerView.frame = pinnerFrame
                    lineView.frame = CGRect(x: barLayerFrame.origin.x + barLayerFrame.width / 2, y: pinnerFrame.origin.y + pinnerFrame.size.height, width: 2, height: barLayerFrame.origin.y - (pinnerFrame.origin.y + pinnerFrame.height))
                }
                
            }
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
    
    func setupView() {
        self.layer.addSublayer(mainLayer)
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.tapActions(touch:)))
            tap.numberOfTapsRequired = 1
            addGestureRecognizer(tap)
        
        let longTapRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(self.longTapActions(touch:)))
            addGestureRecognizer(longTapRecognizer)
        
        addSubview(pinnerView)
        pinnerView.isHidden = true
        
        addSubview(lineView)
        lineView.isHidden = false
        
    }
        
    func updateDataEntries(dataEntries: [DataEntry], chartType: BarChart.ChartType, animated: Bool) {
        self.chartType = chartType
        self.animated = animated
        self.presenter.dataEntries = dataEntries
        self.barEntries = self.presenter.computeBarEntries(chartFrame: frame)
    }
    
    private func showEntry(index: Int, entry: BarEntry, animated: Bool, oldEntry: BarEntry?) -> BarLayer {
        
        let cgColor = entry.data.color.cgColor
        
        // Show the main bar
        let layer = mainLayer.addRectangleLayer(frame: entry.barFrame, color: cgColor, animated: animated, oldFrame: oldEntry?.barFrame)

        // Show a title below the bar
        let dateFormatter = DateFormatter()
        switch chartType {
        case .week:
            dateFormatter.dateFormat = "dd"
            let barFrame = entry.barFrame
            
            let dateLayer = CATextLayer()
            dateLayer.frame = CGRect(x: barFrame.origin.x, y: barFrame.origin.y + barFrame.size.height + 20, width: barFrame.size.width, height: 12)
            dateLayer.foregroundColor = UIColor.black.cgColor
            dateLayer.backgroundColor = UIColor.clear.cgColor
            dateLayer.alignmentMode = CATextLayerAlignmentMode.center
            dateLayer.contentsScale = UIScreen.main.scale
            dateLayer.font = CTFontCreateWithName(UIFont.systemFont(ofSize: 0).fontName as CFString, 0, nil)
            dateLayer.fontSize = 10
            dateLayer.string = dateFormatter.string(from: entry.data.date)
            mainLayer.addSublayer(dateLayer)
            
            dateFormatter.dateFormat = "EEE"
            let dayLayer = CATextLayer()
            dayLayer.frame = CGRect(x: dateLayer.frame.origin.x, y: dateLayer.frame.origin.y + dateLayer.frame.size.height + 5, width: dateLayer.frame.size.width, height: 12)
            dayLayer.foregroundColor = UIColor(red: 0.235, green: 0.235, blue: 0.231, alpha: 0.6).cgColor
            dayLayer.backgroundColor = UIColor.clear.cgColor
            dayLayer.alignmentMode = CATextLayerAlignmentMode.center
            dayLayer.contentsScale = UIScreen.main.scale
            dayLayer.font = CTFontCreateWithName(UIFont.systemFont(ofSize: 0).fontName as CFString, 0, nil)
            dayLayer.fontSize = 10
            dayLayer.string = dateFormatter.string(from: entry.data.date)
            mainLayer.addSublayer(dayLayer)
            
            if Calendar.current.isDateInToday(entry.data.date) {
                let layer = CALayer()
                layer.cornerRadius = 2
                layer.frame = CGRect(x: dayLayer.frame.origin.x + dayLayer.frame.width / 2 - 4, y: dayLayer.frame.origin.y + dayLayer.frame.height + 4, width: 8, height: 4)
                layer.backgroundColor = mainColor.cgColor
                mainLayer.addSublayer(layer)
            }
                        

        case .year:
            dateFormatter.dateFormat = "MMM"
            let barFrame = entry.barFrame
            
            let dateLayer = CATextLayer()
            dateLayer.frame = CGRect(x: barFrame.origin.x, y: barFrame.origin.y + barFrame.size.height + 20, width: barFrame.size.width, height: 12)
            dateLayer.foregroundColor = UIColor(red: 0.235, green: 0.235, blue: 0.231, alpha: 0.6).cgColor
            dateLayer.backgroundColor = UIColor.clear.cgColor
            dateLayer.alignmentMode = CATextLayerAlignmentMode.center
            dateLayer.contentsScale = UIScreen.main.scale
            dateLayer.font = CTFontCreateWithName(UIFont.systemFont(ofSize: 0).fontName as CFString, 0, nil)
            dateLayer.fontSize = 10
            dateLayer.string = dateFormatter.string(from: entry.data.date)
            dateLayer.transform = CATransform3DMakeAffineTransform(CGAffineTransform(rotationAngle: -.pi/4));
            mainLayer.addSublayer(dateLayer)
            
            if Calendar.current.isDate(entry.data.date, equalTo: Date(), toGranularity: .month) {
                let layer = CALayer()
                layer.cornerRadius = 2
                layer.frame = CGRect(x: dateLayer.frame.origin.x + dateLayer.frame.width / 2 - 4, y: dateLayer.frame.origin.y + dateLayer.frame.height + 4, width: 8, height: 4)
                layer.backgroundColor = mainColor.cgColor
                mainLayer.addSublayer(layer)
            }
        }

        return layer
    }
    
    private func showHorizontalLines() {
        self.layer.sublayers?.forEach({
            if $0 is CAShapeLayer {
                $0.removeFromSuperlayer()
            }
        })
        let lines = presenter.computeHorizontalLines(viewHeight: self.frame.height)
        lines.forEach { (line) in
            mainLayer.addLineLayer(lineSegment: line.segment, color: #colorLiteral(red: 249.0 / 255, green: 249.0 / 255, blue: 248.0 / 255, alpha: 1).cgColor, width: line.width, isDashed: line.isDashed, animated: false, oldSegment: nil)
        }
    }
    
    func deselectAll() {
        barEntries.forEach { barEntry in
            barEntry.barLayer?.shadowOpacity = 0
        }
    }
    
    func checkSelectedBar(with touchPoint: CGPoint) {
        if let barEntry = barEntries.filter({ barEntry in
            if let layer = barEntry.barLayer, (layer.frame.origin.x < touchPoint.x) && ((layer.frame.origin.x + layer.frame.width) > touchPoint.x) && (layer is BarLayer) {
                return true
            }
            return false
            //layer.contains(layer.convert(touchPoint, from: layer.superlayer)) && (layer is BarLayer)
        }).first {
            selectedBarEntry = barEntry
        }
    }
    
    // MARK: - Actions
    
   @objc func tapActions(touch: UITapGestureRecognizer) {
        let touchPoint = touch.location(in: self)
       checkSelectedBar(with: touchPoint)
    }
    
    @objc func longTapActions(touch: UILongPressGestureRecognizer)
    {
        print(touch.state.rawValue)
        let touchPoint = touch.location(in: self)
        checkSelectedBar(with: touchPoint)
    }
    
}
