//
//  FindLocationViewController.swift
//  PetDetective
//
//  Created by Junseo Park on 2022/04/08.
//
//
//import CoreLocation


import NMapsMap

class FindLocationViewController: MapViewController {
    
    let customMapView = MapView()
    
    var findingLatitude: Double?   // 위도
    var findingLongtitude: Double? // 경도
    var findingAddress: String? {
        didSet {
            customMapView.addressLabel.text = findingAddress
        }
    }
    
    @IBOutlet weak var findMapView: UIView!
    
    override var isAuthorized: Bool {
        didSet {
            updateUIFromMode(isAuthorized: isAuthorized, naverMapView: customMapView.naverMapView, customMapView.addressLabel, customMapView.setLocationButton)
        }
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        self.findMapView.addSubview(customMapView)
        
        customMapView.translatesAutoresizingMaskIntoConstraints = false
        customMapView.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 1).isActive = true
        customMapView.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 1).isActive = true
        customMapView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        customMapView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
        
        setLocationManager()
        
        customMapView.setLocationButton.setTitle("탐색 위치 설정", for: .normal)
        
        customMapView.setLocationButton.backgroundColor = .systemBrown
        
        customMapView.mapView.addCameraDelegate(delegate: self)
        
        customMapView.setLocationButton.addTarget(self, action: #selector(buttonTapped(button:)), for: .touchUpInside)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let LV = segue.destination as? LoginViewController {
            LV.locationTextField.text = customMapView.addressLabel.text
        }
    }
    
    @objc func buttonTapped(button: UIButton) {
        // 데이터 저장
        self.performSegue(withIdentifier: "unwindFromFindLocation", sender: self)
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

extension FindLocationViewController {
    // 카메라 움직임 종료시 실행
    func mapViewCameraIdle(_ mapView: NMFMapView) {

        let cameraPosition = mapView.cameraPosition // 카메라 현재 위치 (지도 중앙 좌표)
        let centerLat = cameraPosition.target.lat
        let centerLng = cameraPosition.target.lng

        // 좌표 주소 변환
        // 위도 경도 주소 저장
        findAddress(lat: centerLat, long: centerLng, completion: { (centerAddress) in
            if let centerAddress = centerAddress {
                self.findingLatitude = centerLat
                self.findingLongtitude = centerLng
                self.findingAddress = centerAddress
                print("\(centerLat) \n \(centerLng) \n \(centerAddress)")
            }
        })
    }
    
}



