//
//  CustomInfoWindowDataSource.swift
//  PetDetective
//
//  Created by Junseo Park on 2022/04/16.
//

import UIKit
import NMapsMap

class CustomInfoWindowDataSource: NSObject, NMFOverlayImageDataSource {
    var markerInfoView = MarkerInfoView()
    
    func view(with overlay: NMFOverlay) -> UIView {
        print("IN view")

        guard let infoWindow = overlay as? NMFInfoWindow else { return markerInfoView }
        
        print("InfoWindow")
//        rootView.textLabel.text = infoWindow.marker?.userInfo["MarkerInfo"] as? MarkerInfo
//        guard let infoWindow = overlay as? NMFInfoWindow else { return markInfoView }
//
//        if infoWindow.marker != nil {
//            markInfoView.goldenTimeLabel.text = infoWindow.missingTime
//            markInfoView.moneyLabel.text = "\(infoWindow.money)"
//            rootView.iconView.image = UIImage(named: "baseline_room_black_24pt")
//            rootView.textLabel.text = infoWindow.marker?.userInfo["title"] as? String
//        }
//
//        markInfoView.goldenTimeLabel.text = infoWindow.marker?.userInfo["MarkerInfo"] as! MarkerInfo
//
//        print(<#T##items: Any...##Any#>)
        
        let markerInfo = infoWindow.marker?.userInfo["MarkerInfo"] as! MarkerInfo
        
        print("markerInfo")
        markerInfoView.goldenTimeLabel.text = markerInfo.missingTime
        markerInfoView.moneyLabel.text = "\(markerInfo.money)"
        
        print(markerInfo.missingTime)
        print(markerInfo.money)
        
        print(markerInfoView)
        
        markerInfoView.frame = CGRect(x: 0, y: 0, width: 200, height: 200)

        markerInfoView.layoutIfNeeded()
        return markerInfoView
    }
    
   
}

//func view(with overlay: NMFOverlay) -> UIView {
//    print("IN view")
//    let markInfoView = MarkerInfoView()
//    let markerInfo = overlay.userInfo["MarkerInfo"] as! MarkerInfo
//    markInfoView.goldenTimeLabel.text = markerInfo.missingTime
//    markInfoView.moneyLabel.text = "\(markerInfo.money)"
//
//    print(markerInfo.missingTime)
//    print(markerInfo.money)
//
//    print(markInfoView)
//    return markInfoView
//}
