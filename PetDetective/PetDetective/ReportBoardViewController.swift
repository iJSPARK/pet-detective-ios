//
//  ReportBoardViewController.swift
//  PetDetective
//
//  Created by 고석준 on 2022/03/23.
//

import UIKit

class ReportBoardViewController: UIViewController {
    
    @IBOutlet weak var addFloatBtn: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    
    
    private var reportList = [Report](){
        // 프로퍼티 옵저버
        didSet {
          self.saveReportList()
            // 다이어리 리스트의 변화가 있을 때마다 userDefaults에 저장
        }
      }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.addFloatBtn.layer.borderWidth = 1
        self.addFloatBtn.layer.borderColor = UIColor.red.cgColor
        self.addFloatBtn.frame.size = CGSize(width: 300, height: 50)
        self.addFloatBtn.frame.origin = CGPoint(x: self.view.frame.width/2 - self.addFloatBtn.frame.width/2, y: self.view.frame.height - 100)
    }
    
    private func saveReportList() {
        self.collectionView.reloadData()
    }
    
    private func configureCollectionView() {
        self.collectionView.collectionViewLayout = UICollectionViewFlowLayout()
        // 콜렉션뷰의 레이아웃을 플로우 레이아웃으로 채택
        self.collectionView.contentInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        // 컨텐츠들의 좌우위아래로 여백 10
        self.collectionView.delegate = self  // 하단 extension 참조
        self.collectionView.dataSource = self // 하단 extension 참조
    }
    
}
extension ReportBoardViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.reportList.count
    }
    // 지정된 섹션의 표시할 셀의 개수 = 다이어리 리스트의 갯수
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ReportBoardCell", for: indexPath) as? ReportBoardCell else { return UICollectionViewCell() }
        // 재사용 가능한 셀을 찾고 재사용하여 메모리 사용량을 낮춤
        let report = self.reportList[indexPath.row]
//        cell.petInfo.text = report.title
//        cell.date.text = self.dateToString(date: report.date) // date->String
        return cell
    }
    // 컬렉션 뷰의 지정된 위치에 표시할 셀을 요청하는 함수
}


extension ReportBoardViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (UIScreen.main.bounds.width / 2) - 20, height: 200)
    }
    // 표시할 셀의 사이즈를 설정. 행에 셀 2개씩 구현할 예정
}

extension ReportBoardViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // 일기장 리스트 화면에서 일기를 선택했을 때 일기 상세 페이지로 넘어가는 코드
        // didSelectItemAt: 특정 셀이 선택되었을 때 동작
        guard let viewContoller = self.storyboard?.instantiateViewController(identifier: "ReportDetailViewController") as? ReportWriteViewController else { return }
        //DiaryDetailViewController를 인스턴스화
        let report = self.reportList[indexPath.row]
        viewContoller.report = report
        viewContoller.indexPath = indexPath
        self.navigationController?.pushViewController(viewContoller, animated: true)
        // 일기장 상세화면 푸시
    }
}
