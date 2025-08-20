//
//  DateFormatter+Extensions.swift
//  weady
//
//  Created by 엄민서 on 8/2/25.
//

import Foundation

private enum _DateCache {
    // 서버 기본(초 단위, TZ 미표기 → UTC 가정)
    static let serverBasic: DateFormatter = {
        let f = DateFormatter()
        f.calendar = Calendar(identifier: .gregorian)
        f.locale = Locale(identifier: "ko_KR")
        // ✅ 핵심 수정: UTC → .current (KST 환경이라면 Asia/Seoul)
        f.timeZone = .current
        f.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        return f
    }()

    // 서버(소수점이 길이 가변, TZ 미표기 → UTC 가정)
    // 여러 패턴을 순차 시도
    static let serverFractionalFormats: [DateFormatter] = {
        let patterns = [
            "yyyy-MM-dd'T'HH:mm:ss.SSSSSSSSS",
            "yyyy-MM-dd'T'HH:mm:ss.SSSSSSS",
            "yyyy-MM-dd'T'HH:mm:ss.SSSSSS",
            "yyyy-MM-dd'T'HH:mm:ss.SSSSS",
            "yyyy-MM-dd'T'HH:mm:ss.SSSS",
            "yyyy-MM-dd'T'HH:mm:ss.SSS"
        ]
        return patterns.map { p in
            let f = DateFormatter()
            f.calendar = Calendar(identifier: .gregorian)
            f.locale = Locale(identifier: "ko_KR")
            f.timeZone = .current
            f.dateFormat = p
            return f
        }
    }()

    // 표준 ISO8601 (타임존 포함일 때만 기대)
    static let iso8601Frac: ISO8601DateFormatter = {
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return f
    }()
    static let iso8601: ISO8601DateFormatter = {
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withInternetDateTime]
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
        let input = DateFormatter()
        input.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        input.locale = Locale(identifier: "ko_KR")
        // 서버 기본 포맷이 로컬 시간대이므로 input.timeZone도 맞춰주면 더 안전
        input.timeZone = .current

        guard let date = input.date(from: self) else { return self }
        let out = DateFormatter()
        out.dateFormat = "yyyy-MM-dd"
        out.timeZone = .current
        return out.string(from: date)
    }

    /// 서버가 주는 날짜 문자열을 Date로 변환
    func asServerDate() -> Date? {
        let s = self.trimmingCharacters(in: .whitespacesAndNewlines)

        // 1) 타임존 명시(Z 또는 +HH:mm)가 있으면 ISO8601로 정확히 파싱
        if s.contains("Z") || s.contains("+") {
            if let d = _DateCache.iso8601Frac.date(from: s) { return d }
            if let d = _DateCache.iso8601.date(from: s) { return d }
        }

        // 2) 가변 소수점(타임존 미표기 → 로컬 시간대)
        if s.contains(".") {
            for f in _DateCache.serverFractionalFormats {
                if let d = f.date(from: s) { return d }
            }
            // 소수점 제거 후 기본 포맷
            if let base = s.split(separator: ".").first,
               let d = _DateCache.serverBasic.date(from: String(base)) {
                return d
            }
        }

        // 3) 기본 포맷(타임존 미표기 → 로컬 시간대)
        if let d = _DateCache.serverBasic.date(from: s) { return d }

        // 4) 마지막 백업 (예외 케이스 대비)
        if let d = _DateCache.iso8601Frac.date(from: s) { return d }
        if let d = _DateCache.iso8601.date(from: s) { return d }

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

        let seconds = Int(now.timeIntervalSince(date))
        if seconds < 0 { // 미래 시각이면 절대값 말고, "방금 전"으로만 표시
            return "방금 전"
        }
        if seconds < 60 { return "방금 전" }
        if seconds < 3600 { return "\(seconds / 60)분 전" }
        if seconds < 86400 { return "\(seconds / 3600)시간 전" }
        if seconds < 86400 * 7 { return "\(seconds / 86400)일 전" }

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
        let seconds = Int(now.timeIntervalSince(self))
        if seconds < 0 { return "방금 전" }
        if seconds < 60 { return "방금 전" }
        if seconds < 3600 { return "\(seconds / 60)분 전" }
        if seconds < 86400 { return "\(seconds / 3600)시간 전" }
        if seconds < 86400 * 7 { return "\(seconds / 86400)일 전" }

        let out = _DateCache.custom("yyyy.MM.dd HH:mm", tz: timeZone, locale: locale)
        return out.string(from: self)
    }
}
