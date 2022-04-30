//
//  ReportViewController.swift
//  PetDetective
//
//  Created by Junseo Park on 3/19/22.
//

import NMapsMap
import UIKit

struct MarkerInfo {
    var missingTime: String
    let money: Int
//    let boadrId: Int
}

// 데이터 요청 후
// 실종시간 > 남은시간으로
// 날짜 시간 변환 > 남은 시간 = 현재 핸드폰 시간 - 실종 시간 > 남은시간 marker에 저장 > 남은 시간
// 타이머 발동 > 남은시간 - count
// 함수 적용
// 의뢰글 나오게 하기
// 터치 하면 잃어버린 위치 마커 캡션 토글값
// 지도 터치시 뷰 없애기
// 이미지 리사이즈 및 뽑기

class EmergencyRescueViewController: MapViewController {
    
    var markers = [NMFMarker]()
    var mTimer: Timer?
    var remainTime = 0 // 남은시간
    var count = 0   // 시간 카운트
    var missingTime = 1 // 넣는 시간
    
    let emergencyRescuePetInfoController = EmergencyRescuePetInfoController()
    
    let naverMap = MapView().naverMapView!
    
    var infoWindow = NMFInfoWindow()
//    var dataSource = NMFInfoWindowDefaultTextSource.data()
    
    var customInfoWindowDataSource = CustomInfoWindowDataSource()
    
    @IBOutlet weak var rescueMapView: UIView!
    
    @IBOutlet weak var markerInfoView: UIView!
    @IBOutlet weak var goldenTimeLabel: UILabel!
    @IBOutlet weak var moneyLabel: UILabel!
    
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
            
