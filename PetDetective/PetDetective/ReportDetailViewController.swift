//
//  ReportDetailViewController.swift
//  PetDetective
//
//  Created by 고석준 on 2022/04/01.
//

import UIKit
import Alamofire

class ReportDetailViewController: UIViewController {
    
    @IBOutlet weak var petImageView: UIImageView!
    @IBOutlet weak var breedLabel: UILabel!
    @IBOutlet weak var furColorLabel: UILabel!
    @IBOutlet weak var missingDateLabel: UILabel!
    @IBOutlet weak var missingLocationLabel: UILabel!
    @IBOutlet weak var featureLabel: UILabel!
    @IBOutlet weak var moneyLabel: UILabel!
    @IBOutlet weak var sexSegControl: UISegmentedControl!
    @IBOutlet weak var operationSegControl: UISegmentedControl!
    @IBOutlet weak var diseaseLabel: UILabel!
    @IBOutlet weak var ageLabel: UILabel!
    @IBOutlet weak var etcTextView: UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    private func getInfo(){
        let url = "https://iospring.herokuapp.com/detect/4"
        AF.request(url)
            .validate(statusCode: 200..<500)
            .responseData { response in
                switch response.result {
                case .success:
                    debugPrint(response)
                case let .failure(error):
                    print(error)
                }
            }
    }
    
    @IBAction func testBtn(_ sender: UIBarButtonItem) {
        getInfo()
    }
    
}
