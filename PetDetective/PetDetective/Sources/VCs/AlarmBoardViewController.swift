//
//  AlarmBoardViewController.swift
//  PetDetective
//
//  Created by 고석준 on 2022/04/27.
//

import UIKit

class AlarmBoardViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!

    var alarm = [Alarm]() {
        didSet {
            self.saveTasks()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadTasks() // userDefaults의 데이터 불러오기
        self.tableView.dataSource = self
        self.tableView.delegate = self
    }
    

    
    func saveTasks() {
        let data = self.alarm.map {
            [
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
        self.alarm = data.compactMap {
            guard let boardType = $0["boardType"] as? String else { return nil }
            guard let boardId = $0["boardId"] as? Int else { return nil }
            return Alarm(boardType: boardType, boardId: boardId)
        }
    }
}

extension AlarmBoardViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { // 행의 갯수 지정, 필수 기능 함수
        return self.alarm.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell { // 필수 기능 함수
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) // 화면에 나온 셀의 UI 재사용함으로 메모리 사용 줄임
//        let task = self.alarm[indexPath.row]
//        cell.textLabel?.text = alarm.title
//        if task.done {
//            cell.accessoryType = .checkmark   //task의 done이 true이면 check
//        } else {
//            cell.accessoryType = .none
//        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        // 셀이 다른 행으로 이동을 하면 원래의 셀이 어떤 위치로 이동했는지 알려줌
        var alarms = self.alarm
        let alarm = alarms[sourceIndexPath.row]
        alarms.remove(at: sourceIndexPath.row)
        alarms.insert(alarm, at: destinationIndexPath.row) // 진짜 data도 수정
        self.alarm = alarms
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        self.alarm.remove(at: indexPath.row) // 편집모드에서 -아이콘을 클릭했을 시 또는 스와이프 레프트 시, 해당 tasks정보 삭제
        tableView.deleteRows(at: [indexPath], with: .automatic) // tableView에 적용
    }
}

extension AlarmBoardViewController: UITableViewDelegate { // delegate property 지정
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) { //셀이 선택 되었을 때
        var alarm = self.alarm[indexPath.row] // 선택된 셀의 인덱스 값을 알려줌
        self.alarm[indexPath.row] = alarm
        self.tableView.reloadRows(at: [indexPath], with: .automatic) // 자동으로 적절한 애니메이션을 활용해 선택된 인덱스의 셀만 리로드
    }
}

