//
//  ReportViewController.swift
//  PetDetective
//
//  Created by Junseo Park on 3/19/22.
//

import NMapsMap
import UIKit

class EmergencyRescueViewController: MapViewController {
    
    let emergencyRescuePetInfoController = EmergencyRescuePetInfoController()
    
    let naverMap = MapView().naverMapView!
    
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
    
    @IBOutlet weak var rescueMapView: UIView!
    
    override var isAuthorized: Bool {
        didSet {
            updateUIFromMode(isAuthorized: isAuthorized, naverMapView: naverMap, nil, nil)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.rescueMapView.addSubview(naverMap)
        
        naverMap.translatesAutoresizingMaskIntoConstraints = false
        naverMap.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 1).isActive = true
        naverMap.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 1).isActive = true
        naverMap.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        naverMap.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
        
        setLocationManager()
        
        naverMap.mapView.addCameraDelegate(delegate: self)
        
        emergencyRescuePetInfoController.fetchedMissingPetInfo { (missingPet) in
            guard let missingPet = missingPet else { return }
            guard let missingPets = missingPet.missingPetInfos else { return }

            self.updateUI(with: missingPets)


        }

        
    }
    
    
    func updateUI(with missingPets: [MissingPetInfo]) {
        DispatchQueue.global(qos: .default).async { [self] in
            // 백그라운드 스레드 (오버레이 객체 생성)
            var markers = [NMFMarker]()
            for i in 0..<missingPets.count {
                print("Add Marker")

                let marker = NMFMarker(position: NMGLatLng(lat: missingPets[i].latitude ?? 37.33517959240947, lng: missingPets[i].longtitude ?? 127.11733318999303))
                
//                print(missingPets[i].image)
        
                let imageString: String? =  "https://user-images.githubusercontent.com/92430498/163326267-f21af1c6-4c9a-43fa-b301-ec44084a49af.jpg"
                
                let petImage = self.reSize(imageString: imageString)
                    
                
                marker.iconImage = NMFOverlayImage(image: petImage)
            
                
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
//
//                }
                markers.append(marker)
                print("\(missingPets[i].latitude), \(missingPets[i].longtitude)")
            }

            DispatchQueue.main.async { [weak self] in
                // 메인 스레드 (오버레이 객체 맵에 올림)

                for marker in markers {
                    marker.mapView = self?.naverMap.mapView
                }
            }
        }
    }
    
    func reSize(imageString: String?) -> UIImage {
        let url = URL(string: imageString!)!
        let data = try? Data(contentsOf: url)
        let image = UIImage(data: data!)
        let newWidth = 36
        let newHeight = 36
        let newImageRect = CGRect(x: 0, y: 0, width: newWidth, height: newHeight)
//        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
        
        UIGraphicsBeginImageContextWithOptions(CGSize(width: newWidth, height: newHeight), false, 0.0)

        UIBezierPath(roundedRect: newImageRect, cornerRadius: 50).addClip()
        
        image?.draw(in: newImageRect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()?.withRenderingMode(.alwaysOriginal)
        UIGraphicsEndImageContext()
        return newImage!
    }
    
//    func makeRounded() {
//
//        self.layer.borderWidth = 1
//        self.layer.masksToBounds = false
//        self.layer.borderColor = UIColor.black.cgColor
//        self.layer.cornerRadius = self.frame.height / 2
//        self.clipsToBounds = true
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
    
}

extension String {
    func toImage() -> UIImage? {
        if let data = Data(base64Encoded: self, options: .ignoreUnknownCharacters){
            return UIImage(data: data)
        }
        return nil
    }
}

extension UIImage {
    var roundedImage: UIImage {
        let rect = CGRect(origin:CGPoint(x: 0, y: 0), size: self.size)
        UIGraphicsBeginImageContextWithOptions(self.size, false, 1)
        UIBezierPath(
            roundedRect: rect,
            cornerRadius: 50
            ).addClip()
        self.draw(in: rect)
        return UIGraphicsGetImageFromCurrentImageContext()!
    }
}

