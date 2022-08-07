//
//  AsteroidChartVC.swift
//  AsteroidNeoApp
//
//  Created by iMac on 05/08/22.
//

import UIKit
import Alamofire
import Toast_Swift
import Charts


class AsteroidChartVC: UIViewController {
    
    
    var arrAllAeteroid = [NearEarthObject]()
    var arrDate = [String]()
    var arrAsteroidCountperDate = [Double]()
    
    var startDate = Date()
    var endDate = Date()
    
    
    fileprivate lazy var dateFormatter: DateFormatter = {
        
        let formatter = DateFormatter()
        formatter.locale = NSLocale.init(localeIdentifier: "en") as Locale
        formatter.timeZone = .current
        formatter.dateFormat = "yyyy-MM-dd"
        
        return formatter
    }()
    
    
    //MARK:- *************** OUTLET ***************
    
    @IBOutlet weak var txtStartDate: UITextField!
    @IBOutlet weak var txtEndDate: UITextField!
    @IBOutlet weak var btnSubmit: UIButton!
    @IBOutlet weak var viewAsteroidDetail: UIView!
    @IBOutlet weak var lblFastestAsteroid: UILabel!
    @IBOutlet weak var lblClosestAsteroid: UILabel!
    @IBOutlet weak var lblAsteroidAverageSize: UILabel!
    @IBOutlet weak var chartView: BarChartView!
    
    
    //MARK:- *************** LIFE CYCLE ***************