            self.updateMapUI(with: missingPets)
        }

        timerRun()
    }
    
    func updateMapUI(with missingPets: [MissingPetInfo]) {
        DispatchQueue.global(qos: .default).async { [self] in
            // 백그라운드 스레드 (오버레이 객체 생성)
            var add = 0.01
            
            for i in 0..<missingPets.count {
                print("Add Marker")
                
                let marker = NMFMarker(position: NMGLatLng(lat: 37.33517959240947 + add, lng: 127.11733318999303 + add))
                
                if i % 2 == 0 {
                    add -= 0.015
                } else {
                    add += 0.01
                }
                
        
                let imageString: String? =  "https://user-images.githubusercontent.com/92430498/163326267-f21af1c6-4c9a-43fa-b301-ec44084a49af.jpg"
                guard let petImage = imageString?.toImage() else { return }
                guard let petImageCircleResize = petImage.circleReSize() else { return }
                
                    
                marker.iconImage = NMFOverlayImage(image: petImageCircleResize)
                
                
                guard let time = missingPets[i].missingTime else { return }

                guard let money = missingPets[i].money else { return }
                
                marker.userInfo = ["MissingTime": time, "Money": money]
                
                markers.append(marker)
                print("\(missingPets[i].latitude), \(missingPets[i].longtitude)")
            }

            DispatchQueue.main.async { [weak self] in
                // 메인 스레드 (오버레이 객체 맵에 올림)
                

                for marker in self!.markers {
                    
                    marker.mapView = self?.naverMap.mapView
                    
                    marker.touchHandler = { (overlay: NMFOverlay) -> Bool in
                        print("마커 터치")
                        // 터치시 실종시간 - count
                        // 계속 1씩 감소
                        if let missingTime = marker.userInfo["MissingTime"] as? String {
                            print(missingTime)
                            if let currentDate = "yyyy-MM-dd HH:mm:ss".currentKorDate().stringToDate() {
                                print("현재 시간 \(currentDate)")
                                print("missingTime \(missingTime)")
                                if let missingDate = missingTime.stringToDate() {
                                    print("missingDate \(missingDate)")
                                    self?.remainTime = Int(currentDate.timeIntervalSince(missingDate))
                                    print("남은 시간(초) \(self?.remainTime)")
                                }
                            }
                        }
                        if let money = marker.userInfo["Money"] {
                            self?.moneyLabel.text = "사례금 \(money)"
                        }
                        self?.markerInfoView.isHidden = false
                        return true // 이벤트 소비, -mapView:didTapMap:point 이벤트는 발생하지 않음
                        
                    }
//                    marker.touchHandler = { [self] (overlay: NMFOverlay) -> Bool in
//                        if let marker = overlay as? NMFMarker {
//                            if marker.infoWindow == nil {
//                                // 현재 마커에 정보 창이 열려있지 않을 경우
//
//                                print("Touch")
//
////                                marker.userInfo = ["MarkerInfo": MarkerInfo(missingTime: "Dfdf", money: 100)]
//
//                                self?.infoWindow.dataSource = self!.customInfoWindowDataSource
//
//
////                                self?.dataSource.title = "\(add2)"
////                                add2 = add2 + 1
////
////                                print(add2)
////                                self?.infoWindow.dataSource = self!.dataSource
//
//                                self?.infoWindow.offsetY = +10
//
//                                self?.infoWindow.open(with:marker)
//
//
//                            } else {
//                                // 이미 현재 마커에 정보 창이 열려있을 경우 닫음
//
//                                self?.infoWindow.close()
//
//    //
//                            }
//                        }
//                        return true
//                    };
                }
                
//                if let timer = self?.mTimer {
//                    //timer 객체가 nil 이 아닌경우에는 invalid 상태에만 시작한다
//                    if !timer.isValid {
//                        /** 1초마다 timerCallback함수를 호출하는 타이머 */
//                        mTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(timerCallback()), userInfo: nil, repeats: true)
//                    }
//
//                } else {
//                    //timer 객체가 nil 인 경우에 객체를 생성하고 타이머를 시작한다
//                    /** 1초마다 timerCallback함수를 호출하는 타이머 */
//                    mTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(timerCallback()), userInfo: nil, repeats: true)
//                }
            }
            
        }
        
    }
    
    @IBAction func viewRequestPostButtonTapped(_ sender: Any) {
        
    }
    
    func timerRun() {
        print("timerRun")
        if let timer = mTimer {
            //timer 객체가 nil 이 아닌경우에는 invalid 상태에만 시작한다
            if !timer.isValid {
                /** 1초마다 timerCallback함수를 호출하는 타이머 */
                mTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(timerCallback), userInfo: nil, repeats: true)
            }

        } else {
            //timer 객체가 nil 인 경우에 객체를 생성하고 타이머를 시작한다
            /** 1초마다 timerCallback함수를 호출하는 타이머 */
            mTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(timerCallback), userInfo: nil, repeats: true)
        }
    }
    
    // 뷰가 업데이트 할때마다 네트워크 요청
    //타이머가 호출하는 콜백함수
    @objc func timerCallback() {
//        let markInfo = marker.userInfo["MarkerInfo"] as! MarkerInfo
//        var number = Int(markInfo.missingTime)!
        print("timerCallback")
//        for marker in markers {
//            if let missingTime = marker.userInfo["MissingTime"] as? Int {
//                if missingTime > 0 {
//                    marker.userInfo["MissingTime"] = missingTime - count
//                } else {
//                    marker.userInfo["MissingTime"] = 0
//                }
//                goldenTimeLabel.text = "골든 타임 \(String(describing: marker.userInfo["MissingTime"]))"
//            }
//        }
        if remainTime - count > 0 {
            remainTime = remainTime - count
            goldenTimeLabel.text = "골든 타임 \(remainTime.hour) \(remainTime.minute) \(remainTime.second)"
        } else {
            goldenTimeLabel.text = "0"
        }
        count += 1
//        if number == 0 {
//            if let timer = mTimer {
//                if (timer.isValid) {
//                    timer.invalidate()
//                }
//            }
//        }
//        marker.userInfo = ["MarkerInfo": MarkerInfo(missingTime: String(number), money: markInfo.money)]
//        number -= 1
//        if number == 0 {
//            if let timer = mTimer {
//                if (timer.isValid) {
//                    timer.invalidate()
//                }
//            }
//        }
//        time = String(number)
//        mark.userInfo = ["MarkerInfo": MarkerInfo(missingTime: time, money: money)]
    }

    
