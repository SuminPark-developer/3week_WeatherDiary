//
//  DiaryDetailVC.swift
//  3week_WeatherDiary
//
//  Created by sumin on 2021/09/23.
//

import UIKit
import CoreData
import CoreLocation
import PhotosUI

class DiaryDetailVC: UIViewController, UINavigationControllerDelegate {

    @IBOutlet weak var titleTF: UITextField!
    @IBOutlet weak var contentsTV: UITextView!
    @IBOutlet weak var openImageBtn: UIButton!
    
    @IBOutlet weak var imageView: UIImageView!
    var imagePicker = UIImagePickerController()
    var arrPhotos: [Diary]?
    
    // api 호출을 통해 받아온 데이터를 저장할 프로퍼티
    var weather: Weather?
    var main: Main?
    var name: String?
    // 상단 날씨 아이콘 & 현재 온도
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var tempLabel: UILabel!
    
    var selectedDiary: Diary? = nil
    
    let locationManager: CLLocationManager = CLLocationManager() // 앱에서 위치 관련 이벤트 전달을 시작하고 중지하는 데 사용하는 개체
    var currentLocation: CLLocationCoordinate2D!
    let photoAuthorizationStatus = PHPhotoLibrary.authorizationStatus() // 사진 라이브러리의 승인상태를 체크하는 값
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        openImageBtn.layer.borderWidth = 1.5
        openImageBtn.layer.borderColor = #colorLiteral(red: 0.9254901961, green: 0.9254901961, blue: 0.8901960784, alpha: 1)
        openImageBtn.layer.cornerRadius = 10
        
        contentsTV.layer.cornerRadius = 10
        
        
        if selectedDiary != nil { // 이미 작성했던 일기 편집이면,
            titleTF.text = selectedDiary?.title
            contentsTV.text = selectedDiary?.contents
            tempLabel.text = selectedDiary?.temperature
            if ((selectedDiary?.weatherImage) != nil) { // 상단 - 날씨 아이콘 이미지 데이터가 있을 때에만,
                iconImageView.image = UIImage(data: (selectedDiary?.weatherImage)!) // 날씨 아이콘 표시
            }
            
            if ((selectedDiary?.image) != nil) { // 하단 - (사진첩) 이미지 데이터가 있을 때에만,
                imageView.image = UIImage(data: (selectedDiary?.image)!) // (사진첩) 이미지 표시
            }
        }
        else { // 새로운 일기 작성이면,
            checkLocationAuth() // 위치 권한 상태 확인 함수 호출.
        }
        