    override func viewDidLoad() {
        super.viewDidLoad()

        
        self.viewAsteroidDetail.isHidden = true
        self.btnSubmit.layer.cornerRadius = 10.0
        self.viewAsteroidDetail.layer.cornerRadius = 10.0
        self.txtStartDate.setInputViewDatePicker(target: self, selector: #selector(selectStartDateClicked))
        self.txtEndDate.setInputViewDatePicker(target: self, selector: #selector(selectEndDateClicked))
        
        self.setChart(dataPoints: self.arrDate, values: self.arrAsteroidCountperDate)
    }
    
    
    //MARK:- *************** BUTTON ACTION ***************
    
    @objc func selectStartDateClicked() {

        if let datePicker = self.txtStartDate.inputView as? UIDatePicker {

            self.txtStartDate.text = dateFormatter.string(from: datePicker.date)
            self.startDate = datePicker.date
        }
        self.txtStartDate.resignFirstResponder()
    }

    @objc func selectEndDateClicked() {

        if let datePicker = self.txtEndDate.inputView as? UIDatePicker {
            
            self.txtEndDate.text = dateFormatter.string(from: datePicker.date)
            self.endDate = datePicker.date
        }
        self.txtEndDate.resignFirstResponder()
    }
    
    @IBAction func btnSubmitClicked(_ sender: UIButton) {
        
        if self.txtStartDate.text?.trim().count == 0
        {
            self.view.makeToast("Select Start Date")
        }
        else if self.txtEndDate.text?.trim().count == 0
        {
            self.view.makeToast("Select End Date")
        }
        else if endDate < startDate
        {
            self.view.makeToast("Select a date after the start date")
        }
        else if Calendar.current.numberOfDaysBetween(startDate, and: endDate) >= 8
        {
            self.view.makeToast("Select date range between one week")
        }
        else
        {
            self.view.hideAllToasts()
            self.callNeoFeedAPI()
        }
    }
    
    
    //MARK:- *************** API CALLING ***************

    
    fileprivate func callNeoFeedAPI() {
        
        if (utils.connected()) {
            
            hudProggess(self.view, Show: true)
            
            let webPath = "https://api.nasa.gov/neo/rest/v1/feed?start_date=\(self.txtStartDate.text ?? "")&end_date=\(self.txtEndDate.text ?? "")&api_key=DEMO_KEY"
            
            Alamofire.request(URL(string: webPath) ?? String(), method: .get, parameters: nil).responseJSON { (response) in
                
                if let responseData = response.data {
                    
                    do {
                        let decodeJson = JSONDecoder()
                        let objMain = try decodeJson.decode(ModelBaseFeed.self, from: responseData)
                        
                        guard let objEarthDics = objMain.nearEarthObjects else { return }
                        let sortedKeysAndValues = objEarthDics.sorted(by: { $0.0 < $1.0 })
                        
                        self.arrAllAeteroid.removeAll()
                        self.arrDate.removeAll()
                        self.arrAsteroidCountperDate.removeAll()
                        
                        for (key, value) in sortedKeysAndValues {
                            print("(\(key),\(value))")
                            
                            let arrTempAsteroid = value
                            arrTempAsteroid.forEach { objTempEarthObject in
                                self.arrAllAeteroid.append(objTempEarthObject)
                            }
                            
                            /// Chart Data
                            self.arrDate.append(key)
                            self.arrAsteroidCountperDate.append(Double(value.count))
                        }
                        
                        print("ALL ASTEROID COUNT == \(self.arrAllAeteroid.count)")
                        print(self.arrDate)
                        print(self.arrAsteroidCountperDate)
                        
                        /// Show  Data in Bar Chart
                        self.setChart(dataPoints: self.arrDate, values: self.arrAsteroidCountperDate)
                        
                        /// Get Speed of Fastest Asteroid
                        let fastestAsteroidSpeed = self.arrAllAeteroid.map { Double($0.closeApproachData?.first?.relativeVelocity?.kilometersPerHour ?? "0") ?? 0.0 }.sorted(by: { $0 > $1 }).first
                        
                        /// Get ID of Fastest Asteroid
                        let fastestAsteroidID = self.arrAllAeteroid.filter { Double($0.closeApproachData?.first?.relativeVelocity?.kilometersPerHour ?? "0") ?? 0.0 == fastestAsteroidSpeed }.first?.id ?? ""
                        
                        /// Get Distance of Closest Asteroid
                        let closestAsteroidDistance = self.arrAllAeteroid.map { Double($0.closeApproachData?.first?.missDistance?.kilometers ?? "0") ?? 0.0 }.sorted(by: { $0 > $1 }).last
                        
                        /// Get ID of Closest Asteroid
                        let closestAsteroidID = self.arrAllAeteroid.filter { Double($0.closeApproachData?.first?.missDistance?.kilometers ?? "0") ?? 0.0 == closestAsteroidDistance }.first?.id ?? ""
                        
                        /// Calculate average size of Asteroid
                        var arrAsteroidSize = [Double]()
                        self.arrAllAeteroid.forEach { tempAsteroidDetail in
                            let minDiameter = tempAsteroidDetail.estimatedDiameter?.kilometers?.estimatedDiameterMin ?? 0.0
                            let maxDiameter = tempAsteroidDetail.estimatedDiameter?.kilometers?.estimatedDiameterMax ?? 0.0
                            let sumOfDiameter = minDiameter + maxDiameter
                            print(sumOfDiameter)

                            arrAsteroidSize.append(sumOfDiameter)
                        }
                        
                        let averageSizeOfAsteroid = (arrAsteroidSize.reduce(0) { $0 + $1 }) / 2
                        print(averageSizeOfAsteroid)
                        
                        DispatchQueue.main.async {
                            self.lblFastestAsteroid.text = "Fastest Asteroid : \(fastestAsteroidID) & \(String(format: "%.2f", fastestAsteroidSpeed!)) km/h"
                            self.lblClosestAsteroid.text = "Closest Asteroid : \(closestAsteroidID) & \(String(format: "%.2f", closestAsteroidDistance!)) km"
                            self.lblAsteroidAverageSize.text = "Average Size of Asteroids : \(String(format: "%.2f", averageSizeOfAsteroid)) km"
                            
                            self.viewAsteroidDetail.isHidden = false
                        }
                        
                        hudProggess(self.view, Show: false)

                    } catch {

                        print(error)
                        hudProggess(self.view, Show: false)
                        self.presentAlertWithTitle(title: "Something went wrong, Try again later", message: "", options: "OK") { (option) in }
                    }
                }
                
            }
        }else{
            
            hudProggess(self.view, Show: false)
            self.presentAlertWithTitle(title: "Internet Connection", message: "Make sure your device is connected to the internet.", options: "OK") { (option) in }
        }
        
    }
    
    
    //MARK:- *************** Setup BarChart ***************
    
    func setChart(dataPoints: [String], values: [Double]) {
        
        chartView.noDataText = "No asteroids data available"
        
        var dataEntries: [BarChartDataEntry] = []
        
        for i in 0..<dataPoints.count {
            
            let dataEntry = BarChartDataEntry(x: Double(i), y: self.arrAsteroidCountperDate[i])
            dataEntries.append(dataEntry)
        }
        
        let chartDataSet = BarChartDataSet(entries: dataEntries, label: "Asteroid Chart")
        let dataSets: [BarChartDataSet] = [chartDataSet]
        chartDataSet.colors = [UIColor(red: 100/255, green: 181/255, blue: 246/255, alpha: 1)]
        //        chartDataSet.colors = [UIColor.green]
        //        chartDataSet.colors = ChartColorTemplates.colorful()
        let chartData = BarChartData(dataSets: dataSets)
        
        chartView.xAxis.labelPosition = .bottom
        chartView.xAxis.valueFormatter = IndexAxisValueFormatter(values: arrDate)
        chartView.xAxis.granularity = 1
        chartView.leftAxis.enabled = false
        chartView.rightAxis.enabled = false
//        chartView.doubleTapToZoomEnabled = false
//        chartView.setVisibleXRangeMaximum(30)
        chartView.data = chartData
        chartView.scaleYEnabled = false
        chartView.scaleXEnabled = true
        chartView.animate(xAxisDuration: 2.0, yAxisDuration: 2.0, easingOption: .easeInQuad)
    }
   
}
