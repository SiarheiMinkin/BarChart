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
    let presenter = BasicBarChartPresenter()
    
    /// An array of bar entries. Each BasicBarEntry contain information about line segments, curved line segments, positions and frames of all elements on a bar.
    private var barEntries: [BasicBarEntry] = [] {
        didSet {
            mainLayer.sublayers?.forEach({$0.removeFromSuperlayer()})
            
            mainLayer.frame = CGRect(x: 0, y: 0, width: frame.width, height: frame.height)
            showHorizontalLines()
            
            for (index, entry) in barEntries.enumerated() {
                barEntries[index].barLayer = showEntry(index: index, entry: entry, animated: animated, oldEntry: oldValue.safeValue(at: index))
            }
        }
    }
    
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
    
    private var selectedBarEntry: BasicBarEntry? {
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

                pinnerView.dateLabel.text = selectedBarEntry.data.title
                pinnerView.valueLabel.text = selectedBarEntry.data.textValue
                
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
        
    func updateDataEntries(dataEntries: [DataEntry], animated: Bool) {
        self.animated = animated
        self.presenter.dataEntries = dataEntries
        self.barEntries = self.presenter.computeBarEntries(chartFrame: frame)
    }
    
    private func showEntry(index: Int, entry: BasicBarEntry, animated: Bool, oldEntry: BasicBarEntry?) -> BarLayer {
        
        let cgColor = entry.data.color.cgColor
        
        // Show the main bar
        let layer = mainLayer.addRectangleLayer(frame: entry.barFrame, color: cgColor, animated: animated, oldFrame: oldEntry?.barFrame)

        // Show a title below the bar
        mainLayer.addTextLayer(frame: entry.bottomTitleFrame, color: cgColor, fontSize: 14, text: entry.data.title, animated: animated, oldFrame: oldEntry?.bottomTitleFrame)
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
            mainLayer.addLineLayer(lineSegment: line.segment, color: #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1).cgColor, width: line.width, isDashed: line.isDashed, animated: false, oldSegment: nil)
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
