//
//  ReportDetailViewController.swift
//  PetDetective
//
//  Created by 고석준 on 2022/04/01.
//

import UIKit

class ReportDetailViewController: UIViewController {
    
    var reportId: Int?
    
    @IBOutlet weak var petImageView: UIImageView!
    @IBOutlet weak var breedLabel: UILabel!
    @IBOutlet weak var furColorLabel: UILabel!
    @IBOutlet weak var missingDateLabel: UILabel!
    @IBOutlet weak var missingLocationLabel: UILabel!
    @IBOutlet weak var featureLabel: UILabel!
    @IBOutlet weak var moneyLabel: UILabel!
    @IBOutlet weak var sexLabel: UILabel!
    @IBOutlet weak var operationLabel: UILabel!
    @IBOutlet weak var diseaseLabel: UILabel!
    @IBOutlet weak var ageLabel: UILabel!
    @IBOutlet weak var etcTextView: UITextView!
    @IBOutlet weak var myPostStackBtn: UIStackView!
    override func viewDidLoad() {
        super.viewDidLoad()
        myPostStackBtn.isHidden = true
        getInfo(id: self.reportId!)
    }
    
    private func getInfo(id: Int){
        guard let url = URL(string: "https://iospring.herokuapp.com/detect/\(id)") else {
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if(error != nil){
                    print(error.debugDescription)
                    return
                }
                else if( data != nil ){
                    do{
                        let decodedData = try JSONDecoder().decode(APIDetectDetailResponse.self, from: data!)
                        let url = URL(string: decodedData.mainImageUrl)
                        let data = try? Data(contentsOf: url!)
                        self.petImageView.image = UIImage(data: data!)
                        self.breedLabel.text = decodedData.breed
                        self.furColorLabel.text = decodedData.color
                        self.missingDateLabel.text = decodedData.missingTime
                        self.missingLocationLabel.text = decodedData.missingLocation
                        self.sexLabel.text = decodedData.gender
                        let operation = decodedData.operation
                        if(operation == true){
                            self.operationLabel.text = "유"
                        }
                        else{
                            self.operationLabel.text = "무"
                        }
                        self.featureLabel.text = decodedData.feature
                        let money = decodedData.money ?? 0
                        self.moneyLabel.text = String(money)
                        self.diseaseLabel.text = decodedData.disease
                        let age = decodedData.age ?? -1
                        self.ageLabel.text = String(age)
                        self.etcTextView.text = decodedData.content
                    }
                    catch{
                        print(error.localizedDescription)
                    }
                }
            }
        }
        task.resume()
    }
    
}
