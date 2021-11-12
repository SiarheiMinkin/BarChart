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
       barChart.chartType = .year
        self.barChart.addEntries(generateRandomDataEntries())
        let timer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) {[unowned self] (timer) in
            let dataEntries = self.generateRandomDataEntries()
            self.barChart.addEntries(dataEntries)
        }
        timer.fire()
    }
    
    func generateEmptyDataEntries() -> [DataEntry] {
        var result: [DataEntry] = []
        Array(0..<numEntry).forEach {_ in
            result.append(DataEntry(date: Date(), value: 0))
        }
        return result
    }
    
    func generateRandomDataEntries() -> [DataEntry] {
        var result: [DataEntry] = []
        for i in 0..<numEntry {
            let value = (Int(arc4random()) % (counter + 1))
            let formatter = DateFormatter()
            formatter.dateFormat = "d MMM"
            var date = Date()
            date.addTimeInterval(-TimeInterval(24*60*60*counter * 30))
            counter += 1
            result.append(DataEntry(date: date, value: Int(value)))
        }
        return result
    }
}

