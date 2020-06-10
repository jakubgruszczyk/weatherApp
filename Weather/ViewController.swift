//
//  ViewController.swift
//  Weather
//
//  Created by Jakub Gruszczyk on 09/06/2020.
//  Copyright © 2020 Jakub Gruszczyk. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import SwiftyJSON
import NVActivityIndicatorView
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {

    @IBOutlet weak var unitLabel: UILabel!
    @IBOutlet weak var localizationType: UITextField!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var dayLabel: UILabel!
    
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var pressureLabel: UILabel!
    @IBOutlet weak var sunsetLabel: UILabel!
    @IBOutlet weak var sunriseLabel: UILabel!
    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var windLabel: UILabel!
    @IBOutlet weak var humanityLabel: UILabel!
    @IBOutlet weak var conditionImageView: UIImageView!
    @IBOutlet weak var conditionLabel: UILabel!
    
    @IBOutlet weak var temperatureLabel: UILabel!
    
    
    let gradientLayer = CAGradientLayer()
    
    let apiKey = "8c1e240150949fb7bfe0bf0503c8a20e"
    var lat = 11.344533
    var lon = 104.33322
    var activityIndicator: NVActivityIndicatorView!
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTextFields()
        
    
        let indicatorSize: CGFloat = 70
        let indicatorFrame = CGRect(x: (view.frame.width-indicatorSize)/2, y: (view.frame.height-indicatorSize)/2, width: indicatorSize, height: indicatorSize)
        activityIndicator = NVActivityIndicatorView(frame: indicatorFrame, type: .lineScale, color: UIColor.white, padding: 20.0)
        activityIndicator.backgroundColor = UIColor.black
        view.addSubview(activityIndicator)
        
        locationManager.requestWhenInUseAuthorization()
        
        activityIndicator.startAnimating()
        if(CLLocationManager.locationServicesEnabled()){
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
        }
        
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        self.backgroundImage.image = UIImage(named:"4.png")
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[0]
        

        lat =  location.coordinate.latitude
        lon =  location.coordinate.longitude
       
    
        
        Alamofire.request("http://api.openweathermap.org/data/2.5/weather?lat=\(lat)&lon=\(lon)&appid=\(apiKey)&units=metric").responseJSON {
            response in
            self.activityIndicator.stopAnimating()
            if let responseStr = response.result.value {
                let jsonResponse = JSON(responseStr)
                let jsonWeather = jsonResponse["weather"].array![0]
                let jsonTemp = jsonResponse["main"]
                let jsonWind = jsonResponse["wind"]
                let jsonSys = jsonResponse["sys"]
                let iconName = jsonWeather["icon"].stringValue
                
                
                self.locationLabel.text = jsonResponse["name"].stringValue
                self.conditionImageView.image = UIImage(named: iconName)
                self.conditionLabel.text = jsonWeather["main"].stringValue
                self.temperatureLabel.text = "\(Int(round(jsonTemp["temp"].doubleValue)))"
                
                self.humanityLabel.text = jsonTemp["humidity"].stringValue + "%"
                self.windLabel.text = jsonWind["speed"].stringValue + "m/s"
                self.pressureLabel.text = jsonTemp["pressure"].stringValue + "hPa"
                
                self.localizationType.isEnabled = true
                self.conditionImageView.isHidden = false
                self.unitLabel.isHidden = false
                self.temperatureLabel.isHidden = false
                self.conditionLabel.isHidden = false
                
                let date = Date()
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "EEEE"
                self.dayLabel.text = dateFormatter.string(from: date)
                
                let dataSunrise = jsonSys["sunrise"].doubleValue
                let sunrsiseFormated = Date(timeIntervalSince1970: dataSunrise)
                
                dateFormatter.dateFormat = "HH:mm"
                self.sunriseLabel.text = dateFormatter.string(from: sunrsiseFormated)
                
                
                let dataSunset = jsonSys["sunset"].doubleValue
                let sunsetFormated = Date(timeIntervalSince1970: dataSunset)
                
                dateFormatter.dateFormat = "HH:mm"
                self.sunsetLabel.text = dateFormatter.string(from: sunsetFormated)
                let suffix = iconName.suffix(1)
                if(suffix == "n"){
                    self.backgroundImage.image = UIImage(named:"1.png")
                }else{
                    if(self.conditionLabel.text! == "Clear"){
                        self.backgroundImage.image = UIImage(named:"3.png")
                    }else if(self.conditionLabel.text! == "Rain"){
                        self.backgroundImage.image = UIImage(named:"2.png")
                    }else{
                        self.backgroundImage.image = UIImage(named:"4.png")
                        }}
            }
        }
        self.locationManager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
    
    @IBAction func getLocalization(_ sender: Any) {
        
        self.errorLabel.isHidden = true
        
        let indicatorSize: CGFloat = 70
            let indicatorFrame = CGRect(x: (view.frame.width-indicatorSize)/2, y: (view.frame.height-indicatorSize)/2, width: indicatorSize, height: indicatorSize)
            activityIndicator = NVActivityIndicatorView(frame: indicatorFrame, type: .lineScale, color: UIColor.white, padding: 20.0)
            activityIndicator.backgroundColor = UIColor.black
            view.addSubview(activityIndicator)
            
            locationManager.requestWhenInUseAuthorization()
            
            activityIndicator.startAnimating()
            if(CLLocationManager.locationServicesEnabled()){
                locationManager.delegate = self
                locationManager.desiredAccuracy = kCLLocationAccuracyBest
                locationManager.startUpdatingLocation()
            }
            
        
    }
    private func configureTextFields(){
        localizationType.delegate = self
    }
    
}

