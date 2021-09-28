//
//  ViewController.swift
//  3week_WeatherDiary
//
//  Created by sumin on 2021/09/22.
//

import UIKit
import PhotosUI // 사진첩
import CoreLocation // 위치

class ViewController: UIViewController {

    @IBOutlet weak var txtUserName: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    
    var locationManager: CLLocationManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager = CLLocationManager() // 위치 권한 허용을 위한 객체 생성.
        locationManager.requestWhenInUseAuthorization() // 위치 권한 허용 요청.
        
        // 사진첩 권한 허용 요청 함수 호출.
        requestGalleryPermission()
        
        // (로그인한적 있다면) 자동 로그인
        if UserDefaults.standard.bool(forKey: "ISUSERLOGGEDIN") == true {
            let homeVc = self.storyboard?.instantiateViewController(withIdentifier: "HomeVC") as! HomeVC
            self.navigationController?.pushViewController(homeVc, animated: false)
        }
    }
    
    // MARK: - 사진첩 권한 허용 요청.
    func requestGalleryPermission(){
            PHPhotoLibrary.requestAuthorization( { status in
                switch status{
                case .authorized:
                    print("Gallery: 권한 허용")
                case .denied:
                    print("Gallery: 권한 거부")
                case .restricted, .notDetermined:
                    print("Gallery: 선택하지 않음")
                default:
                    break
                }
            })
    }
    
    
    // MARK: - (아이디 = test, 비밀번호 = test) 로그인.
    @IBAction func authenticateUser(_ sender: UIButton) {
        if txtUserName.text == "test" && txtPassword.text == "test" {
            //navigate to home screen
            UserDefaults.standard.set(true, forKey: "ISUSERLOGGEDIN")
            let homeVc = self.storyboard?.instantiateViewController(withIdentifier: "HomeVC") as! HomeVC
            self.navigationController?.pushViewController(homeVc, animated: true)
        }
    }
    
}
