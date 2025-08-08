//
//  DateFormatter+Extensions.swift
//  weady
//
//  Created by 엄민서 on 8/2/25.
//

import Foundation

extension String {
    /// yyyy-MM-dd'T'HH:mm:ss → yyyy-MM-dd 포맷 변환
    var dateFormat: String {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        inputFormatter.locale = Locale(identifier: "ko_KR")

        guard let date = inputFormatter.date(from: self) else {
            return self
        }

        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "yyyy-MM-dd"
        return outputFormatter.string(from: date)
    }

    /// 상대 시간 표시 (방금 전, n분 전, n시간 전, n일 전)
    func relativeTimeString() -> String {
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.timeZone = TimeZone(identifier: "Asia/Seoul")

        guard let date = isoFormatter.date(from: self) else {
            return self
        }

        let interval = Int(Date().timeIntervalSince(date))

        if interval < 60 {
            return "방금 전"
        } else if interval < 3600 {
            return "\(interval / 60)분 전"
        } else if interval < 86400 {
            return "\(interval / 3600)시간 전"
        } else {
            return "\(interval / 86400)일 전"
        }
    }
}
