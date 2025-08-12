//
//  DateFormatter+Extensions.swift
//  weady
//
//  Created by 엄민서 on 8/2/25.
//

import Foundation

private enum _DateCache {
    // 서버 기본 포맷
    static let serverBasic: DateFormatter = {
        let f = DateFormatter()
        f.calendar = Calendar(identifier: .gregorian)
        f.locale = Locale(identifier: "ko_KR")
        f.timeZone = TimeZone(secondsFromGMT: 0) // TZ 미표기 → UTC로 가정
        f.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        return f
    }()

    static let iso8601: ISO8601DateFormatter = {
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return f
    }()

    static func custom(_ format: String,
                       tz: TimeZone = .current,
                       locale: Locale = Locale(identifier: "ko_KR")) -> DateFormatter {
        let f = DateFormatter()
        f.calendar = Calendar(identifier: .gregorian)
        f.locale = locale
        f.timeZone = tz
        f.dateFormat = format
        return f
    }
}

public extension String {
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

    /// 서버가 주는 날짜 문자열을 Date로 변환
    func asServerDate() -> Date? {
        if let d = _DateCache.serverBasic.date(from: self) {
            return d
        }
        if let d = _DateCache.iso8601.date(from: self) {
            return d
        }
        return nil
    }

    /// 서버 포맷 문자열을 원하는 포맷으로 변환
    func formattedFromServer(to format: String = "yyyy-MM-dd",
                             timeZone: TimeZone = .current,
                             locale: Locale = Locale(identifier: "ko_KR")) -> String {
        guard let date = asServerDate() else { return self }
        let out = _DateCache.custom(format, tz: timeZone, locale: locale)
        return out.string(from: date)
    }

    /// 상대 시간(방금 전, n분 전, n시간 전, n일 전, 7일↑은 yyyy.MM.dd HH:mm)
    func relativeTimeString(now: Date = Date(),
                                timeZone: TimeZone = .current,
                                locale: Locale = Locale(identifier: "ko_KR")) -> String {
        guard let date = asServerDate() else { return self }

        let interval = Int(now.timeIntervalSince(date))
        if interval < 60 { return "방금 전" }
        if interval < 3600 { return "\(interval / 60)분 전" }
        if interval < 86400 { return "\(interval / 3600)시간 전" }
        if interval < 86400 * 7 { return "\(interval / 86400)일 전" }

        let out = _DateCache.custom("yyyy.MM.dd HH:mm", tz: timeZone, locale: locale)
        return out.string(from: date)
    }
}

public extension Date {
    func formatted(_ format: String = "yyyy-MM-dd",
                   timeZone: TimeZone = .current,
                   locale: Locale = Locale(identifier: "ko_KR")) -> String {
        let f = _DateCache.custom(format, tz: timeZone, locale: locale)
        return f.string(from: self)
    }

    func relativeTimeString(now: Date = Date(),
                            timeZone: TimeZone = .current,
                            locale: Locale = Locale(identifier: "ko_KR")) -> String {
        let interval = Int(now.timeIntervalSince(self))
        if interval < 60 { return "방금 전" }
        if interval < 3600 { return "\(interval / 60)분 전" }
        if interval < 86400 { return "\(interval / 3600)시간 전" }
        if interval < 86400 * 7 { return "\(interval / 86400)일 전" }

        let out = _DateCache.custom("yyyy.MM.dd HH:mm", tz: timeZone, locale: locale)
        return out.string(from: self)
    }
}
