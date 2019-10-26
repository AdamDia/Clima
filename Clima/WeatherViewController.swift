//
//  ViewController.swift
//  WeatherApp
//
//  Created by Angela Yu on 23/08/2015.
//  Copyright (c) 2015 London App Brewery. All rights reserved.
//

import UIKit
import CoreLocation
import Alamofire //used to make http requests
import SwiftyJSON

//this means that WeatherViewController is subcalss of UIViewController and it confroms to the rules of the call location (location manager Delegate)
//delegate tm tfwed our weatherView here ll qyam bel 7agat ely hygbha men CLLocationManager Class

class WeatherViewController: UIViewController, CLLocationManagerDelegate, ChangeCityDelegate {
    
    
    
    
    //Constants
    let WEATHER_URL = "http://api.openweathermap.org/data/2.5/weather"
    let APP_ID = "9816804fcbbf5718a1da7d67efd3047e"
    /***Get your own App ID at https://openweathermap.org/appid ****/
    

    //TODO: Declare instance variables here
    let locationManager = CLLocationManager()
    let weatherDataModel = WeatherDataModel()
    
    
    //Pre-linked IBOutlets
    @IBOutlet weak var weatherIcon: UIImageView!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //TODO:Set up the location manager here.
        //self here refer to our current class which is the weatherViewController
        //here we are setting the WeatherViewController as the delegate of the locationManager ely howa ana saweto fo2 bel CLLocationManager() class so the locationManager knows who to report to once it founds the location data that's we are loking for
        locationManager.delegate =  self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters // why this they found that HundredMeters works best with this weather APIs
        //to ask the user for the permession to use the location
        locationManager.requestWhenInUseAuthorization() // this is best not always Auth dont make the user feel that the app is spying on him
        // to grab the user's location and start to use it
        locationManager.startUpdatingLocation() //called Asynchronous Method which means that it works in the background to try and grab the GPS location coordinates if it worked in the foreground i.e if it was on what we called the main thread then it would freeze up the entire app you won't be able to interact with it until it's done looking for the GPS location.
        
//      locationManager.delegate = nil [this will remove our current class from receiving messages from the location manager while it's in the process of being stopped] if u find the JSON has been printed several times
        
    }
    
    
    
    //MARK: - Networking
    /***************************************************************/
    
    //Write the getWeatherData method here:
    
    func getWeatherData(url: String, parameters: [String: String]) {
        
        //this is a ready code and it's an Asynchronous Method also
        Alamofire.request(url, method: .get, parameters: parameters).responseJSON {
            response in
            if response.result.isSuccess {
                print("Sucess! Got it")
                
                //parsing the JSON
                let weatherJSON : JSON = JSON(response.result.value!) //we have to convert the value because its type is Any and we need it to be JSON
                print(weatherJSON)
                self.updateWeatherData(json: weatherJSON)
            }
            else {
                print("Error \(response.result.error)")
                self.cityLabel.text = "Connection Issues"
            }
        }
    }
    
    
    
    
    
    //MARK: - JSON Parsing
    /***************************************************************/
   
    
    //Write the updateWeatherData method here:
    func updateWeatherData(json : JSON) {

        if let temResult = json["main"]["temp"].double {//to parse easy in JSONs you have to import swiftyJSON it helps alot
            
        //kan mmken hena m3ml4 if let bas dah mesh hykon save 34an ana kont h3ml temResult! w dah mesh save 5ales l2no efrd l2y sabb men el asbab el data mrg3t4 sa7 el app hy7slo crash
            
        weatherDataModel.temperature = Int(temResult - 273.15) //to convert from kalvin to celisum degree
        weatherDataModel.city = json["name"].stringValue
        weatherDataModel.condition = json["weather"][0]["id"].intValue
        weatherDataModel.weatherIconName = weatherDataModel.updateWeatherIcon(condition: weatherDataModel.condition)
            
        updateUIWithWeatherData()
     }
        else {
            cityLabel.text = "Weather Unavailble"
        }

    }
    
    
    //MARK: - UI Updates
    /***************************************************************/
    
    
    //Write the updateUIWithWeatherData method here:
    func updateUIWithWeatherData() {
        
        cityLabel.text = weatherDataModel.city
        temperatureLabel.text = "\(weatherDataModel.temperature)°"
        weatherIcon.image = UIImage(named: weatherDataModel.weatherIconName)
    }
    
    
    
    
    
    //MARK: - Location Manager Delegate Methods
    /***************************************************************/
    
    
    //Write the didUpdateLocations method here:
    
    
    //telling the delegate that new location data is available
    //m3na keda el funtion deh htb3t ll delegate ely howa hena el weatherViewController 34an e7na 5alinah howa el delegate fo2 t2olo eno el location 7slo update
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        // lma bnady el function el fel viewDidLoad ely hya locationManager.startUpdatingLocation() btbd2 tgma3 several location and put them into an array called locations fa na akeed el most accurate one hykon a5er location el function gabto yb2a na dah ely yhmni so (count - 1) 34an el count bybd2 men 1 w el array be count men zero fna keda gebt a5er element fel array
        
        let location = locations[locations.count - 1] //the last location in locations Array
        if location.horizontalAccuracy > 0 {
            locationManager.stopUpdatingLocation()
            
//            print("longitude = \(location.coordinate.longitude), latitude = \(location.coordinate.latitude)")
            
            let latitude = "\(location.coordinate.latitude)"
            let longitude = String(location.coordinate.longitude)
            
            let params : [String : String] = ["lat" : latitude, "lon" : longitude, "appid" : APP_ID]
            
            getWeatherData(url: WEATHER_URL, parameters: params)
        }
    }
    
    
    //Write the didFailWithError method here:
    
    
    //lo 7asal ay error 5alani mesh 3aref ageb el GPS location
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
        cityLabel.text = "Location Unavailable"
    }
    
    

    
    //MARK: - Change City Delegate methods
    /***************************************************************/
    
    
    //Write the userEnteredANewCityName Delegate method here:
    func userEnteredANewCityName(city: String) {
        
        //leh q : city el documentation bta3t el weather hya ely bt2ol smeha keda
        let params : [String : String] = ["q" : city, "appid" : APP_ID]
        getWeatherData(url: WEATHER_URL, parameters: params)
    }

    
    //Write the PrepareForSegue Method here
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "changeCityName" {
            
            let destinationVC = segue.destination as! ChangeCityViewController
            destinationVC.delegate = self
        }
    }
    
    
    
}


