//
//  ViewController.swift
//  Pokemon Adventure
//
//  Created by Lane Faison on 5/6/17.
//  Copyright © 2017 RunningSocial. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    
    var manager = CLLocationManager() // This is used to ask user for permission to use location
    
    var updateCount = 0
    
    var pokemons : [Pokemon] = [] // Creates an empty array of type Pokemon
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        pokemons = getAllPokemon()
        
        manager.delegate = self
        
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            setUp()
        } else {
            manager.requestWhenInUseAuthorization()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            setUp()
        }
    }
    
    func setUp() {
        mapView.delegate = self
        mapView.showsUserLocation = true
        manager.startUpdatingLocation()
        
        Timer.scheduledTimer(withTimeInterval: 5, repeats: true
            , block: {(timer) in
                // Spawn new Pokemon every 5 seconds
                
                if let coord = self.manager.location?.coordinate {
                    let pokemon = self.pokemons[Int(arc4random_uniform(UInt32(self.pokemons.count)))]
                    let annotation = PokeAnnotation(coord: coord, pokemon: pokemon)
                    
                    // Create some randomization with the coordinate of new Pokemon
                    let randomLat = (Double(arc4random_uniform(200)) - 100) / 50000.0
                    let randomLng = (Double(arc4random_uniform(200)) - 100) / 50000.0
                    
                    annotation.coordinate.latitude += randomLat
                    annotation.coordinate.longitude += randomLng
                    self.mapView.addAnnotation(annotation)
                }
        })
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if annotation is MKUserLocation {
            let annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: nil)
            annotationView.image = UIImage(named: "player")
            var frame = annotationView.frame // Can set height and width using frame
            frame.size.height = 50
            frame.size.width = 50
            annotationView.frame = frame
            return annotationView
        }
        
        let annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: nil)
        let pokemon = (annotation as! PokeAnnotation).pokemon
        annotationView.image = UIImage(named: pokemon.imageName!)
        var frame = annotationView.frame // Can set height and width using frame
        frame.size.height = 50
        frame.size.width = 50
        annotationView.frame = frame
        return annotationView
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if updateCount < 3 {
            let region = MKCoordinateRegionMakeWithDistance(manager.location!.coordinate, 200, 200)
            mapView.setRegion(region, animated: false) // Put true if you want to see maps zooming in
            updateCount += 1
        } else {
            manager.stopUpdatingHeading()
        }
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        mapView.deselectAnnotation(view.annotation!, animated: true)
        
        if view.annotation! is MKUserLocation {
            return
        }
        let region = MKCoordinateRegionMakeWithDistance(view.annotation!.coordinate, 200, 200)
        mapView.setRegion(region, animated: true)
        
        Timer.scheduledTimer(withTimeInterval: 1, repeats: false, block: {(timer) in
            // this function can determine if two points are visible on the screen at the same time
            if let coord = self.manager.location?.coordinate {
                let pokemon = (view.annotation as! PokeAnnotation).pokemon
                
                if MKMapRectContainsPoint(mapView.visibleMapRect, MKMapPointForCoordinate(coord)) {
                    pokemon.caught = true
                    (UIApplication.shared.delegate as! AppDelegate).saveContext()
                    
                    // remove pokemon from view after being caught
                    mapView.removeAnnotation(view.annotation!)
                    
                    let alertVC = UIAlertController(title: "Congrats!", message: "YOu caught a \(pokemon.name)! You are a Pokemon master!", preferredStyle: .alert)
                    
                    let pokedexAction = UIAlertAction(title: "Pokedex", style: .default, handler: { (action) in
                        self.performSegue(withIdentifier: "pedexSegue", sender: nil)
                    })
                    alertVC.addAction(pokedexAction)
                    
                    let OKaction = UIAlertAction(title: "Ok", style: .default, handler: nil)
                    alertVC.addAction(OKaction)
                    self.present(alertVC, animated: true, completion: nil)
                    
                } else {
                    let alertVC = UIAlertController(title: "Uh-oh!", message: "YOu are too far away to catch the \(pokemon.name). Move closer to it!", preferredStyle: .alert)
                    let OKaction = UIAlertAction(title: "Ok", style: .default, handler: nil)
                    alertVC.addAction(OKaction)
                    self.present(alertVC, animated: true, completion: nil)
                }
            }
        })
    }
    
    @IBAction func centerTapped(_ sender: Any) {
        
        if let coord = manager.location?.coordinate {
            let region = MKCoordinateRegionMakeWithDistance(coord, 200, 200)
            mapView.setRegion(region, animated: true)
        }
    }
    
    
}

