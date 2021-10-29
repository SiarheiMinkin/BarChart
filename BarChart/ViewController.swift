//
//  ViewController.swift
//  BarChart
//


import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var basicBarChart: BasicBarChart!
    
    private let numEntry = 7
    private var counter = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        var dataEntries = generateEmptyDataEntries()
       basicBarChart.setPages(pages: [dataEntries])
       basicBarChart.setPages(pages: [generateRandomDataEntries(), generateRandomDataEntries(), generateRandomDataEntries()])
        
        let timer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) {[unowned self] (timer) in
            let dataEntries = self.generateRandomDataEntries()
            self.basicBarChart.addPages(pages: [dataEntries])
        }
        timer.fire()
    }
    
    func generateEmptyDataEntries() -> [DataEntry] {
        var result: [DataEntry] = []
        Array(0..<numEntry).forEach {_ in
            result.append(DataEntry(color: UIColor.clear, height: 0, textValue: "0", title: ""))
        }
        return result
    }
    
    func generateRandomDataEntries() -> [DataEntry] {
        var result: [DataEntry] = []
        for i in 0..<numEntry {
            let value = (arc4random() % 90) + 10
            let height: Float = Float(value) / 100.0
            
            let formatter = DateFormatter()
            formatter.dateFormat = "d MMM"
            var date = Date()
            date.addTimeInterval(TimeInterval(24*60*60*counter))
            counter += 1
            result.append(DataEntry(color: UIColor(red: 65.0/255.0, green: 142.0/255.0, blue: 145.0/255.0, alpha: 1), height: height, textValue: "\(value)", title: formatter.string(from: date)))
        }
        return result.reversed()
    }
}