extension ViewController : UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        let cityName = localizationType.text!
        
        self.localizationType.text = ""
        
        let url = "http://api.openweathermap.org/data/2.5/weather?q=\(cityName)&appid=\(apiKey)&units=metric"
        
        Alamofire.request(url).responseJSON {
            response in
            self.activityIndicator.stopAnimating()
            if let responseStr = response.result.value {
                let jsonResponse = JSON(responseStr)
                let jsonCod = jsonResponse["cod"].stringValue
                print(jsonCod)
                if(jsonCod == "200"){
                
                self.errorLabel.isHidden = true
                
                let jsonWeather = jsonResponse["weather"].array![0]
                let jsonTemp = jsonResponse["main"]
                let jsonWind = jsonResponse["wind"]
                let jsonSys = jsonResponse["sys"]
                let iconName = jsonWeather["icon"].stringValue
                
                self.locationLabel.text = jsonResponse["name"].stringValue
                self.conditionImageView.image = UIImage(named: iconName)
                self.conditionLabel.text = jsonWeather["main"].stringValue
                self.temperatureLabel.text = "\(Int(round(jsonTemp["temp"].doubleValue)))"
                
                self.humanityLabel.text = jsonTemp["humidity"].stringValue + "%"
                self.windLabel.text = jsonWind["speed"].stringValue + "m/s"
                self.pressureLabel.text = jsonTemp["pressure"].stringValue + "hPa"
                
                
                let date = Date()
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "EEEE"
                self.dayLabel.text = dateFormatter.string(from: date)
                
                let dataSunrise = jsonSys["sunrise"].doubleValue
                let sunrsiseFormated = Date(timeIntervalSince1970: dataSunrise)
                dateFormatter.dateFormat = "HH:mm"
                self.sunriseLabel.text = dateFormatter.string(from: sunrsiseFormated)
                
                
                let dataSunset = jsonSys["sunset"].doubleValue
                let sunsetFormated = Date(timeIntervalSince1970: dataSunset)
                dateFormatter.dateFormat = "HH:mm"
                self.sunsetLabel.text = dateFormatter.string(from: sunsetFormated)
                
                let suffix = iconName.suffix(1)
                if(suffix == "n"){
                    self.backgroundImage.image = UIImage(named:"1.png")
                }else{
                    
                    if(jsonWeather["main"].stringValue == "Clear"){
                        self.backgroundImage.image = UIImage(named:"3.png")
                    }else if(jsonWeather["main"].stringValue == "Rain"){
                        self.backgroundImage.image = UIImage(named:"2.png")
                    }else{
                    self.backgroundImage.image = UIImage(named:"4.png")
                    }}
                    
                    
            }else{
                self.errorLabel.isHidden = false
            }
        }}
        textField.resignFirstResponder()
        
        return true
    }
}
