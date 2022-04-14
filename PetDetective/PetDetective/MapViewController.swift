//
//  MapViewController.swift
//  PetDetective
//
//  Created by Junseo Park on 2022/04/08.
//

import NMapsMap

class MapViewController: LocationController, NMFMapViewCameraDelegate {
    
    func moveCameraFirstRun(_ naverMapView: NMFNaverMapView) {
        // 앱 처음 실행시 카메라 이동 현재 위치 비동기 처리 (1초후 카메라 이동)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            let cameraUpdate = NMFCameraUpdate(scrollTo: NMGLatLng(lat: self.locationManager.location?.coordinate.latitude ?? 0, lng: self.locationManager.location?.coordinate.longitude ?? 0))
            naverMapView.mapView.moveCamera(cameraUpdate) { (isCancelled) in
                if isCancelled {
                    print("카메라 이동 취소")
                } else {
                    print("카메라 이동 완료")
                }
            }
        }
    }
    
    
    // 위치 추적 모드에 따른 UIView update
    func updateUIFromMode(isAuthorized: Bool, naverMapView: NMFNaverMapView, _ addressLabel: UILabel?, _ setLocationButton: UIButton?) {

        // 네이버 지도 사용자 인터렉션
        naverMapView.mapView.isUserInteractionEnabled = isAuthorized

        // 현재 위치 버튼 가져오기
        naverMapView.showLocationButton = isAuthorized
        
        addressLabel?.isEnabled = isAuthorized
        setLocationButton?.isEnabled = isAuthorized
        
        if isAuthorized {
            print("Tracking Mode")

            // 위치 추적이 활성화 모드
            naverMapView.mapView.positionMode = .direction

            // 카메라 첫 움직임
            // moveCameraFirstRun(naverMapView)

        } else {
            print("Not Tracking Mode")

            naverMapView.mapView.positionMode = .disabled

        }
    }
    
}

