//
//  GeotagMapViewController.swift
//  LambdaTimeline
//
//  Created by De MicheliStefano on 18.10.18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import UIKit
import MapKit

class GeotagMapViewController: UIViewController, MKMapViewDelegate, LambdaTimelineDelegate {

    // MARK: - Properties
    
    var postController: PostController!
    var geotaggedPosts: [Post] {
        return postController.posts.filter { $0.geotag != nil }
    }
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.mapView.register(MKMarkerAnnotationView.self, forAnnotationViewWithReuseIdentifier: "GeotagAnnotation")
        self.mapView.addAnnotations(geotaggedPosts)
    }
    
    // MARK: - MKMapViewDelegate
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard let post = annotation as? Post else { return nil }
        
        let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "GeotagAnnotation", for: post) as! MKMarkerAnnotationView
        annotationView.markerTintColor = .red
        
        annotationView.canShowCallout = true
        
        
        // annotationView.detailCalloutAccessoryView = detailView
        
        return annotationView
    }

}
