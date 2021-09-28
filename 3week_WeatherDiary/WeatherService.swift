//
//  WeatherService.swift
//  3week_WeatherDiary
//
//  Created by sumin on 2021/09/28.
//

import Foundation

// 에러 정의
enum NetworkError: Error {
    case badUrl
    case noData
    case decodingError
}

class WeatherService {
    let latitude: Double
    let longitude: Double
    
    // .plist에서 API Key 가져오기
    private var apiKey: String {
        get {
            // 생성한 .plist 파일 경로 불러오기
            guard let filePath = Bundle.main.path(forResource: "KeyList", ofType: "plist") else {
                fatalError("Couldn't find file 'KeyList.plist'.")
            }
            
            // .plist를 딕셔너리로 받아오기
            let plist = NSDictionary(contentsOfFile: filePath)
            
            // 딕셔너리에서 값 찾기
            guard let value = plist?.object(forKey: "OPENWEATHERMAP_KEY") as? String else {
                fatalError("Couldn't find key 'OPENWEATHERMAP_KEY' in 'KeyList.plist'.")
            }
            return value
        }
    }
    
    init(_ latitude: Double, _ longitude: Double) {
        self.latitude = latitude
        self.longitude = longitude
    }
    
    func getWeather(completion: @escaping (Result<WeatherResponse, NetworkError>) -> Void) {
        // API 호출을 위한 URL
//        let url = URL(string: "https://api.openweathermap.org/data/2.5/weather?q=seoul&appid=\(apiKey)")
        let url = URL(string: "https://api.openweathermap.org/data/2.5/weather?lat=\(latitude)&lon=\(longitude)&appid=\(apiKey)")
        guard let url2 = url else {
            return completion(.failure(.badUrl))
        }
        
        URLSession.shared.dataTask(with: url2) { data, response, error in
            guard let data = data, error == nil else {
                return completion(.failure(.noData))
            }
            
            // Data 타입으로 받은 리턴을 디코드
            let weatherResponse = try? JSONDecoder().decode(WeatherResponse.self, from: data)

            // 성공
            if let weatherResponse = weatherResponse {
                print(weatherResponse)
                completion(.success(weatherResponse)) // 성공한 데이터 저장
            } else {
                completion(.failure(.decodingError))
            }
        }.resume() // 이 dataTask 시작
    }
}