        iconImageView.layer.borderWidth = 1.5
        iconImageView.layer.borderColor = UIColor.systemGray6.cgColor
        iconImageView.layer.cornerRadius = iconImageView.frame.height / 2 // 동그랗게 설정.
        
    }
    
    // MARK: - 상단 현재 날씨 아이콘 & 현재 온도 세팅.
    private func setWeatherUI() {
        let url = URL(string: "https://openweathermap.org/img/wn/\(self.weather?.icon ?? "00")@2x.png")
        let data = try? Data(contentsOf: url!)
        if let data = data {
            iconImageView.image = UIImage(data: data)
        }
        
        let celsiusUnit = UnitTemperature.celsius // 섭씨로 변경할 예정
        let celsiusTemp = celsiusUnit.converter.value(fromBaseUnitValue: main!.temp) // 켈빈을 섭씨로 변경
        tempLabel.text = String(format: "%.2f", celsiusTemp) + " ℃"
    }
    
    // MARK: - 위치 권한 상태 확인.
    func checkLocationAuth() {
        switch locationManager.authorizationStatus {
        case .authorizedAlways, .authorizedWhenInUse:
            print("위치 접근 허가 됨.")
            locationManager.delegate = self
            locationManagerDidChangeAuthorization(locationManager)
        case .restricted, .notDetermined: // 아직 결정하지 않은 상태: 시스템 팝업 호출
            print("위치 접근 허가 필요함.")
            locationManager.requestWhenInUseAuthorization() // 허가 요청 창 띄우기.
            locationManager.delegate = self
            locationManagerDidChangeAuthorization(locationManager)
        case .denied: // 거부인 상태: 설정 창으로 가서 권한을 변경하도록 유도
            setLocationAuthAlertAction()
        @unknown default:
            return
        }
        
    }
    
    // MARK: - 경고 문구 및 위치 권한 설정으로 이동.
    func setLocationAuthAlertAction() {
        let authAlertController: UIAlertController
        authAlertController = UIAlertController(title: "위치 권한 요청", message: "위치 권한을 허용해야만 앱을 사용하실 수 있습니다.", preferredStyle: UIAlertController.Style.alert) // 알람 제목, 문구를 설정함.
        
        let getAuthAction: UIAlertAction
        getAuthAction = UIAlertAction(title: "네 알겠습니다.", style: UIAlertAction.Style.default, handler: { (UIAlertAction) in
            if let appSettings = URL(string: UIApplication.openSettingsURLString){
                UIApplication.shared.open(appSettings, options: [:], completionHandler: nil)
            }
        })
        authAlertController.addAction(getAuthAction)
        self.present(authAlertController, animated: true, completion: nil)
    }
    
    // MARK: - 경고 문구 및 사진첩 권한 설정으로 이동.
    func setPhotoAuthAlertAction() {
        let authAlertController: UIAlertController
        authAlertController = UIAlertController(title: "사진첩 권한 요청", message: "사진첩 권한을 허용해야만 앱을 사용하실 수 있습니다.", preferredStyle: UIAlertController.Style.alert) // 알람 제목, 문구를 설정함.
        
        let getAuthAction: UIAlertAction
        getAuthAction = UIAlertAction(title: "네 알겠습니다.", style: UIAlertAction.Style.default, handler: { (UIAlertAction) in
            if let appSettings = URL(string: UIApplication.openSettingsURLString){
                UIApplication.shared.open(appSettings, options: [:], completionHandler: nil)
            }
        })
        authAlertController.addAction(getAuthAction)
        self.present(authAlertController, animated: true, completion: nil)
    }
                                       
    // MARK: - 뒤로가기 버튼 클릭 시,
    @IBAction func backDiary(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: - 이미지 선택 버튼 클릭 시,
    @IBAction func pickImageButtonPressed(_ sender: UIButton) {
        
        switch photoAuthorizationStatus {
        case .authorized:
            print("사진첩 접근 허가 됨.")
            self.openImagePicker() // 접근 허가된 상황이니까, 이미지를 고르게 한다.
        case .denied, .notDetermined, .restricted, .limited:
            print("접근 허가 안됨.")
            setPhotoAuthAlertAction() // 접근 거부된 상황이라면, AlertAction을 수행한다.
        @unknown default:
            return
        }
    }
    
    // MARK: - 저장 버튼 클릭 시,
    @IBAction func saveAction(_ sender: Any) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context: NSManagedObjectContext = appDelegate.persistentContainer.viewContext
        
        if selectedDiary == nil { // 새로운 일기 작성
            let entity = NSEntityDescription.entity(forEntityName: "Diary", in: context)
            let newDiary = Diary(entity: entity!, insertInto: context)
            // 일기 id, 제목, 내용 저장.
            newDiary.id = diaryList.count as NSNumber
            newDiary.title = titleTF.text
            newDiary.contents = contentsTV.text
            // 상단 - 날씨 아이콘 & 현재 온도 저장.
            newDiary.temperature = tempLabel.text
            newDiary.weatherImage = self.iconImageView.image?.jpegData(compressionQuality: 1.0)
            
            // 하단 - 사용자가 사진첩에서 고른 이미지 저장.
            // newDiary.image = self.imageView.image?.pngData()
            newDiary.image = self.imageView.image?.jpegData(compressionQuality: 1.0)
            
            do {
                try context.save()
                diaryList.append(newDiary)
                navigationController?.popViewController(animated: true)
            }
            catch  {
                print("context save error.")
            }
        }
        else { // 이미 작성했던 일기 편집
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Diary")
            do {
                let results: NSArray = try context.fetch(request) as NSArray
                for result in results {
                    let diary = result as! Diary
                    if diary == selectedDiary {
                        diary.title = titleTF.text
                        diary.contents = contentsTV.text
                        
//                        diary.image = self.imageView.image?.pngData() // 이미지 가끔 돌아가는 이유 - https://stackoverflow.com/questions/10245649/iphone-uiimage-loaded-from-core-data-is-rotated-counterclockwise-by-90-degrees
                        diary.image = self.imageView.image?.jpegData(compressionQuality: 1.0) // png -> jpeg로 바꾸니 해결.
                        try context.save()
                        navigationController?.popViewController(animated: true)
                    }
                }
            } catch {
                print("Fetch Failed")
            }
        }
        
    }
    
    // MARK: - delete버튼 클릭 시,
    @IBAction func DeleteDiary(_ sender: UIButton) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context: NSManagedObjectContext = appDelegate.persistentContainer.viewContext
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Diary")
        do {
            let results: NSArray = try context.fetch(request) as NSArray
            for result in results {
                let diary = result as! Diary
                if diary == selectedDiary {
                    diary.deletedDate = Date()
                    try context.save()
                    navigationController?.popViewController(animated: true)
                }
            }
        } catch {
            print("Fetch Failed")
        }
        
    }
    
}

// MARK: - 이미지 CoreData : https://cb510.medium.com/saving-images-to-core-data-in-ios-473b92d5fd4f
extension DiaryDetailVC: UIImagePickerControllerDelegate {
    func openImagePicker() {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            imagePicker.delegate = self
            imagePicker.sourceType = .photoLibrary
            imagePicker.allowsEditing = false
            present(imagePicker, animated: true, completion: nil)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        dismiss(animated: true, completion: nil)
        if let img = info[.originalImage] as? UIImage {
            self.imageView.image = img
        }
    }
}

// MARK: - 현재 권한 상태 확인 및 현재 위치(경도, 위도) => 데이터 패치
extension DiaryDetailVC: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if manager.authorizationStatus == .authorizedWhenInUse {
            
            currentLocation = locationManager.location?.coordinate
            print(currentLocation.latitude) // 위도
            print(currentLocation.longitude) // 경도
            
            // data fetch
            WeatherService(currentLocation.latitude, currentLocation.longitude).getWeather { result in
                switch result {
                case .success(let weatherResponse):
                    DispatchQueue.main.async {
                        self.weather = weatherResponse.weather.first
                        self.main = weatherResponse.main
                        self.name = weatherResponse.name
                        self.setWeatherUI()
                    }
                case .failure(_ ):
                    print("error")
                }
            }
            
        }
    }
}
