//
//  MapViewController.swift
//  final_project
//
//  Created by Yangjun Bie on 3/15/20.
//

/*
 - Attribution:
 http://brainwashinc.com/2017/07/21/loading-activity-indicator-ios-swift/
 https://www.raywenderlich.com/9009-requesting-app-ratings-and-reviews-tutorial-for-ios
 https://stackoverflow.com/questions/30743408/check-for-internet-connection-with-swift
 */

import UIKit
import MapKit
import CoreLocation
import StoreKit

enum AppStoreReviewManager {
  // 1.
  static let minimumReviewWorthyActionCount = 3

  static func requestReviewIfAppropriate() {
    let defaults = UserDefaults.standard
    let bundle = Bundle.main

    // 2.
    var actionCount = defaults.integer(forKey: "reviewWorthyActionCount")
    
    if actionCount == 0 {
        setFirstLaunchTime()
    }

    // 3.
    actionCount += 1

    // 4.
    defaults.set(actionCount, forKey: "reviewWorthyActionCount")

    // 5.
    guard actionCount >= minimumReviewWorthyActionCount else {
      return
    }

    // 6.
    let bundleVersionKey = kCFBundleVersionKey as String
    let currentVersion = bundle.object(forInfoDictionaryKey: bundleVersionKey) as? String
    let lastVersion = defaults.string(forKey: "lastReviewRequestAppVersion")

    // 7.
    guard lastVersion == nil || lastVersion != currentVersion else {
      return
    }

    // 8.
    SKStoreReviewController.requestReview()

    // 9.
    defaults.set(0, forKey: "reviewWorthyActionCount")
    defaults.set(currentVersion, forKey: "lastReviewRequestAppVersion")
  }
    
    static func setFirstLaunchTime() {
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy"
        let DateInFormat = formatter.string(from: date)
        
        UserDefaults.standard.set(DateInFormat, forKey: "first_launch")
    }

}

struct RestaurantInfo{
    var placeId: String?
    var name: String?
    var rating: Double?
    var userRatingsTotal: Int?
    var priceLevel: Int?
    var lat: Double?
    var lng: Double?
    var photos: [String]?
}

protocol SelectInfoDelegate: class {
    func passRestaurants(photsUrl: [url_id], restaurants: [Restaurant]) -> Void
}


class MapViewController: UIViewController {
    @IBOutlet var mapView: MKMapView!
    @IBOutlet var segmentedControl: UISegmentedControl!
    @IBOutlet var maxDis: UILabel!
    @IBOutlet var stepper: UIStepper!
    
    @IBOutlet weak var button: UIButton!
    var allRestaurants = [RestaurantInfo?]()
    
    @IBAction func distanceChanged(_ sender: UIStepper) {
        maxDis.text = "Within " + Int(sender.value).description + " minutes"
    }
    
    let locationManager = CLLocationManager()
    var currIndex: Int!
    var currDis: Int!

    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        AppStoreReviewManager.requestReviewIfAppropriate()

