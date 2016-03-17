//
//  MapViewController.swift
//  Milieu
//
//  Created by Xiaoxi Pang on 15/12/6.
//  Copyright © 2015 Atelier Ruderal. All rights reserved.
//

import Mapbox
import STPopup
import UIKit

class MapViewController: UIViewController{
    
    // View
    var map: MGLMapView!
    
    // CoreData
    var coreDataStack: CoreDataStack!
    var selectedNeighbour: Neighbourhood?
    var events: [EventInfo]!
    
    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet weak var locationMenuButton: UIBarButtonItem!
    
    // MARK: - View Controller Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        coreDataStack = CoreDataManager.sharedManager.coreDataStack
        linkMenuController()
        createMapView()
        
        
        // Add gesture to change the map style
        map.addGestureRecognizer(UILongPressGestureRecognizer(target: self,
            action: "changeStyle:"))
        
        events = EventInfo.loadAllEvents()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        displaySelectedNeighbour()
        populateAnnotations()
    }
    
    // MARK: - View Setup
    func linkMenuController(){
        // Link the menus
        if revealViewController() != nil{
            revealViewController().rearViewRevealWidth = 260
            locationMenuButton.target = revealViewController()
            locationMenuButton.action = "revealToggle:"
            
            revealViewController().rightViewRevealWidth = 220
            menuButton.target = revealViewController()
            menuButton.action = "rightRevealToggle:"
        }
    }
    
    // MARK: - Map View Setup
    func createMapView(){
        // Create the Map View
        map = MGLMapView(frame: view.bounds, styleURL: MGLStyle.lightStyleURL())
        map.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        
        settleUserLocation()
        view.addSubview(map)
        
        // Set Map Delegate
        map.delegate = self
    }
    
    func settleUserLocation(){
        map.showsUserLocation = true
        map.userTrackingMode = .Follow
    }
    

    func changeStyle(longPress: UILongPressGestureRecognizer) {
        if longPress.state == .Began {
            let styleURLs = [
                MGLStyle.lightStyleURL(),
                MGLStyle.streetsStyleURL(),
                MGLStyle.emeraldStyleURL(),
                MGLStyle.darkStyleURL(),
                MGLStyle.satelliteStyleURL(),
                MGLStyle.hybridStyleURL()
            ]
            var index = 0
            for styleURL in styleURLs {
                if map.styleURL == styleURL {
                    index = styleURLs.indexOf(styleURL)!
                }
            }
            if index == styleURLs.endIndex - 1 {
                index = styleURLs.startIndex
            } else {
                index = index.advancedBy(1)
            }
            map.styleURL = styleURLs[index]
        }
    }
    
    // MARK: - View Controller Logic
    
    func displaySelectedNeighbour(){
        
        // Try to find the neighbourhood bounds
        // Use the current one if those can't be found
        let bounds = NeighbourManager.findBoundsFromNeighbourhood(selectedNeighbour) ?? map.visibleCoordinateBounds

        map.setVisibleCoordinateBounds(bounds, edgePadding: UIEdgeInsetsMake(5.0, 10.0, 5.0, 10.0), animated: true)
    }
    
    func populateAnnotations(){
        if let neighbour = selectedNeighbour{
            var applicationInfos = [MilieuAnnotation]()
            
            for item in neighbour.devApps!{
                let app = item as! DevApp
                if let _ = app.addresses?.allObjects.first as? Address{
                    let appInfo = ApplicationInfo(devApp: app)
                    
                    
                    applicationInfos.append(appInfo)
                }
            }
            
            map.removeAnnotations(map.annotations ?? [MGLAnnotation]())
            map.showsUserLocation = true
            map.addAnnotations(applicationInfos)
        }
    }
    
    
}

// MARK: - MGLMapViewDelegate

extension MapViewController: MGLMapViewDelegate{
    
    func mapView(mapView: MGLMapView, imageForAnnotation annotation: MGLAnnotation) -> MGLAnnotationImage? {
        let annotation = annotation as! MilieuAnnotation
        // Make unique reusable identifier for one annotation type
        let identifier = annotation.category.rawValue
        
        var annotationImage = mapView.dequeueReusableAnnotationImageWithIdentifier(identifier)
        
        if annotationImage == nil{
            let image = UIImage(named: identifier)!
            annotationImage = MGLAnnotationImage(image: image, reuseIdentifier: identifier)
        }
        
        return annotationImage
    }
    
    func mapView(mapView: MGLMapView, didSelectAnnotation annotation: MGLAnnotation) {
        
        // Deselect the annotation so that it can be chosen again after dismissing the detail view controller
        mapView.deselectAnnotation(annotation, animated: false)
        
        if let annotation = annotation as? ApplicationInfo{
            
            // Create the ApplicationDetailViewController by storyboard
            let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("ApplicationDetailViewController") as? ApplicationDetailViewController
            
            // Set the annotation
            viewController?.annotation = annotation
            
            // Use the STPopupController to make the fancy view controller
            let popupController = STPopupController(rootViewController: viewController)
            popupController.containerView.layer.cornerRadius = 4
            
            // Show it on top of the map view
            popupController.presentInViewController(self)
        }
    }
}