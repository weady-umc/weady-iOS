//
//  ReportReasonViewModel.swift
//  weady
//
//  Created by 엄민서 on 7/17/25.
//

let reportReasons: [ReportReason] = [
    ReportReason(
        listTitle: "스팸",
        detailTitle: "스팸으로 신고하시겠습니까?",
        details: [
        "광고성 도배 게시물",
        "사기나 도박 등의 콘텐츠 및 홍보",
        "무의미한 내용 반복 게시물"
    ], isCustomInput: false),

    ReportReason(
        listTitle: "유해 콘텐츠",
        detailTitle: "유해 콘텐츠로 신고하시겠습니까?",
        details: [
        "누드, 선정적인 콘텐츠 및 음란물",
        "혐오, 자극적, 폭력적, 잔인한 묘사 포함"
    ], isCustomInput: false),

    ReportReason(
        listTitle: "잘못된 정보",
        detailTitle: "잘못된 정보로 신고하시겠습니까?",
        details: [
        "허위 사실이 포함된 정보",
        "사실과 다른 정보 (의도적 혹은 비의도적 기재 오류 등)",
        "타인을 오도할 수 있는 정보",
        "명확한 정보 출처 없음"
    ], isCustomInput: false),

    ReportReason(
        listTitle: "혐오활동",
        detailTitle: "혐오활동으로 신고하시겠습니까?",
        details: [
        "특정 대상에 대한 공격 또는 비하가 포함된 콘텐츠",
        "성별, 인종, 연령, 종교 등 차별적 요소가 포함된 콘텐츠"
    ], isCustomInput: false),

    ReportReason(
        listTitle: "모욕적인 내용 또는 비난",
        detailTitle: "모욕적인 내용 또는 비난으로 신고하시겠습니까?",
        details: [
        "욕설 또는 비속어가 포함된 게시물",
        "타인을 조롱하거나 모욕하는 의도가 포함된 표현"
    ], isCustomInput: false),

    ReportReason(
        listTitle: "개인정보 침해",
        detailTitle: "개인정보 침해로 신고하시겠습니까?",
        details: [
        "개인 정보가 포함된 콘텐츠 (이름, 전화번호, 주소 등)",
        "타인의 계정 정보 노출"
    ], isCustomInput: false),

    ReportReason(
        listTitle: "불법 촬영 콘텐츠",
        detailTitle: "불법 촬영 콘텐츠로 신고하시겠습니까?",
        details: [
        "촬영 동의 없는 콘텐츠",
        "불법 촬영이 의심되는 콘텐츠"
    ], isCustomInput: false),

    ReportReason(
        listTitle: "기타",
        detailTitle: "해당하는 항목이 없는 경우\n웨디에게 직접 알려주세요.",
        details: [],
        isCustomInput: true)
]
