//
//  CalendarViewController.swift
//  ToDoApp
//
//  Created by 工藤海斗 on 2020/04/19.
//  Copyright © 2020 工藤海斗. All rights reserved.
//

import UIKit
import RealmSwift
import FSCalendar
import CalculateCalendarLogic
import DZNEmptyDataSet

class CalendarViewController: UIViewController, FSCalendarDelegate, FSCalendarDataSource, FSCalendarDelegateAppearance, UITableViewDelegate, UITableViewDataSource, DZNEmptyDataSetDelegate, DZNEmptyDataSetSource {
    
    @IBOutlet weak var calendar: FSCalendar!
    @IBOutlet weak var todayScheduleTableView: UITableView!
    @IBOutlet weak var dayLable: UILabel!
    
    let calendarViewModel = CalendarViewModel()
    let dayOfTheWeeks = ["日":0, "月":1, "火":2, "水":3, "木":4, "金":5, "土":6]
    var toDoLists : Results<ToDoModel>!
    let realm = try! Realm() // RealmのTodoリストを取得

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        calendar.delegate = self
        calendar.dataSource = self
        calendar.appearance.headerDateFormat = "yyyy年MM月"
        todayScheduleTableView.delegate = self
        todayScheduleTableView.dataSource = self
        todayScheduleTableView.emptyDataSetSource = self
        todayScheduleTableView.emptyDataSetDelegate = self
        
        for (key, value) in self.dayOfTheWeeks {
            self.calendar.calendarWeekdayView.weekdayLabels[value].text = key
        }
    
        // RealmのTodoリストを取得
        toDoLists = realm.objects(ToDoModel.self)
        
        let todayFilter = "\(calendarViewModel.getYear(date: Date()))/\(calendarViewModel.getMonth(date: Date()))/\(calendarViewModel.getDay(date: Date()))"
        toDoLists = toDoLists.filter("date LIKE '\(todayFilter)*' ")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        todayScheduleTableView.reloadData()
        calendar.reloadData()
    }
    
    // 土日・祝日の文字色を変える
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, titleDefaultColorFor date: Date) -> UIColor? {
        //祝日判定をする（祝日は赤色で表示する）
        if self.calendarViewModel.judgeHoliday(date: date){
            return UIColor.red
        }
        //土日の判定を行う（土曜日は青色、日曜日は赤色で表示する）
        let weekDay = self.calendarViewModel.getWeekIndex(date: date)
        if weekDay == 1 { // 日曜日
            return UIColor.red
        }
        else if weekDay == 7 { // 土曜日
            return UIColor.blue
        }
        
        return nil
    }
    
    // カレンダーのタップイベント
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        toDoLists = calendarViewModel.searchToDoList(date: date)
        //print(toDoLists as Any)
        self.todayScheduleTableView.reloadData()
        let tmpDate = Calendar(identifier: .gregorian)
        let month = tmpDate.component(.month, from: date)
        let day = tmpDate.component(.day, from: date)
        dayLable.text = "\(month)月\(day)日の予定"
    }
    
    // 予定がある日にカレンダーに点を描画
    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int{
        var plansToDoLists : Results<ToDoModel>
        plansToDoLists = calendarViewModel.searchToDoList(date: date)
        return plansToDoLists.count
    }
    
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        return NSAttributedString(string: "この日の予定はありません")
    }
    
    func backgroundColor(forEmptyDataSet scrollView: UIScrollView!) -> UIColor! {
        return  UIColor(red: 232/255, green: 236/255, blue: 241/255, alpha: 1.0)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if toDoLists.count == 0{
            tableView.separatorStyle = .none // 罫線を削除
        }
        else{
            tableView.separatorStyle = .singleLine
        }
        return toDoLists.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = todayScheduleTableView.dequeueReusableCell(withIdentifier: "todayScheduleCell", for: indexPath)
        cell.textLabel?.text = toDoLists[indexPath.row].title
        tableView.tableFooterView = UIView() // 空のセルの罫線を消す。
        return cell
    }
    
}
