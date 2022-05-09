//
//  AlarmBoardViewController.swift
//  PetDetective
//
//  Created by 고석준 on 2022/04/27.
//

import UIKit

class AlarmBoardViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!

    var alarms = [Alarm]() {
        didSet {
            self.saveTasks()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let nibName = UINib(nibName: "AlarmCell", bundle: nil)
        tableView.register(nibName, forCellReuseIdentifier: "AlarmCell")
        
        self.loadTasks() // userDefaults의 데이터 불러오기
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.refreshControl = UIRefreshControl()
        self.tableView.refreshControl?.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        refreshData()
    }
    
    @objc private func refreshData(){
        loadTasks()
        tableView.reloadData()
    }
    
    func saveTasks() {
        let data = self.alarms.map {
            [
                "alarmMode": $0.alarmMode,
                "boardType": $0.boardType,
                "boardId": $0.boardId
            ]
        }
        let userDefaults = UserDefaults.standard
        userDefaults.set(data, forKey: "petAlarm")
    }
    
    func loadTasks() {
        let userDefaults = UserDefaults.standard
        guard let data = userDefaults.object(forKey: "petAlarm") as? [[String: Any]] else { return }
        self.alarms = data.compactMap {
            guard let alarmMode =  $0["alarmMode"] as? String else { return nil }
            guard let boardType = $0["boardType"] as? String else { return nil }
            guard let boardId = $0["boardId"] as? Int else { return nil }
            return Alarm(alarmMode: alarmMode, boardType: boardType, boardId: boardId)
        }
        self.tableView.refreshControl?.endRefreshing()
    }
}

extension AlarmBoardViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { // 행의 갯수 지정, 필수 기능 함수
        return self.alarms.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell { // 필수 기능 함수
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "AlarmCell", for: indexPath) as? AlarmCell else { return UITableViewCell() }
        let alarm = self.alarms[indexPath.row]
        cell.alarmTitle.text = alarm.boardType
//        cell.alarmBody.text = String(alarm.boardId)
        if( alarm.alarmMode == "게시글 작성"){
            if( alarm.boardType == "의뢰"){
                cell.alarmBody.text = "새로운 의뢰가 들어왔어요!"
            }
            else if ( alarm.boardType == "보호" ){
                cell.alarmBody.text = "반려견과 비슷한 친구가 보호 중이에요!"
            }
            else if ( alarm.boardType == "발견" ){
                cell.alarmBody.text = "반려견과 비슷한 친구가 제보가 되었어요!"
            }
        }
        else if(alarm.alarmMode == "골든타임"){
            
        }
        
        return cell
    }

    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        self.alarms.remove(at: indexPath.row) // 편집모드에서 -아이콘을 클릭했을 시 또는 스와이프 레프트 시, 해당 tasks정보 삭제
        tableView.deleteRows(at: [indexPath], with: .automatic) // tableView에 적용
    }
}

extension AlarmBoardViewController: UITableViewDelegate { // delegate property 지정
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) { //셀이 선택 되었을 때
        let alarm = self.alarms[indexPath.row] // 선택된 셀의 인덱스 값을 알려줌
        let mode = alarm.alarmMode
        let type = alarm.boardType
        let id = alarm.boardId
        if(mode == "board"){
            if(type == "report"){
                guard let viewController = self.storyboard?.instantiateViewController(withIdentifier: "ReportDetailViewController") as? ReportDetailViewController else { return }
                viewController.reportId = id
                self.navigationController?.pushViewController(viewController, animated: true)
            }
            else{
                guard let viewController = self.storyboard?.instantiateViewController(withIdentifier: "DetectDetailViewController") as? DetectDetailViewController else { return }
                viewController.findId = id
                self.navigationController?.pushViewController(viewController, animated: true)
            }
        }
        else if(mode == "goldenTime"){

        }
    }
}

