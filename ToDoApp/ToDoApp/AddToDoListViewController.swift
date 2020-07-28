//
//  AddToDoListViewController.swift
//  ToDoApp
//
//  Created by 工藤海斗 on 2020/04/06.
//  Copyright © 2020 工藤海斗. All rights reserved.
//

import UIKit
import RealmSwift
import RxSwift
import FirebaseDatabase

class AddToDoListViewController: UIViewController,UITextFieldDelegate {
    
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var checkButton: UIButton!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var dateLabel: UILabel!
    let currentDateFormatter = DateFormatter()
    let addToDoListViewModel = AddToDoListViewModel()
    var toDoLists : Results<ToDoModel>! //Realmから受け取るデータを入れる
    var databaseRef:DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        currentDateFormatter.dateFormat = "yyyy/MM/dd  HH:mm"
        textField.delegate = self
        textField.placeholder = "ToDoリストに追加したいことを入力してください"
        checkButton.isEnabled = false
        // RealmのTodoリストを取得
        let realm = try! Realm()
        toDoLists = realm.objects(ToDoModel.self)
        datePicker.locale = Locale(identifier: "ja_JP")
        dateLabel.text = currentDateFormatter.string(from: Date())
        databaseRef = Database.database().reference() // インスタンスを取得
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        validate()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func validate() { // テキストフィールドが空かどうかチェック
        guard let textData = textField.text else {
            self.checkButton.isEnabled = false
            return
        }
        if textData.count == 0{
            self.checkButton.isEnabled = false
        }
        else{
            self.checkButton.isEnabled = true
        }
    }
    
    @IBAction func textEditingChanged(_ sender: Any) {
        validate()
    }
    
    @IBAction func AddToDoList(_ sender: Any) {
        
        let realm = try! Realm()
        let toDoModel:ToDoModel = ToDoModel()
        
        toDoModel.title = self.textField.text!
        toDoModel.date = addToDoListViewModel.format(date: datePicker.date)
        try! realm.write({ // データベースへの書き込み
            realm.add(toDoModel)
        })
        
        textField.text = ""
        textField.placeholder = "ToDoリストに追加したいことを入力してください"
        checkButton.isEnabled = false
        
        // firebaseにアクセスしてデータの書き込み
        //let todoDic = ["title":toDoModel.title, "date":toDoModel.date]
        //databaseRef.childByAutoId().setValue(todoDic)
        /*databaseRef.child("todo").updateChildValues(todoDic, withCompletionBlock: { (error, reference) in
            if error != nil{
                print("書き込み時にエラーが発生しました。")
                return
            }
        })*/
    }
    
    @IBAction func dateChanged(_ sender: Any) {
        dateLabel.text = addToDoListViewModel.format(date: datePicker.date)
    }
    
}
