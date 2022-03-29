//
//  ReportDetailViewController.swift
//  PetDetective
//
//  Created by 고석준 on 2022/03/23.
//

import UIKit
import WebKit
import Alamofire

enum ReportEditorMode{
    case new
    case edit(IndexPath, Report)
}

class ReportWriteViewController: UIViewController {
    
    var report: Report?
    var indexPath: IndexPath?
    var pet: Pet?
    var petId: Int?
    var boardId: Int?
    var userId: Int?
    @IBOutlet weak var petImageView: UIImageView!
    let imagePicker = UIImagePickerController()
    @IBOutlet weak var breedTextField: UITextField!
    @IBOutlet weak var furColorTextField: UITextField!
    @IBOutlet weak var dateTextField: UITextField!
    private var reportDate: Date?
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var featureTextField: UITextField!
    @IBOutlet weak var moneyTextField: UITextField!
    @IBOutlet weak var sexSegControl: UISegmentedControl!
    @IBOutlet weak var neuteringSegControl: UISegmentedControl!
    @IBOutlet weak var diseaseTextField: UITextField!
    @IBOutlet weak var ageTextField: UITextField!
    @IBOutlet weak var etcTextView: UITextView!
    @IBOutlet weak var confirmBtn: UIBarButtonItem!
    var reportEditMode: ReportEditorMode = .new
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureImg()
        self.configureDatePicker()
        //        self.confirmBtn.isEnabled = false
    }
    
    private func configureImg(){
        self.imagePicker.sourceType = .photoLibrary // 앨범에서 가져옴
        self.imagePicker.allowsEditing = true // 수정 가능 여부
        self.imagePicker.delegate = self // picker delegate
        self.petImageView.layer.borderWidth = 1
        self.petImageView.layer.borderColor = UIColor.gray.cgColor
    }
    
    private func configureDatePicker(){
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .dateAndTime
        datePicker.addTarget(self, action: #selector(dateChange(datePikcer:)), for: UIControl.Event.valueChanged)
        datePicker.frame.size = CGSize(width: 0, height: 300)
        datePicker.preferredDatePickerStyle = .wheels
        dateTextField.inputView = datePicker
        dateTextField.text = formatDate(date: Date())
        reportDate = Date()
    }
    
    private func configureEditMode(){
        switch self.reportEditMode {
        case let .new:
            break
        case let .edit(_, report):
            self.boardId = report.boardId
            self.userId = report.userId
            self.petId = report.petId
            self.dateTextField.text = self.formatDate(date: report.missingTime)
            self.locationTextField.text = report.missingLocation
//            self.moneyTextField.text = report.money
        }
    }
    
    @IBAction func tabConfirmBtn(_ sender: UIBarButtonItem) {
        //        print("hi")
        guard let breed = self.breedTextField.text else { return }
        //        print(breed)
        guard let color = self.furColorTextField.text else { return }
        //        print(color)
        guard let date = self.reportDate else { return }
        //        print(date)
        guard let location = self.locationTextField.text else { return }
        //        print(location)
        guard let money = self.moneyTextField.text else { return }
        //        print(money)
        let sexArray = ["남", "여", "모름"]
        let sex = sexArray[self.sexSegControl.selectedSegmentIndex]
        //        print(sex)
        let operationArray = ["유", "무", "모름"]
        let operation = operationArray[self.neuteringSegControl.selectedSegmentIndex]
        //        print(operation)
        guard let disease = self.diseaseTextField.text else { return }
        //        print(disease)
        guard let ageStr = self.ageTextField.text else { return }
        //        print(ageStr)
        guard let etc = self.etcTextView.text else { return }
        //        print(etc)
        postInfo(missingTime: dateTextField.text!, missingLocation: location)
    }
    
    private func postInfo(missingTime: String, missingLocation: String){
        let url = "https://iospring.herokuapp.com/find"
        let param = [
            "missingTime": missingTime,
            "missingLocation": missingLocation
        ]
        AF.request(url, parameters: param, encoding: JSONEncoding.default)
            .validate(statusCode: 200..<300)
            .responseJSON{(json) in
                print(json)
            }
    }
    
    func formatDate(date: Date) -> String{
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYY년 MMMM dd일 HH:mm"
        return formatter.string(from: date)
    }
    
    @objc func dateChange(datePikcer: UIDatePicker){
        dateTextField.text = formatDate(date: datePikcer.date)
        self.reportDate = datePikcer.date
    }
    
    @IBAction func pickImg(_ sender: UIButton) {
        self.present(self.imagePicker, animated: true)
    }
    
    func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size
        
        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height
        
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        }
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    } // 유저가 빈 화면을 터치하면 키보드나 피커가 다시 내려감
}

extension ReportWriteViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        var newImage: UIImage? = nil // update 할 이미지
        
        if let possibleImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            newImage = possibleImage // 수정된 이미지가 있을 경우
        } else if let possibleImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            newImage = possibleImage // 원본 이미지가 있을 경우
        }
        let resizedImg = resizeImage(image: newImage!, targetSize: CGSize(width: 224.0, height: 224.0))
        self.petImageView.image = resizedImg // 받아온 이미지를 update
        picker.dismiss(animated: true, completion: nil) // picker를 닫아줌
        
    }
}

