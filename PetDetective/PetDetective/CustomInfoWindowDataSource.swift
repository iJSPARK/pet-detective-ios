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
        
        markerInfoView.frame = CGRect(x: 0, y: 0, width: 180, height: 100)

        markerInfoView.layoutIfNeeded()
        return markerInfoView
    }
    
    
//    func timerRun() {
//        if let timer = mTimer {
//            //timer 객체가 nil 이 아닌경우에는 invalid 상태에만 시작한다
//            if !timer.isValid {
//                /** 1초마다 timerCallback함수를 호출하는 타이머 */
//                mTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(timerCallback), userInfo: nil, repeats: true)
//            }
//        } else {
//            //timer 객체가 nil 인 경우에 객체를 생성하고 타이머를 시작한다
//            /** 1초마다 timerCallback함수를 호출하는 타이머 */
//            mTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(timerCallback), userInfo: nil, repeats: true)
//        }
//    }
//
 
   
}


