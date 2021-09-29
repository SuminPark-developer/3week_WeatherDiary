//
//  DiaryTableViewCell.swift
//  3week_WeatherDiary
//
//  Created by sumin on 2021/09/23.
//

import UIKit

class DiaryTableViewCell: UITableViewCell {

    @IBOutlet weak var uiTitle: UILabel!
    @IBOutlet weak var uiContents: UILabel!
    @IBOutlet weak var uiImage: UIImageView!
    
    @IBOutlet weak var uiWeatherImage: UIImageView!
    @IBOutlet weak var uiTemperature: UILabel!
    
    // 재활용 셀 중첩오류 해결법 : prepareForReuse() 사용 - https://sihyungyou.github.io/iOS-dequeueReusableCell/
    override func prepareForReuse() {
        uiImage.image = nil
        uiImage.image = UIImage(named: "profileImage")
        uiWeatherImage.image = nil
    }
    
    // cell이 렌더링(=그릴 때)될 때
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        uiImage.layer.cornerRadius = uiImage.frame.height / 2
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
