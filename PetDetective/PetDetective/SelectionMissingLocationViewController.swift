//
//  SelectionMssingLocationViewController.swift
//  PetDetective
//
//  Created by Junseo Park on 2022/03/25.
//

import NMapsMap

class SelectionMissingLocationViewController: MapViewController {
    
    let customMapView = MapView()
    
    var missingLatitude: Double?   // 위도
    var missingLongtitude: Double? // 경도
    var missingAddress: String? {
        didSet {
            customMapView.addressLabel.text = missingAddress
        }
    }
    
    @IBOutlet weak var missingMapView: UIView!
    
    override var isAuthorized: Bool {
        didSet {
            updateMapViewFromMode(isAuthorized: isAuthorized, naverMapView: customMapView.naverMapView)
            updateUICustomMapViewFromMode(isAuthorized: isAuthorized, customMapView.addressLabel, customMapView.setLocationButton)
        }
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.missingMapView.addSubview(customMapView)
//        self.view.addSubview(customMapView)
        
        customMapView.translatesAutoresizingMaskIntoConstraints = false
        customMapView.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 1).isActive = true
        customMapView.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 1).isActive = true
        customMapView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        customMapView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
        
        setLocationManager()
        
        customMapView.setLocationButton.setTitle("실종 위치 설정", for: .normal)
        
        customMapView.setLocationButton.backgroundColor = .systemRed
        
        customMapView.mapView.addCameraDelegate(delegate: self)
        
        customMapView.setLocationButton.addTarget(self, action: #selector(buttonTapped(button:)), for: .touchUpInside)
        
    }
    
    @objc func buttonTapped(button: UIButton) {
        // 데이터 저장
        self.performSegue(withIdentifier: "unwinToMainFromSetMissingLocation", sender: self)
    }
    
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

extension SelectionMissingLocationViewController {
    // 카메라 움직임 종료시 실행
    func mapViewCameraIdle(_ mapView: NMFMapView) {
        
        let cameraPosition = mapView.cameraPosition // 카메라 현재 위치 (지도 중앙 좌표)
        let centerLat = cameraPosition.target.lat
        let centerLng = cameraPosition.target.lng
        
        // 좌표 주소 변환
        // 위도 경도 주소 저장
        findAddress(lat: centerLat, long: centerLng, completion: { (centerAddress) in
            if let centerAddress = centerAddress {
                self.missingLatitude = centerLat
                self.missingLongtitude = centerLng
                self.missingAddress = centerAddress
                print("실종 (카메라 중앙) 좌표 \(centerLat), \(centerLng), \(centerAddress)")
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



