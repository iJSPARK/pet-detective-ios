//
//  ReportViewController.swift
//  PetDetective
//
//  Created by Junseo Park on 3/19/22.
//

import UIKit
import NMapsMap
import CoreLocation

class EmergencyRescueViewController: UIViewController, CLLocationManagerDelegate {
    
    var locationManager = CLLocationManager()   // 위치 객체
    // var currentCoordinate = CLLocationCoordinate2D() //  좌표 객체
    
    @IBOutlet weak var mapView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // 델리게이트 설정
        locationManager.delegate = self
        
        // 거리 정확도 설정
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        // 위치 권한 요청
        locationManager.requestAlwaysAuthorization()
        
        let naverMap = NMFMapView(frame: mapView.frame)
        mapView.addSubview(naverMap)
  
        // 아이폰 설정에서의 위치 서비스가 켜진 상태라면
        if CLLocationManager.locationServicesEnabled() {
            print("위치 서비스 On 상태")
            
            naverMap.positionMode = .direction
            
            locationManager.startUpdatingLocation() //위치 정보 받아오기 시작
            
            // 오버레이 활성화
            let locationOverlay = naverMap.locationOverlay
            locationOverlay.hidden = false
            
        } else {
            print("위치 서비스 Off 상태")
        }
        
    }
        
    // 위치 정보 계속 업데이트 -> 위도 경도 받아옴
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("didUpdateLocations")
        if let location = locations.first {
            let latitude = location.coordinate.latitude
            let longtitude = location.coordinate.longitude
            print("위도 \(latitude)")
            print("경도 \(longtitude)")
        }
    }
   
    // 위도 경도 받아오기 실패
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("error")
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        print("Change Authorization")
        switch locationManager.authorizationStatus {
        case .authorizedAlways:
            locationManager.allowsBackgroundLocationUpdates = true
        case .authorizedWhenInUse:
            locationManager.allowsBackgroundLocationUpdates = false
        case .notDetermined, .restricted, .denied:
            locationManager.requestAlwaysAuthorization()
        @unknown default:
            print("Defualt")
        }
    }
//    // 지도 터치 함수
//    func mapView(_ mapView: NMFMapView, didTapMap latlng: NMGLatLng, point: CGPoint) {
//
//    }
    
//    // 카메라 이동 함수
//    func mapView(_ mapView: NMFMapView, cameraWillChangeByReason reason: Int, animated: Bool) {
//
//    }
}
