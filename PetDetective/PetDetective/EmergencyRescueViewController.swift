//
//  ReportViewController.swift
//  PetDetective
//
//  Created by Junseo Park on 3/19/22.
//

import UIKit
import NMapsMap
import CoreLocation

class EmergencyRescueViewController: UIViewController {
    
    let emergencyRescuePetInfoController = EmergencyRescuePetInfoController()
    
    
    
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
    
    let locationManager = CLLocationManager()   // 위치 객체
    
    @IBOutlet weak var naverMapView: NMFNaverMapView!
    var mapView: NMFMapView {
        return naverMapView.mapView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 델리게이트 설정
        locationManager.delegate = self
    
        // 거리 정확도 설정
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        // GPS 위치 정보 받아오기
        locationManager.startUpdatingLocation()
        
        // 카메라 delegate 설정, 카메라 이동 시마다 호출되는 콜백함수 사용 (카메라 이동 이벤트 받기)
        mapView.addCameraDelegate(delegate: self)

//        var missingPets: [MissingPetInfo]?
        
        emergencyRescuePetInfoController.fetchedMissingPetInfo { (missingPet) in
            guard let missingPet = missingPet else { return }
            guard let missingPets = missingPet.missingPetInfos else { return }
            
            self.updateUI(with: missingPets)
            
            
        }
            
    
    }
    
    
    func updateUI(with missingPets: [MissingPetInfo]) {
        DispatchQueue.global(qos: .default).async {
            // 백그라운드 스레드
            var markers = [NMFMarker]()
            for i in 0..<missingPets.count {
                print("Add Marker")
                
                let marker = NMFMarker(position: NMGLatLng(lat: missingPets[i].latitude ?? 37.33517959240947, lng: missingPets[i].longtitude ?? 127.11733318999303))
                
//                let image = missingPets[i].image?.toImage()! // 스트링으로 바꾸기


//                guard let url = URL(string: missingPets[i].image!) else { return }
//                guard let data = try? Data(contentsOf: url) else { return }
//                guard let petImage = UIImage(data: data) else { return }
//                DispatchQueue.main.async {
//                    let petImageView = UIImageView(image: image)
//                    petImageView.layer.borderWidth = 1
//                    petImageView.layer.masksToBounds = false
//                    petImageView.layer.cornerRadius = petImageView.layer.frame.height / 2
//                    petImageView.layer.cornerRadius = petImageView.layer.frame.height / 2
//                    imageMainView.clipsToBounds = true
//                    marker.iconImage = NMFOverlayImage(name: missingPets[i].image)
//                    marker.iconImage = NMFOverlayImage(image: petImageView.image)
                
//
//                }
                markers.append(marker)
                print("\(missingPets[i].latitude), \(missingPets[i].longtitude)")
            }

            DispatchQueue.main.async { [weak self] in
                // 메인 스레드
                for marker in markers {
                    marker.self.mapView = self?.mapView
                }
            }
        }
    }
    
//    func makeRounded() {
//
//        self.layer.borderWidth = 1
//        self.layer.masksToBounds = false
//        self.layer.borderColor = UIColor.black.cgColor
//        self.layer.cornerRadius = self.frame.height / 2
//        self.clipsToBounds = true
//    }
    
