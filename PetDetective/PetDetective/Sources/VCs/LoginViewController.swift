//
//  LoginViewController.swift
//  PetDetective
//
//  Created by 고석준 on 2022/05/02.
//

import UIKit
import Alamofire

class LoginViewController: UIViewController {

    @IBOutlet weak var cellphoneTextField: UITextField!
    private var phoneNumber: String = ""
    @IBOutlet weak var authBtn: UIButton!
    private var cernum: String = "-1"
    @IBOutlet weak var sendAuthBtn: UIButton!
    @IBOutlet weak var emailTextField: UITextField!
    private var email:String = ""
    @IBOutlet weak var locationTextField: UITextField!
    private var longitude: Double = 0.0
    private var latitude: Double = 0.0
    private var address: String = "서울"
    @IBOutlet weak var getLocBtn: UIButton!
    @IBOutlet weak var submitBtn: UIButton!
    @IBOutlet weak var cancleBtn: UIButton!
    @IBOutlet weak var reGetPNBtn: UIButton!
    
    var needjoin: Bool = true
    private var deviceToken: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        cellphoneTextField.keyboardType = .numberPad 
        loadDeviceToken()
    }
    
    private func loadDeviceToken(){
        let userDefaults = UserDefaults.standard
        guard let data = userDefaults.object(forKey: "petDeviceToken") as? String else { return }
        self.deviceToken = data
    }
    
    @IBAction func authenticationBtn(_ sender: UIButton) {
        self.phoneNumber = cellphoneTextField.text!
        self.view.endEditing(true)
        self.cellphoneTextField.text = ""
        self.cellphoneTextField.placeholder = "인증번호 입력"
        self.authBtn.isHidden = true
        self.sendAuthBtn.isHidden = false
        self.reGetPNBtn.isHidden = false
        
        let url = "https://iospring.herokuapp.com/check/sendSMS"
        
        AF.upload(multipartFormData: {multipartFormData in
            multipartFormData.append("\(self.phoneNumber)".data(using: String.Encoding.utf8)!, withName: "phoneNumber")
            multipartFormData.append("\(self.deviceToken)".data(using: String.Encoding.utf8)!, withName: "diviceToken")
        }, to: url, method: .post)
        .validate(statusCode: 200..<500)
        .responseData { response in
            switch response.result {
            case .success:
                if let data = response.data {
                    do{
                        let decodedData = try JSONDecoder().decode(GetCertificationNumber.self, from: data)
                        self.cernum = decodedData.cernum
                        self.needjoin = decodedData.needjoin
                    } catch {
                        print(error)
                    }
                }
            case let .failure(error):
                print(error)
            }
        }
    }

    
    @IBAction func secondAuthFunc(_ sender: UIButton) {
        self.view.endEditing(true)
        self.sendAuthBtn.isHidden = true
        if(self.cernum == cellphoneTextField.text!){
            if ( self.needjoin == true){
                emailTextField.isHidden = false
                locationTextField.isHidden = false
                getLocBtn.isHidden = false
                submitBtn.isHidden = false
                cancleBtn.isHidden = false
                reGetPNBtn.isHidden = true
            }
            else{
                print("로그인 완료")
            }
        }
        else{
            self.cellphoneTextField.text = ""
            self.cellphoneTextField.placeholder = "인증번호가 틀렸습니다."
        }
        
    }
    @IBAction func reGetPN(_ sender: UIButton) {
        self.authBtn.isHidden = false
        self.sendAuthBtn.isHidden = true
        self.reGetPNBtn.isHidden = true
        self.cernum = "-1"
        self.phoneNumber = "-1"
    }
    
    @IBAction func getLocation(_ sender: UIButton) {
        print("location")
        //준서 파트
    }
    @IBAction func submitInfo(_ sender: UIButton) {
        let url = "https://iospring.herokuapp.com/join"
        
        self.email = emailTextField.text!
        
        AF.upload(multipartFormData: {multipartFormData in
            multipartFormData.append("\(self.phoneNumber)".data(using: String.Encoding.utf8)!, withName: "phoneNumber")
            multipartFormData.append("\(self.deviceToken)".data(using: String.Encoding.utf8)!, withName: "deviceToken")
            multipartFormData.append("\(self.email)".data(using: String.Encoding.utf8)!, withName: "email")
            multipartFormData.append("\(self.address)".data(using: String.Encoding.utf8)!, withName: "loadAddress")
            multipartFormData.append("\(self.latitude)".data(using: String.Encoding.utf8)!, withName: "latitude")
            multipartFormData.append("\(self.longitude)".data(using: String.Encoding.utf8)!, withName: "longitude")
        }, to: url, method: .post)
        .validate(statusCode: 200..<500)
        .responseData { response in
            switch response.result {
            case .success:
                if let data = response.data {
                    do{
                        debugPrint(response)
                        let decodedData = try JSONDecoder().decode(PassCertification.self, from: data)
//                        let userDefaults = UserDefaults.standard
//                        userDefaults.set(decodedData.id, forKey: "petUserId")
                        print(decodedData.id)
                    } catch {
                        print(error)
                    }
                }
            case let .failure(error):
                print(error)
            }
        }
    }
    @IBAction func cancleAll(_ sender: UIButton) {
        self.cellphoneTextField.isHidden = false
        self.authBtn.isHidden = false
        self.emailTextField.isHidden = true
        self.locationTextField.isHidden = true
        self.getLocBtn.isHidden = true
        self.cancleBtn.isHidden = true
        self.submitBtn.isHidden = true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
}
