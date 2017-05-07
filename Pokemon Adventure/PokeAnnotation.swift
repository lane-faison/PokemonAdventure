//
//  PokeAnnotation.swift
//  Pokemon Adventure
//
//  Created by Lane Faison on 5/7/17.
//  Copyright © 2017 RunningSocial. All rights reserved.
//

import UIKit
import MapKit

class PokeAnnotation : NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var pokemon: Pokemon
    
    init(coord: CLLocationCoordinate2D, pokemon: Pokemon) {
        self.coordinate = coord
        self.pokemon = pokemon
    }
}
