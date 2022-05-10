//
//  ReportViewController.swift
//  PetDetective
//
//  Created by Junseo Park on 3/19/22.
//

import NMapsMap
import UIKit

enum ReportMode: String {
    case request = "requset"
    case find = "find"
    
    func toString() -> String {
        return rawValue
    }
}

// 의뢰 > 탐색위치 추가해서 받아와야함
// 목격 > 실종위치 추가해서 받아와야함

class EmergencyRescueViewController: MapViewController, NMFMapViewTouchDelegate {
    
    let emergencyRescuePetInfoController = EmergencyRescuePetInfoController()
    var naverMap = MapView().naverMapView!
    
    var markers = [NMFMarker]()
    var getMarker: NMFMarker?
    var secondTimer: Timer?
    var reportMode: ReportMode?
    var remainTime = 1 // 남은시간
    
    @IBOutlet weak var rescueMapView: UIView!
    @IBOutlet weak var markerInfoView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var goldenTimeLabel: UILabel!
    @IBOutlet weak var addDetailLabel: UILabel!
    @IBOutlet weak var boardButton: UIButton!
    @IBOutlet weak var reportSegment: UISegmentedControl!
    
    override var isAuthorized: Bool {
        didSet {
            updateUIFromMode(isAuthorized: isAuthorized, naverMapView: naverMap, nil, nil)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.rescueMapView.addSubview(naverMap)
        
        naverMap.translatesAutoresizingMaskIntoConstraints = false
        naverMap.widthAnchor.constraint(equalTo: self.rescueMapView.widthAnchor, multiplier: 1).isActive = true
        naverMap.heightAnchor.constraint(equalTo: self.rescueMapView.heightAnchor, multiplier: 1).isActive = true
        naverMap.centerXAnchor.constraint(equalTo: self.rescueMapView.centerXAnchor).isActive = true
        naverMap.centerYAnchor.constraint(equalTo: self.rescueMapView.centerYAnchor).isActive = true
        
        naverMap.mapView.touchDelegate = self
        
        setLocationManager()
        
        naverMap.mapView.addCameraDelegate(delegate: self)
        
        boardButton.layer.cornerRadius = 6
        boardButton.tintColor = .white
        boardButton.backgroundColor = .systemBrown
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
//        reportMode = .request // report mode를 초기값으로 (알림으로 들어오면 board값으로 request, find)
        updateReportUI(mode: reportMode) // report mode를 초기값으로 (알림으로 들어오면 board값으로
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        timerQuit()
    }
    
    func updateReportUI(mode: ReportMode?) {
        timerQuit()
        markerInfoView.isHidden = true
        if mode == .find {
            print("find mode")
            emergencyRescuePetInfoController.fetchedFindPetInfo { (findPet) in
                guard let findPet = findPet else {
                    // 목격신고한 유저 없으면
                    self.alertOk( title: "실종 신고한 이력이 없습니다.", message: "실종 신고한 이력이 없습니다.\n실종 신고한 애완동물과 같은 종의 동물이 지도에 표시됩니다.", viewController: self)
                    return
                }
                guard let findPets = findPet.findPetInfos else { return }

                self.updateMapUI(with: findPets)
            }

        } else { // mode request 이거나 nil 일때
            print("request or nil mode")
            reportMode = .request
            emergencyRescuePetInfoController.fetchedMissingPetInfo { (missingPet) in
                guard let missingPet = missingPet else { return }
                print("missinPet Data")
                guard let missingPets = missingPet.missingPetInfos else { return }
                print("missinPets Data")
                self.updateMapUI(with: missingPets)
                print("updateMapUI")
            }
        }
        // 카메라 이동 (실종 / 발견 위치 시점)
    }
    
    func updateMapUI(with pets: [Any]) {
        // seguementcontrol 값 변경 되면 삭제후 새 마커 찍기
        // 신고한 글 없으면 경고창
        // 마커 존재 하면 삭제하고 실행
        timerRun()
        print("updateMapUI")
        if let missingPets = pets as? [MissingPetInfo] {
            DispatchQueue.global(qos: .default).async { [self] in
                // 백그라운드 스레드 (오버레이 객체 생성)
                var add = 0.01
               
                for i in 0..<missingPets.count {
                    print("Add Marker")
                    
                    let marker = NMFMarker(position: NMGLatLng(lat: 37.33517959240947 + add, lng: 127.11733318999303 + add))
                    
//                    let marker = NMFMarker(position: NMGLatLng(lat: 37.33517959240947 + add, lng: 127.11733318999303 + add))
                    
                    if i % 2 == 0 {
                        add -= 0.015
                    } else {
                        add += 0.01
                    }
                    

                    let imageString: String? =  "https://user-images.githubusercontent.com/92430498/163326267-f21af1c6-4c9a-43fa-b301-ec44084a49af.jpg"
                    guard let petImage = imageString?.toImage() else { return }
                    guard let petImageCircleResize = petImage.circleReSize() else { return }
                    
    //                    guard let imageString = missingPets[i].image else { return }
    //
    //                    guard let petImage = imageString.toImage() else { return }
    //
    //                    guard let petImageCircleResize = petImage.circleReSize() else { return }
                        
                    marker.iconImage = NMFOverlayImage(image: petImageCircleResize)
                    
                    guard let time = missingPets[i].missingTime else { return }

                    guard let money = missingPets[i].money else { return }
                    
                    marker.userInfo = ["MissingTime": time, "Money": money]
                    
                    // 마커 초기값 저장
                    if i == 0 {
                        getMarker = marker
                    }
                    
                    markers.append(marker)
                    print("\(missingPets[i].latitude), \(missingPets[i].longtitude)")
                }

                DispatchQueue.main.async { [self] in
                    // 메인 스레드 (오버레이 객체 맵에 올림)
                    for marker in markers {
                        
                        marker.mapView = self.naverMap.mapView
                        
                        func createRequestMarkerInfoView() {
                            if self.markerInfoView.isHidden == true {
                                if let missingTime = marker.userInfo["MissingTime"] as? String {
                                    print(missingTime)
                                    if let currentDate = "yyyy-MM-dd HH:mm:ss".currentKorDate().stringToDate() {
                                        print("현재 날짜 시간 \(currentDate)")
                                        print("String type 실종 날짜 시간 \(missingTime)")
                                        if let missingTime = missingTime.stringToDate() {
                                            print("Date type 실종 날짜 시간 \(missingTime)")
                                            self.remainTime = Int(currentDate.timeIntervalSince(missingTime))
                                            print("골든 타임 남은 시간(초) \(self.remainTime)")
                                            
                                        }
                                    }
                                }
                                
                                if let money = marker.userInfo["Money"] {
                                    self.addDetailLabel.text = "💰 사례금 \(money)"
                                    self.getMarker = marker
                                    self.getMarker?.captionText = "잃어버린 위치"
                                    self.getMarker?.captionColor = UIColor.red
                                }
                                self.titleLabel.text = "🚨 목격된 같은 종의 애완동물"
                                self.boardButton.setTitle("목격글 보기", for: .normal) // 버튼 이름 변경
                                self.markerInfoView.isHidden = false
                            }
                            else {
                                self.getMarker?.captionText = ""
                                self.markerInfoView.isHidden = true
                            }
                        }
                        
                        // 마커 초기값
                        if self.getMarker == marker {
                            createRequestMarkerInfoView()
                        }
                       
                        
                        marker.touchHandler = { (overlay: NMFOverlay) -> Bool in
                            print("마커 터치")
                            createRequestMarkerInfoView()
                            return true
                        }
                    }
                }
                
            }
        }
        else if let findPets = pets as? [FindPetInfo] {
            DispatchQueue.global(qos: .default).async { [self] in
                // 백그라운드 스레드 (오버레이 객체 생성)
                
                for findPet in findPets {
                    print("Add Marker")
                    
                    let marker = NMFMarker(position: NMGLatLng(lat: findPet.latitude!, lng: findPet.longtitude!))
    
                    guard let imageString = findPet.imageString else { return }

                    guard let petImage = imageString.toImage() else { return }

                    guard let petImageCircleResize = petImage.circleReSize() else { return }
                        
                    marker.iconImage = NMFOverlayImage(image: petImageCircleResize)
                    
                    guard let time = findPet.time else { return }
                    
                    guard let location = findPet.location else { return }

                    guard let boardId = findPet.boardId else { return }
                    
                    marker.userInfo = ["FindTime": time, "BoradId": boardId, "Location": location]
                    
                    // 마커 초기값 저장
                    if findPet == findPets.first {
                        getMarker = marker
                    }
                    
                    markers.append(marker)
                    print("\(findPet.latitude), \(findPet.longtitude)")
                }

                DispatchQueue.main.async { [self] in
                    // 메인 스레드 (오버레이 객체 맵에 올림)
                    
                    for marker in markers {
                        
                        marker.mapView = self.naverMap.mapView
                       
                        func createFindMarkerInfoView() {
                            if self.markerInfoView.isHidden == true {
                                if let findTime = marker.userInfo["FindTime"] as? String {
                                    print(findTime)
                                    if let currentDate = "yyyy-MM-dd HH:mm:ss".currentKorDate().stringToDate() {
                                        print("현재 날짜 시간 \(currentDate)")
                                        print("String type 발견 날짜 시간 \(findTime)")
                                        if let findTime = findTime.stringToDate() {
                                            print("Date type 발견 날짜 시간 \(findTime)")
                                            self.remainTime = Int(currentDate.timeIntervalSince(findTime))
                                            print("골든 타임 남은 시간(초) \(self.remainTime)")
                                        }
                                    }
                                }
                                
                                if let findLocation = marker.userInfo["Location"] {
                                    self.addDetailLabel.text = "발견 위치 \(findLocation)"
                                    self.getMarker = marker
                                    self.getMarker?.captionText = "발견된 위치"
                                    self.getMarker?.captionColor = UIColor.red
                                }
                                
                                if let boardId = marker.userInfo["BoardId"] {
                                    // reportView(boardId)
                                }
                                self.titleLabel.text = "🚨 실종된 애완동물을 제보해주세요!"
                                self.boardButton.setTitle("의뢰글 보기", for: .normal)
                                self.markerInfoView.isHidden = false
                            }
                            else {
                                self.getMarker?.captionText = ""
                                self.markerInfoView.isHidden = true
                            }
                        }
                        
                        // 마커 초기값
                        if self.getMarker == marker {
                            createFindMarkerInfoView()
                        }
                        
                        marker.touchHandler = { (overlay: NMFOverlay) -> Bool in
                            print("마커 터치")
                            createFindMarkerInfoView()
                            return true
                        }
                    }
                }
            }
        }
    }

    
    func timerRun() {
        print("timerRun")
        if let timer = secondTimer {
            //timer 객체가 nil 이 아닌경우에는 invalid 상태에만 시작한다
            if !timer.isValid {
                // 1초마다 timerCallback함수를 호출하는 타이머
                secondTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(timerCallback), userInfo: nil, repeats: true)
            }
        } else {
            // timer 객체가 nil 인 경우에 객체를 생성하고 타이머를 시작한다
            // 1초마다 timerCallback함수를 호출하는 타이머
            secondTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(timerCallback), userInfo: nil, repeats: true)
        }
    }
    
    func timerQuit() {
        if let timer = secondTimer {
            if(timer.isValid){
                timer.invalidate()
            }
        }
    }
    
    // 뷰가 업데이트 할때마다 네트워크 요청
    //타이머가 호출하는 콜백함수
    @objc func timerCallback() {
        print("timercallback")
        if remainTime > 0 {
            remainTime = remainTime - 1
            goldenTimeLabel.text = "🛎 골든 타임 \(remainTime.hour)시간 \(remainTime.minute)분 \(remainTime.second)초"
        } else {
            goldenTimeLabel.text = "🛎 골든 타임 \(remainTime.hour)시간 \(remainTime.minute)분 \(remainTime.second)초"
        }
    }
    
    func mapView(_ mapView: NMFMapView, didTapMap latlng: NMGLatLng, point: CGPoint) {
        markerInfoView.isHidden = true
        self.getMarker?.captionText = ""
        print("지도 탭")
    }
    
    func alertOk( title: String, message: String, viewController: UIViewController ) {

        let alert = UIAlertController( title: title, message: message, preferredStyle: UIAlertController.Style.alert )
        
        let okAction = UIAlertAction( title: "OK", style: .default ) { (action) in }
        alert.addAction(okAction)
        
        viewController.present( alert, animated: false, completion: nil )

    }
    
//    func reportView(_ boardId: Int) {
//        guard let viewController = self.storyboard?.instantiateViewController(withIdentifier: "ReportDetailViewController") as? ReportDetailViewController else { return }
//        print(boardId)
//        self.navigationController?.pushViewController(viewController, animated: true)
//    }
    
    @IBAction func switchView(_ sender: Any) {
        if markers != [] {
            for marker in markers {
                marker.mapView = nil
            }
        }
        
        if reportSegment.selectedSegmentIndex == 0 {
            reportMode = .request
        } else if reportSegment.selectedSegmentIndex == 1 {
            reportMode = .find
        }
        
        updateReportUI(mode: reportMode)
    
    }
    
    @IBAction func viewBoardButtonTapped(_ sender: Any) {
        // 의뢰글 올려짐
//        self.performSegue(withIdentifier: "unwindToMainSetFindLocation", sender: self)
    }
    
    
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

}

extension String {
    func toImage() -> UIImage? {
        guard let url = URL(string: self) else { return nil }
        guard let data = try? Data(contentsOf: url) else { return nil }
        guard let image = UIImage(data: data) else { return nil }
        return image
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

