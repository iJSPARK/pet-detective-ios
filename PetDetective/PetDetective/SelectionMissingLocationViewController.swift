//
//  SelectionMssingLocationViewController.swift
//  PetDetective
//
//  Created by Junseo Park on 2022/03/25.
//

//import UIKit
import NMapsMap
//import CoreLocation

class SelectionMissingLocationViewController: LocationController {
    
//    let locationManager = CLLocationManager()   // 위치 객체
    
    var missingLatitude: Double?   // 위도
    var missingLongtitude: Double? // 경도
    var missingAddress: String? {
        didSet {
            print("실종 (카메라 중앙) 좌표 \(missingLatitude), \(missingLongtitude), \(missingAddress)")
            self.addressLabel.text = missingAddress
        }
    }
    
    @IBOutlet weak var addressLabel: UILabel!

    
    @IBOutlet weak var setMissingLocationButton: UIButton!
    
    @IBOutlet weak var missingPoint: UIImageView!
    
    @IBOutlet weak var naverMapView: NMFNaverMapView!
    var mapView: NMFMapView {
        return naverMapView.mapView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        // 델리게이트 설정
//        locationManager.delegate = self
//
//        // 거리 정확도 설정
//        locationManager.desiredAccuracy = kCLLocationAccuracyBest
//
//        // GPS 위치 정보 받아오기
//        locationManager.startUpdatingLocation()
//
        // 카메라 delegate 설정, 카메라 이동 시마다 호출되는 콜백함수 사용 (카메라 이동 이벤트 받기)
        mapView.addCameraDelegate(delegate: self)
        
    }
    
    // 위치 추적 모드 유무
    func trackingMode(_ isAuthorized: Bool) {
        
        // 네이버 지도 사용자 인터렉션
        self.mapView.isUserInteractionEnabled = isAuthorized
        
        // 현재 위치 버튼 가져오기
        naverMapView.showLocationButton = isAuthorized
        
        // UIView 관련
        self.addressLabel.isEnabled = isAuthorized
        
        self.setMissingLocationButton.isEnabled = isAuthorized
        
        if isAuthorized {
            print("Tracking")
            
            // 위치 추적이 활성화 모드
            self.mapView.positionMode = .direction

            // 카메라 첫 움직임
            moveCameraFirstRun()
            
        } else {
            print("Not Tracking")
            
            self.mapView.positionMode = .disabled
            
        }
    }
    
    // 권한 확인
//    func setAuthAlertAction() {
//
//        let authAlertController = UIAlertController(title: "위치 사용 권한이 필요합니다.", message: "위치 권한을 허용해야만 앱을 사용하실 수 있습니다.", preferredStyle: .alert)
//
//        let getAuthAction = UIAlertAction(title: "설정", style: .default, handler: { (UIAlertAction) in
//            if let appSettings = URL(string: UIApplication.openSettingsURLString) {
//                UIApplication.shared.open(appSettings,options: [:],completionHandler: nil)
//            }
//        })
//
//        authAlertController.addAction(getAuthAction)
//
//        self.present(authAlertController, animated: true, completion: nil)
//    }
    
