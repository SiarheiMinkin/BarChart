//
//  ViewController.swift
//  BarChart
//


import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var barChart: BarChart!
    
    private let numEntry = 7
    private var counter = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
       barChart.chartType = .week
        self.barChart.addEntries(generateRandomDataEntries())
      // barChart.setPages(pages: [generateEmptyDataEntries()])
      // barChart.setPages(pages: [generateRandomDataEntries(), generateRandomDataEntries(), generateRandomDataEntries()])
        
        let timer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) {[unowned self] (timer) in
            let dataEntries = self.generateRandomDataEntries()
            self.barChart.addEntries(dataEntries)
        }
        timer.fire()
    }
    
    func generateEmptyDataEntries() -> [DataEntry] {
        var result: [DataEntry] = []
        Array(0..<numEntry).forEach {_ in
            result.append(DataEntry(height: 0, date: Date(), value: 0))
        }
        return result
    }
    
    func generateRandomDataEntries() -> [DataEntry] {
        var result: [DataEntry] = []
        for i in 0..<numEntry {
            let value = (Int(arc4random()) % (counter + 1))
            let height: Float = Float(value) / 100.0
            
            let formatter = DateFormatter()
            formatter.dateFormat = "d MMM"
            var date = Date()
            date.addTimeInterval(-TimeInterval(24*60*60*counter))
            counter += 1
            result.append(DataEntry(height: height, date: date, value: Int(value)))
        }
        return result
    }
}

