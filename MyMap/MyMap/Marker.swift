//
//  Marker.swift
//  MyMap
//
//  Created by 김하은 on 2022/07/16.
//

import Foundation
import MapKit

class Marker: NSObject, MKAnnotation {
    let title: String?
    let subtitle: String?
    var coordinate: CLLocationCoordinate2D
    
    init(title: String?, subtitle: String?, coordinate: CLLocationCoordinate2D) {
        self.title = title
        self.subtitle = subtitle
        self.coordinate = coordinate
        
        super.init()
    }
}