    @IBAction func saveMissingLocationButtonTapped(_ sender: Any) {
        // 데이터 입력 폼 화면으로 unwind segue 연결
        // 실종위치 (위도, 경도, 주소) 저장
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

//extension SelectionMissingLocationViewController: CLLocationManagerDelegate {
//
//
//    // 위치 권한 변경시 권한 받아오기
////    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
////        print("Changed Authorization")
////        trackingMode(false)
////        switch locationManager.authorizationStatus {
////        case .authorizedWhenInUse, .authorizedAlways:
////            print("Authorized")
////            trackingMode(true)
////        case .notDetermined, .restricted:
////            print("Not Authorized")
////            locationManager.requestWhenInUseAuthorization() // 권한 받아오기
////        case .denied:
////            print("Not denied")
////            setAuthAlertAction() // 위치 권한 거부: 설정 창으로 가서 권한을 변경하도록 유도해야 함
////        @unknown default:
////            break
////        }
////    }
//
////    // 좌표 주소 반환
////    func findAddress(lat: CLLocationDegrees, long: CLLocationDegrees, completion: @escaping (String?) -> Void) {
////        let findLocation = CLLocation(latitude: lat, longitude: long)
////        let geocoder = CLGeocoder()
////        let locale = Locale(identifier: "Ko-kr")
////        var findAddress: String = ""
////
////        geocoder.reverseGeocodeLocation(findLocation, preferredLocale: locale, completionHandler: { (placemarks, error) in
////
////            guard error == nil else { return print("ReverseGeocode error") }
////            guard let address: [CLPlacemark] = placemarks else { return print("ReverseGeocode address error") }
////            guard let locality: String = address.last?.locality else { return print("ReverseGeocode locality error") }
////            guard let name: String = address.last?.name else { return print("ReverseGeocode name error") }
////
////            findAddress = locality + " " + name
////
////            completion(findAddress)
////
////        })
////    }
//}

extension SelectionMissingLocationViewController: NMFMapViewCameraDelegate {
    
    func moveCameraFirstRun() {
        // 앱 처음 실행시 카메라 이동 현재 위치 비동기 처리 (1초후 카메라 이동)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            // self.setMissingLocationButton.isEnabled = false
            let cameraUpdate = NMFCameraUpdate(scrollTo: NMGLatLng(lat: self.locationManager.location?.coordinate.latitude ?? 0, lng: self.locationManager.location?.coordinate.longitude ?? 0))
            self.mapView.moveCamera(cameraUpdate) { (isCancelled) in
                if isCancelled {
                    print("카메라 이동 취소")
                } else {
                    print("카메라 이동 완료")
                }
            }
        }
    }
    
    // 카메라 움직임 종료시 실행
    func mapViewCameraIdle(_ mapView: NMFMapView) {
//        let alert = UIAlertController(title: "카메라 움직임 종료",
//                                      message: nil,
//                                      preferredStyle: .alert)
//        present(alert, animated: true, completion: {
//            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5, execute: {
//                alert.dismiss(animated: true, completion: nil)
//            })
//        })
        let cameraPosition = mapView.cameraPosition // 카메라 현재 위치 (지도 중앙 좌표)
        let centerLat = cameraPosition.target.lat
        let centerLng = cameraPosition.target.lng
        
        missingLatitude = centerLat
        missingLongtitude = centerLng
        
        // 좌표 주소 변환
        findAddress(lat: centerLat, long: centerLng, completion: { (centerAddress) in
            if let centerAddress = centerAddress {
                self.missingAddress = centerAddress
            }
        })
    }
    
//    // 카메라 이동 함수 cameraIsChangingByReason
//    func mapView(_ mapView: NMFMapView, cameraDidChangeByReason reason: Int, animated: Bool) {
//
////        let cameraPosition = NMFCameraPosition() // 카메라 위치 객체 생성
//        print("빠른 이동")
//        let cameraPosition = mapView.cameraPosition // 카메라 현재위치
//
////        let x = self.mapView.frame.width / 2
////        let y = self.mapView.frame.height / 2
////
////        let projection = mapView.projection // 카메라 투영
////        let coord = projection.latlng(from: CGPoint(x: x, y: y)) // 0.5, 0.5
//
//    }
    
//    func mapViewRegionIsChanging(_ mapView: NMFMapView, byReason reason: Int) {
//        print("카메라 변경 - reason: \(reason)")
//
//        let cameraPosition = NMFCameraPosition() // 카메라 위치 객체 생성
//
//        let centerLat = cameraPosition.target.lat
//        let centerLng = cameraPosition.target.lng
//
//        let marker = NMFMarker()
//        marker.position = NMGLatLng(lat: centerLat, lng: centerLng)
//        marker.mapView = mapView
//        print("중앙 좌표 \(centerLat), \(centerLng)")
//    }

}