//    func view(with overlay: NMFOverlay) -> UIView {
//        print("IN view")
//        let markInfoView = MarkerInfoView()
//        let markerInfo = overlay.userInfo["MarkerInfo"] as! MarkerInfo
//        markInfoView.goldenTimeLabel.text = markerInfo.missingTime
//        markInfoView.moneyLabel.text = "\(markerInfo.money)"
//        
//        print(markerInfo.missingTime)
//        print(markerInfo.money)
//        
//        print(markInfoView)
//        return markInfoView
//    }
    
//    func reSize(imageString: String?) -> UIImage {
////        let url = URL(string: imageString!)!
////        let data = try? Data(contentsOf: url)
////        let image = UIImage(data: data!)
//        let newWidth = 36
//        let newHeight = 36
//        let newImageRect = CGRect(x: 0, y: 0, width: newWidth, height: newHeight)
////        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
//
//        UIGraphicsBeginImageContextWithOptions(CGSize(width: newWidth, height: newHeight), false, 0.0)
//
//        UIBezierPath(roundedRect: newImageRect, cornerRadius: 50).addClip()
//
//        image?.draw(in: newImageRect)
//        let newImage = UIGraphicsGetImageFromCurrentImageContext()?.withRenderingMode(.alwaysOriginal)
//        UIGraphicsEndImageContext()
//        return newImage!
//    }
    
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
        guard let url = URL(string: self) else { return nil }
        guard let data = try? Data(contentsOf: url) else { return nil }
        guard let image = UIImage(data: data) else { return nil }
        return image
//        let data = try? Data(contentsOf: url)
//        let image = UIImage(data: data!)
//        if let data = Data(base64Encoded: self, options: .ignoreUnknownCharacters){
//            return UIImage(data: data)
//        }
//        return nil
    }
    
    func currentKorDate() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = self
        dateFormatter.locale = Locale(identifier: "ko_KR")
        return dateFormatter.string(from: Date())
    }
    
    func stringFromDate() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = self
        return dateFormatter.string(from: Date())
    }
    
    func stringToDate() -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss +0000"
        dateFormatter.timeZone = TimeZone(identifier: "UTC")
        return dateFormatter.date(from: self)
    }
}

extension Int {
  var hour: Int {
    self / 3600
  }
  var minute: Int {
    (self % 3600) / 60
  }
  var second: Int {
    (self % 60)
  }
}


extension UIImage {
//    var roundedImage: UIImage {
//        let rect = CGRect(origin:CGPoint(x: 0, y: 0), size: self.size)
//        UIGraphicsBeginImageContextWithOptions(self.size, false, 1)
//        UIBezierPath(roundedRect: newImageRect, cornerRadius: 50).addClip()
//        self.draw(in: rect)
//        return UIGraphicsGetImageFromCurrentImageContext()!
//    }
    
    func circleReSize() -> UIImage? {
        let newWidth = 36
        let newHeight = 36
        let newImageRect = CGRect(x: 0, y: 0, width: newWidth, height: newHeight)
        
        UIGraphicsBeginImageContextWithOptions(CGSize(width: newWidth, height: newHeight), false, 0.0)

        UIBezierPath(roundedRect: newImageRect, cornerRadius: 50).addClip()
        
        self.draw(in: newImageRect)
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()?.withRenderingMode(.alwaysOriginal)
        
        UIGraphicsEndImageContext()
        
        return newImage
    }
}

//extension UIView {
//    func toMakerView(_ view: UIView) -> MarkerInfoView {
//        view.addSubview(<#T##view: UIView##UIView#>)
//        if let data = Data(base64Encoded: self, options: .ignoreUnknownCharacters){
//            return UIImage(data: data)
//        }
//        return nil
//    }
//}

