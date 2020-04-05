//
//  DataManager.swift
//  final_project
//
//  Created by sinze vivens on 2020/3/14.
//

import Foundation

struct RestaurantList: Codable {
    var results: [Restaurant]?
}

struct Restaurant : Codable{
    let placeId: String?
    let name: String?
    let rating: Double?
    let userRatingsTotal: Int?
    let priceLevel: Int?
    let geometry: Geometry?
}

struct Geometry: Codable{
    let location: Location?
}

struct Location: Codable{
    let lat: Double?
    let lng: Double?
}

struct PhotoList: Codable{
    let result: PhotoContainer?
}

struct PhotoContainer: Codable{
    let photos: [Photo]?
}

struct Photo: Codable{
    let width: Int?
    let photoReference: String?
}

class RestaurantLibrary{
    
    
    static func fetchPictureList(url: String, completion: @escaping (PhotoList?, Error?) -> Void){
        let urlString = url
         
         guard let url = URL(string: urlString) else {
           fatalError("Unable to create NSURL from string")
         }
         let task = URLSession.shared.dataTask(with: url, completionHandler:  { data, _, error in

             guard let data = data, error == nil else {
                 DispatchQueue.main.async { completion(nil, error) }
                 return
             }
             do {
                 let decoder = JSONDecoder()
                 decoder.keyDecodingStrategy = .convertFromSnakeCase
                 let releases = try decoder.decode(PhotoList.self, from: data)
                 DispatchQueue.main.async { completion(releases, nil) }
                
                for photo in (releases.result?.photos)!{
                    if photo.width! > 1000{
                        _ = fetchSinglePicture(photoRef: photo.photoReference!)
                        
                    }
                }
                 
             } catch (let parsingError) {
                 DispatchQueue.main.async { completion(nil, parsingError) }
                 completion(nil, parsingError)
             }
         })
         //start the task
         task.resume()
    }
    
    static func fetchSinglePicture(photoRef: String) -> String{
        
        let url = "https://maps.googleapis.com/maps/api/place/photo?maxwidth=1000&photoreference=" + photoRef + "&key=yourkey"
        
        return url
    }
    
    static func fetchReleases(lat: Double, lng: Double, radius: Int, completion: @escaping (RestaurantList?, Error?) -> Void) {
        
            
        let urlString = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=" + String(format: "%.7f", lat) + "," + String(format:"%.7f", lng) + "&radius=" + String(radius) + "&type=restaurant&keyword=cruise&key=yourkey"
            
           
            guard let url = URL(string: urlString) else {
              fatalError("Unable to create NSURL from string")
            }
            let task = URLSession.shared.dataTask(with: url, completionHandler:  { data, _, error in

                guard let data = data, error == nil else {
                    DispatchQueue.main.async { completion(nil, error) }
                    return
                }
                do {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    let releases = try decoder.decode(RestaurantList.self, from: data)
                    DispatchQueue.main.async { completion(releases, nil) }
                    
                } catch (let parsingError) {
                    DispatchQueue.main.async { completion(nil, parsingError) }
                    completion(nil, parsingError)
                }
            })
            //start the task
            task.resume()
        }
}




