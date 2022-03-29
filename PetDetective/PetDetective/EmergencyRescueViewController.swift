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
    
    var centerLat = Double()
    var centerLng = Double()
    
    // 위치 권한 허용 (항상 허용, 앱사용시에만 허용)
    // 위치 추적 권한 부인시 앱 허용 상태 페이지로 가게함
    // 실시간 위치 추적 및 오버레이 표시
    
    // 실종 게시글 업로드
    // 실종 시간 3시간 미만
    // 좌표값 전송 (로컬 > 서버)
    // 서버에서 검색 (사용자 1km 내에 있는 좌표)
    // 해당 유저와 가까운 순으로 정렬
    // 좌표값 전송 (서버 > 로컬)
    // 지도에 이미지로 좌표에 표시
    // 지도 이미지 눌렀을때 클릭 기능 (테두리 표시), 잃어버린 위치 문구
    // 지도 반경 표시 (700 ~ 1km)
    // 지도 카메라 반경에 따라 위치 조정
    // 사용자 현재 위치 실시간 추적 및 표시
    // 골든 타임 정보 탭 (남은 골든 타임, 의뢰된 동물 이미지, 사레금, 의뢰글 정보 보기 버튼)
    // 남은 골든 타임 = 3h - (현재시간 - 실종시간)
    // 제보하러 가기 버튼 (신고탭 - 제보 화면 연결)
    
    // 백그라운드에서 좌표 전달 해야댐
    
    @IBOutlet weak var mapView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 델리게이트 설정
        locationManager.delegate = self
        
        // 거리 정확도 설정
        // locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
        
        // GPS 위치 정보 받아오기
        locationManager.startUpdatingLocation()
        
        // 네이버 지도 서브 뷰로 추가
        let naverMap = NMFMapView(frame: mapView.frame)
        
        // 네이버 지도 자동 위치 추적 및 오버레이 활성화
        naverMap.positionMode = .compass
        
        mapView.addSubview(naverMap)
        
//        var cameraPosition = naverMap.cameraPosition
//        var centerLat = cameraPosition.target.lat
//        var centerLng = cameraPosition.target.lng
//
//
//        let marker = NMFMarker()
//        marker.position = NMGLatLng(lat: centerLat, lng: centerLng)
//        marker.mapView = naverMap
//        print("중앙 좌표 \(centerLat), \(centerLng)")
        
        // locationManager.startMonitoringSignificantLocationChanges()
        
    }
    
        
    // 위치 정보 계속 업데이트 -> 위도 경도 받아옴
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("didUpdateLocations")
        if let location = locations.first {
            let latitude = location.coordinate.latitude
            let longtitude = location.coordinate.longitude
            print("위도 \(latitude)")
            print("경도 \(longtitude)")
            

            let findLocation = CLLocation(latitude: 37.557576, longitude: 126.9251192)
            let geocoder = CLGeocoder()
            let locale = Locale(identifier: "Ko-kr") //원하는 언어의 나라 코드를 넣어주시면 됩니다.
            geocoder.reverseGeocodeLocation(findLocation, preferredLocale: locale, completionHandler: {(placemarks, error) in
                if let address: [CLPlacemark] = placemarks {
//                    if let name: String = address.last?.name { print(name) } // 전체 주소
//                    if let name: String = address.last?.administrativeArea { print(name) } // 전체 주소
//                    if let name: String = address.last?.thoroughfare { print(name) } // 전체 주소
//                    if let name: String = address.last?.locality { print(name) } // 전체
                    if let name: String = address.last?.subLocality { print(name) } // 전체 주소
                }
            })
        }
    }
   
    // 위도 경도 받아오기 실패
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("error")
    }
    
    // 위치 권한 변경시 권한 받아오기
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        print("Change Authorization")
        switch locationManager.authorizationStatus {
        case .authorizedAlways:
            locationManager.allowsBackgroundLocationUpdates = true
        case .authorizedWhenInUse:
            locationManager.allowsBackgroundLocationUpdates = false
        case .notDetermined:
            print("not determined")
            locationManager.requestAlwaysAuthorization()
            // locationManager.requestWhenInUseAuthorization()
        case .restricted:
            print("not restricted")
        case .denied:
            print("not denied")
        @unknown default:
            break
        }
    }

//
//    // 현재 위치 주소
//    func getCurrentAddress(location: CLLocation, address: @escaping (String) -> Void) {
//        var currentAddress = ""
//        let geoCoder: CLGeocoder = CLGeocoder()
//        let location: CLLocation = location
//        let placeM = init(place)
//
//
//
//        // 한국어 주소 설정
//        let locale = Locale(identifier: "Ko-Kr")
//        //위경도를 통해 주소 변환
//        geoCoder.reverseGeocodeLocation(location, preferredLocale: locale) { (placeM, error) -> Void in
//
//            guard error == nil else {
//                print("주소 설정 불가능")
//                return
//            }
//
//            if let administrativeArea : String = placeM { currentAddress.append(administrativeArea + " " )}
//            if let locality : String = loca.locality { currentAddress.append(locality + " ")
//            }
//            if let subLocality : String = loca.subLocality { currentAddress.append(subLocality + " ")
//            }
//            address(currentAddress)
//        }
//    }
//
//    // 지도 터치 함수
//    func mapView(_ mapView: NMFMapView, didTapMap latlng: NMGLatLng, point: CGPoint) {
//
//    }
    
//    // 카메라 이동 함수
//    func mapView(_ mapView: NMFMapView, cameraWillChangeByReason reason: Int, animated: Bool) {
//
//    }
}
