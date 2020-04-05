//
//  resultViewController.swift
//  final_project
//
//  Created by Yangjun Bie on 3/17/20.
//

import UIKit
import MapKit
import CoreLocation

class resultViewController: UIViewController {
    @IBOutlet var titles: [UILabel]!
    @IBOutlet var rates: [UILabel]!
    @IBOutlet var prices: [UILabel]!
    
    @IBOutlet var mapView: MKMapView!
    
    @IBOutlet var view0: UIView!
    @IBOutlet var view1: UIView!
    @IBOutlet var view2: UIView!
    
    var finalResults = [Restaurant]()
    let locationManager = CLLocationManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        mapView.mapType = .standard
        mapView.isZoomEnabled = true
        mapView.isScrollEnabled = true
        
        var maxLatitude: Double = (finalResults[0].geometry?.location?.lat)!
        var minLatitude: Double = (finalResults[0].geometry?.location?.lat)!
        var maxLongitude: Double = (finalResults[0].geometry?.location?.lng)!
        var minLongitude: Double = (finalResults[0].geometry?.location?.lng)!

        for i in 0...2 {
            titles[i].text = finalResults[i].name
            rates[i].text = String(format:"%.1f", finalResults[i].rating ?? 0)
            prices[i].text = String(finalResults[i].priceLevel ?? 0)
            
            maxLatitude = Double.maximum((finalResults[i].geometry?.location?.lat)!, maxLatitude)
            minLatitude = Double.minimum((finalResults[i].geometry?.location?.lat)!, minLatitude)
            maxLongitude = Double.maximum((finalResults[i].geometry?.location?.lng)!, maxLongitude)
            minLongitude = Double.minimum((finalResults[i].geometry?.location?.lng)!, minLongitude)
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = CLLocationCoordinate2DMake((finalResults[i].geometry?.location?.lat!)!, (finalResults[i].geometry?.location?.lng!)!)
            annotation.title = finalResults[i].name
            mapView.addAnnotation(annotation)
        }
        
        var region = MKCoordinateRegion()
        region.center.latitude = (minLatitude + maxLatitude) / 2
        region.center.longitude = (minLongitude + maxLongitude) / 2
        region.span.latitudeDelta = (maxLatitude - minLatitude) * 1.1
        region.span.latitudeDelta = (region.span.latitudeDelta < 0.01)
            ? 0.01
            : region.span.latitudeDelta
        region.span.longitudeDelta = (maxLongitude - minLongitude) * 1.1
        
        mapView.setRegion(region, animated: true)
        
        view0.isUserInteractionEnabled = true
        view1.isUserInteractionEnabled = true
        view2.isUserInteractionEnabled = true
        
        let gesture0:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(viewTapped0(_:)))
        let gesture1:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(viewTapped1(_:)))
        let gesture2:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(viewTapped2(_:)))
        
        gesture0.numberOfTapsRequired = 1
        gesture1.numberOfTapsRequired = 1
        gesture2.numberOfTapsRequired = 1
        
        view0.addGestureRecognizer(gesture0)
        view1.addGestureRecognizer(gesture1)
        view2.addGestureRecognizer(gesture2)
        
    }
    
    @objc func viewTapped0(_ view: UIView) {
        let span = MKCoordinateSpan(latitudeDelta: 0.002, longitudeDelta: 0.002)
        var region = MKCoordinateRegion()
        region.center.latitude = (finalResults[0].geometry?.location?.lat)!
        region.center.longitude = (finalResults[0].geometry?.location?.lng)!
        region.span = span
        mapView.setRegion(region, animated: true)
    }
    
    @objc func viewTapped1(_ view: UIView) {
        let span = MKCoordinateSpan(latitudeDelta: 0.002, longitudeDelta: 0.002)
        var region = MKCoordinateRegion()
        region.center.latitude = (finalResults[1].geometry?.location?.lat)!
        region.center.longitude = (finalResults[1].geometry?.location?.lng)!
        region.span = span
        mapView.setRegion(region, animated: true)
    }
    
    @objc func viewTapped2(_ view: UIView) {
        let span = MKCoordinateSpan(latitudeDelta: 0.002, longitudeDelta: 0.002)
        var region = MKCoordinateRegion()
        region.center.latitude = (finalResults[2].geometry?.location?.lat)!
        region.center.longitude = (finalResults[2].geometry?.location?.lng)!
        region.span = span
        mapView.setRegion(region, animated: true)
    }
    
    @IBAction func buttonTapped(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "mapViewController") as! MapViewController
        vc.modalPresentationStyle = .fullScreen
        vc.modalTransitionStyle = .crossDissolve
        
        self.present(vc, animated: true, completion: nil)
    }
    

}

//MapViewController Delegate
extension resultViewController: CLLocationManagerDelegate {

}

//MapView Delegate
extension resultViewController: MKMapViewDelegate {

}