    // 위치 추적 모드 유무
    func trackingMode(_ isAuthorized: Bool) {
        
        // 네이버 지도 사용자 인터렉션
        self.mapView.isUserInteractionEnabled = isAuthorized
        
        // 현재 위치 버튼 가져오기
        naverMapView.showLocationButton = isAuthorized
        
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
    
//    // 권한 확인
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
    
    
        
//    // 위치 정보 계속 업데이트 -> 위도 경도 받아옴
//    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        print("didUpdateLocations")
//        if let location = locations.first {
//            let latitude = location.coordinate.latitude
//            let longtitude = location.coordinate.longitude
//            print("위도 \(latitude), 경도 \(longtitude)")
//        }
//    }
   
//    // 위도 경도 받아오기 실패
//    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
//        print("error")
//    }
    
//    // 지도 터치 함수
//    func mapView(_ mapView: NMFMapView, didTapMap latlng: NMGLatLng, point: CGPoint) {
//
//    }
    
//    // 카메라 이동 함수
//    func mapView(_ mapView: NMFMapView, cameraWillChangeByReason reason: Int, animated: Bool) {
//
//    }
}


extension EmergencyRescueViewController: CLLocationManagerDelegate {
//    // 위치 권한 변경시 권한 받아오기
//    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
//        print("Changed Authorization")
//        trackingMode(false)
//        switch locationManager.authorizationStatus {
//        case .authorizedWhenInUse, .authorizedAlways:
//            print("Authorized")
//            trackingMode(true)
//        case .notDetermined, .restricted:
//            print("Not Authorized")
//            locationManager.requestWhenInUseAuthorization() // 권한 받아오기
//        case .denied:
//            print("Not denied")
//            setAuthAlertAction() // 위치 권한 거부: 설정 창으로 가서 권한을 변경하도록 유도해야 함
//        @unknown default:
//            break
//        }
//    }
    
    // 좌표 주소 반환
    func findAddress(lat: CLLocationDegrees, long: CLLocationDegrees, completion: @escaping (String?) -> Void) {
        let findLocation = CLLocation(latitude: lat, longitude: long)
        let geocoder = CLGeocoder()
        let locale = Locale(identifier: "Ko-kr")
        var findAddress: String = ""

        geocoder.reverseGeocodeLocation(findLocation, preferredLocale: locale, completionHandler: { (placemarks, error) in

            guard error == nil else { return print("ReverseGeocode error") }
            guard let address: [CLPlacemark] = placemarks else { return print("ReverseGeocode address error") }
            guard let locality: String = address.last?.locality else { return print("ReverseGeocode locality error") }
            guard let name: String = address.last?.name else { return print("ReverseGeocode name error") }

            findAddress = locality + " " + name

            completion(findAddress)

        })
    }
}

extension EmergencyRescueViewController: NMFMapViewCameraDelegate {
    
    func moveCameraFirstRun() {
//        // 앱 처음 실행시 카메라 이동 현재 위치 비동기 처리 (1초후 카메라 이동)
//        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
//            // self.setMissingLocationButton.isEnabled = false
//            let cameraUpdate = NMFCameraUpdate(scrollTo: NMGLatLng(lat: self.locationManager.location?.coordinate.latitude ?? 0, lng: self.locationManager.location?.coordinate.longitude ?? 0))
//            self.mapView.moveCamera(cameraUpdate) { (isCancelled) in
//                if isCancelled {
//                    print("카메라 이동 취소")
//                } else {
//                    print("카메라 이동 완료")
//                }
//            }
//        }
    }
    
//    // 카메라 움직임 종료시 실행
//    func mapViewCameraIdle(_ mapView: NMFMapView) {
////        let alert = UIAlertController(title: "카메라 움직임 종료",
////                                      message: nil,
////                                      preferredStyle: .alert)
////        present(alert, animated: true, completion: {
////            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5, execute: {
////                alert.dismiss(animated: true, completion: nil)
////            })
////        })
//        let cameraPosition = mapView.cameraPosition // 카메라 현재 위치 (지도 중앙 좌표)
//        let centerLat = cameraPosition.target.lat
//        let centerLng = cameraPosition.target.lng
//
//        missingLatitude = centerLat
//        missingLongtitude = centerLng
//
//        // 좌표 주소 변환
//        findAddress(lat: centerLat, long: centerLng, completion: { (centerAddress) in
//            if let centerAddress = centerAddress {
//                self.missingAddress = centerAddress
//            }
//        })
//    }
    
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

extension String {
    func toImage() -> UIImage? {
        if let data = Data(base64Encoded: self, options: .ignoreUnknownCharacters){
            return UIImage(data: data)
        }
        return nil
    }
}
