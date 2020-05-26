//
//  ToDoListViewController.swift
//  ToDoApp
//
//  Created by 工藤海斗 on 2020/04/06.
//  Copyright © 2020 工藤海斗. All rights reserved.
//

import UIKit
import RealmSwift
import RxSwift
import DZNEmptyDataSet

class ToDoListViewController: UITableViewController, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate{
    
    var addToDoListViewModel = AddToDoListViewModel()
    var toDoLists : Results<ToDoModel>! //Realmから受け取るデータを入れる
    var observable : Observable<String>!
    let disposeBag = DisposeBag()
    let realm = try! Realm()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        print(Realm.Configuration.defaultConfiguration.fileURL!) // realmファイルのパスを取得してrealm blowserで確認
        //tableView.register(UINib(nibName: "CustomToDoCell", bundle: nil), forCellReuseIdentifier: "CustomToDoCell")
        //tableView.allowsMultipleSelectionDuringEditing = true
        navigationItem.rightBarButtonItem = editButtonItem
        tableView.emptyDataSetSource = self
        tableView.emptyDataSetDelegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        addToDoListViewModel.newCheckToDoList().subscribe(onNext : { toDoLists in
            print(toDoLists)
            self.toDoLists = toDoLists
        }, onError : { error in
            print(error)
        }, onCompleted:{
            print("completed")
        }, onDisposed: {
            print("disposed")
        }).disposed(by: disposeBag)
        tableView.reloadData()
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: true)
        tableView.isEditing = editing
    }
    
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        return NSAttributedString(string: "ToDoはありません")
    }
    
    func backgroundColor(forEmptyDataSet scrollView: UIScrollView!) -> UIColor! {
        return  UIColor(red: 232/255, green: 236/255, blue: 241/255, alpha: 1.0)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.toDoLists.isEmpty{
            tableView.separatorStyle = .none // 罫線を削除
            //debugPrint("toDoLists.count:\(toDoLists.count)")
        }
        else{
            tableView.separatorStyle = .singleLine // 罫線を引く
            //debugPrint("toDoLists.count:\(toDoLists.count)")
        }
        return self.toDoLists.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //if let cell = tableView.dequeueReusableCell(withIdentifier: "CustomToDoCell") as? CustomToDoCell{
            //cell.setToDoCell(todoList: self.toDoLists[indexPath.row].title, date: self.toDoLists[indexPath.row].date)
        /*let noToDoMessageCell = tableView.dequeueReusableCell(withIdentifier: "toDoCell", for: indexPath)
        if self.toDoLists.count == 0{
            noToDoMessageCell.textLabel?.text = self.noToDoMessage[indexPath.row]
            noToDoMessageCell.detailTextLabel?.text = ""
            return noToDoMessageCell
        }
        else{
        }*/
        //print(self.toDoLists.count)
        let cell = tableView.dequeueReusableCell(withIdentifier: "toDoCell", for: indexPath)
        cell.textLabel?.text = self.toDoLists?[indexPath.row].title
        cell.detailTextLabel?.text = self.toDoLists[indexPath.row].date
        self.tableView.tableFooterView = UIView() // 空のセルの罫線を消す。
        return cell
        
        //}
        //return UITableViewCell()
    }
    
    /*override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 140
    }*/
    
    /*override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true // trueを返すことでcellの編集を許可する
    }*/
    
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    // 並び替えが終わったタイミングで呼ばれるメソッド
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        try! realm.write({
            let sourceToDo = toDoLists[sourceIndexPath.row] // 元のデータの位置
            let destinationToDo = toDoLists[destinationIndexPath.row] // 移動先のデータの位置
            let destinationToDoOrder = destinationToDo.order //移動先のorderの値
            
            if sourceIndexPath.row < destinationIndexPath.row{
                // 上から下にcellを移動したとき、間にあるcellを上にシフトさせる
                for index in sourceIndexPath.row ... destinationIndexPath.row {
                    let toDoList = toDoLists[index]
                    toDoList.order -= 1
                    //print("toDoList.order:\(toDoList.order)")
                }
            }
            else{
                // 下から上に移動したとき、間にあるcellを下にシフトさせる
                for index in (destinationIndexPath.row ..< sourceIndexPath.row).reversed() {
                    let toDoList = toDoLists[index]
                    toDoList.order += 1
                    print("index:\(index)")
                    print("toDoList:\(toDoList)")
                    print("sourceIndexPath.row\(sourceIndexPath.row)")
                    print("destinationIndexPath.row:\(destinationIndexPath.row)")
                    print("toDoList.order:\(toDoList.order)")
                }
            }
            // 移動したセルの並びを移動先に更新
            sourceToDo.order = destinationToDoOrder
        })
    }
    
    // cellをスワイプして削除
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCell.EditingStyle.delete{
            
            try! realm.write({
                realm.delete(self.toDoLists[indexPath.row])
            })
            tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.automatic)
            print(self.toDoLists as Any)
        }
    }
    
    // 通常はcellに対して編集できない。編集ボタンを押すことで編集可能になる。
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        if tableView.isEditing{
            return UITableViewCell.EditingStyle.delete
        }
        else{
            return UITableViewCell.EditingStyle.none
        }
    }
}
