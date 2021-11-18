//
//  AlarmSettingBusArriveInfos.swift
//  BBus
//
//  Created by 최수정 on 2021/11/18.
//

import Foundation

typealias AlarmSettingBusStationInfo = (arsId: String, name: String, estimatedTime: Int)

struct AlarmSettingBusStationInfos {
    var arriveInfos: [AlarmSettingBusArriveInfo]
    var changedByTimer: Bool
    
    var count: Int {
        return self.arriveInfos.count
    }
    
    var first: AlarmSettingBusArriveInfo? {
        return self.count > 0 ? arriveInfos[0] : nil
    }
    
    subscript(index: Int) -> AlarmSettingBusArriveInfo? {
        guard index >= 0 && index < self.count else { return nil }
        return self.arriveInfos[index]
    }
    
    mutating func desend() {
        self.arriveInfos = self.arriveInfos.map {
            var arriveInfo = $0
            arriveInfo.arriveRemainTime?.descend()
            return arriveInfo
        }
        self.changedByTimer = true
    }
}