        // Request authorization
        locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
        }
        
        mapView.delegate = self
        mapView.mapType = .standard
        mapView.isZoomEnabled = true
        mapView.isScrollEnabled = true
        
        if let coor = mapView.userLocation.location?.coordinate{
            mapView.setCenter(coor, animated: true)
        }
        
    }
    
    
    @IBAction func buttonTapped(_ sender: Any) {
        
        // check for network connection
        if !Reachability.isConnectedToNetwork(){
            let alert = UIAlertController(title: "No Connnection", message: "Please check your network connection", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Got it", style: .cancel, handler: nil))
            self.present(alert, animated: true)
            return
        }
        
        self.showSpinner(onView: self.view)
        
        let curLocation = self.locationManager.location?.coordinate
        
        var radius = self.stepper.value
        let commuteChoice = self.segmentedControl.selectedSegmentIndex
        
        if commuteChoice == 0{
            radius *= 450
        }else if commuteChoice == 1{
            radius *= 160
        }else{
            radius *= 60
        }
        
        // limit max radius here to reduce api calls (due to current limited amount)
        if radius > 10000{
            radius = 10000.0
        }
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "selectViewController") as! selectViewController
        vc.modalPresentationStyle = .fullScreen
        vc.modalTransitionStyle = .crossDissolve
        // data fetch
        vc.restaurants = [Restaurant]()
        vc.urlArr = [url_id]()
        vc.scores = [Int]()
        var count = 0
        var total = 0;
        RestaurantLibrary.fetchReleases(lat: (Double)(curLocation!.latitude), lng: (Double)(curLocation!.longitude), radius: (Int)(radius)){ (releases, error) in
            guard let releases = releases, error == nil else {
                print(error!)
                return
            }
            for obj in releases.results!{
                var newPhotos = [String]()
                var newRest:RestaurantInfo = RestaurantInfo(placeId: nil, name: nil, rating: nil, userRatingsTotal: nil, priceLevel: nil, lat: nil, lng: nil, photos: newPhotos)
                newRest.placeId = obj.placeId
                newRest.name = obj.name
                newRest.lat = obj.geometry?.location?.lat
                newRest.lng = obj.geometry?.location?.lng
                newRest.rating = obj.rating
                newRest.priceLevel = obj.priceLevel
                newRest.userRatingsTotal = obj.userRatingsTotal
                total += 1
                
                vc.restaurants.append(obj)
                let url = "https://maps.googleapis.com/maps/api/place/details/json?place_id=" + newRest.placeId! + "&fields=photo&key=yourkey"
                
                var onePic = url_id()
                onePic.restaurantID = total - 1
                
                RestaurantLibrary.fetchPictureList(url:url){ (releases, error) in
                    guard let releases = releases, error == nil else {
                        print(error!)
                        return
                    }
                    for photo in (releases.result?.photos)!{
                        newPhotos.append(RestaurantLibrary.fetchSinglePicture(photoRef: photo.photoReference!))
                        onePic.photoURL = RestaurantLibrary.fetchSinglePicture(photoRef: photo.photoReference!)
        
                    }
                    vc.urlArr.append(onePic)
                    newRest.photos = newPhotos
                    self.allRestaurants.append(newRest)
                    count += 1
                    if(count == total){
                        self.removeSpinner()
                        self.present(vc, animated: true, completion: nil)
                    }
                }
            }
        }
    }
}



//MapViewController Delegate
extension MapViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager,
                         didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
            print("Authorized!")
        case .notDetermined:
            print("We need to request authorization")
        default:
            print("Not authorized :(")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let locValue:CLLocationCoordinate2D = manager.location!.coordinate

        mapView.mapType = MKMapType.standard

        let span = MKCoordinateSpan(latitudeDelta: 0.002, longitudeDelta: 0.002)
        let region = MKCoordinateRegion(center: locValue, span: span)
        mapView.setRegion(region, animated: true)

        let annotation = MKPointAnnotation()
        annotation.coordinate = locValue
        annotation.title = "Current location"
        mapView.addAnnotation(annotation)
    }
}

//MapView Delegate
extension MapViewController: MKMapViewDelegate {
   
}


// network activity indicator
var vSpinner : UIView?
 
extension UIViewController {
    func showSpinner(onView : UIView) {
        let spinnerView = UIView.init(frame: onView.bounds)
        spinnerView.backgroundColor = UIColor.init(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.5)
        let ai = UIActivityIndicatorView.init(style: .large)
        ai.startAnimating()
        ai.center = spinnerView.center
        
        DispatchQueue.main.async {
            spinnerView.addSubview(ai)
            onView.addSubview(spinnerView)
        }
        
        vSpinner = spinnerView
    }
    
    func removeSpinner() {
        DispatchQueue.main.async {
            vSpinner?.removeFromSuperview()
            vSpinner = nil
        }
    }
}
