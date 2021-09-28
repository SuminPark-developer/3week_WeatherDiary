//
//  HomeVC.swift
//  3week_WeatherDiary
//
//  Created by sumin on 2021/09/22.
//

import UIKit
import CoreData

var diaryList = [Diary]()

class HomeVC: UIViewController {

    @IBOutlet weak var uiDiaryList: UITableView!
    var firstLoad = true
    
    // 지워질 애 뺀 나머지 데이터들.
    func nonDeleteDiary() -> [Diary] {
        var noDeleteDiaryList = [Diary]()
        for diary in diaryList {
            if diary.deletedDate == nil {
                noDeleteDiaryList.append(diary)
            }
        }
        return noDeleteDiaryList
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if firstLoad == true {
            firstLoad = false
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context: NSManagedObjectContext = appDelegate.persistentContainer.viewContext
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Diary")
            do {
                let results: NSArray = try context.fetch(request) as NSArray
                for result in results {
                    let diary = result as! Diary
                    diaryList.append(diary)
                }
            } catch {
                print("Fetch Failed")
            }
            
        }
        
        uiDiaryList.delegate = self
        uiDiaryList.dataSource = self

        // cell 리소스 파일 가져오기.
        let myTableViewCellNib = UINib(nibName: "DiaryTableViewCell", bundle: nil)
        // cell에 리소스 등록.
        self.uiDiaryList.register(myTableViewCellNib, forCellReuseIdentifier: "DiaryCell")
        
        // cell 높이 유동(self sizing table view cell)
        self.uiDiaryList.rowHeight = UITableView.automaticDimension
        self.uiDiaryList.estimatedRowHeight = 120
        
    }

    @IBAction func logoutUser(_ sender: UIButton) {
        UserDefaults.standard.set(false, forKey: "ISUSERLOGGEDIN")
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        uiDiaryList.reloadData()
    }
}

extension HomeVC: UITableViewDelegate, UITableViewDataSource {
    // 테이블 뷰 cell의 개수
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return nonDeleteDiary().count
    }
    // 각 cell에 대한 설정
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DiaryCell", for: indexPath) as! DiaryTableViewCell
        
        let diaryData: Diary = nonDeleteDiary()[indexPath.row]
        cell.uiTitle.text = diaryData.title
        cell.uiContents.text = diaryData.contents
        
        if diaryData.image != nil {
            cell.uiImage.image = UIImage(data: diaryData.image!)
        }
        
//        if ((selectedDiary?.image) != nil) { // 이미지 데이터가 있을 때에만,
//            imageView.image = UIImage(data: (selectedDiary?.image)!) // 이미지 표시
//        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "editDiary", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "editDiary" {
            let indexPath = uiDiaryList.indexPathForSelectedRow!
            let diaryDetail = segue.destination as? DiaryDetailVC
            let selectedDiary: Diary!
            selectedDiary = nonDeleteDiary()[indexPath.row]
            diaryDetail!.selectedDiary = selectedDiary
            
            uiDiaryList.deselectRow(at: indexPath, animated: true)
        }
    }
    
}


