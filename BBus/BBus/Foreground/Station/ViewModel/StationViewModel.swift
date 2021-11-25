//
//  StationViewModel.swift
//  BBus
//
//  Created by 김태훈 on 2021/11/01.
//

import Foundation
import Combine
import UIKit

final class StationViewModel {
    
    let usecase: StationUsecase
    let arsId: String
    private var cancellables: Set<AnyCancellable>
    @Published private(set) var busKeys: BusSectionKeys
    @Published private(set) var activeBuses = [BBusRouteType: BusArriveInfos]()
    private(set) var noInfoBuses = [BBusRouteType: [BusArriveInfo]]()
    @Published private(set) var favoriteItems = [FavoriteItemDTO]()
    @Published private(set) var nextStation: String? = nil
    
    init(usecase: StationUsecase, arsId: String) {
        self.usecase = usecase
        self.arsId = arsId
        self.cancellables = []
        self.busKeys = BusSectionKeys()
        self.binding()
        self.refresh()
    }

    func configureObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(descendTime), name: .oneSecondPassed, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(refresh), name: .thirtySecondPassed, object: nil)
    }

    func cancelObserver() {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func refresh() {
        self.usecase.stationInfoWillLoad(with: arsId)
        self.usecase.refreshInfo(about: arsId)
    }

    @objc private func descendTime() {
        self.activeBuses.forEach({ [weak self] in
            self?.activeBuses[$0.key] = $0.value.descended()
        })
    }
    
    private func binding() {
        self.bindFavoriteItems()
        self.bindBusArriveInfo()
    }
    
    private func bindBusArriveInfo() {
        self.usecase.$busArriveInfo
            .receive(on: StationUsecase.queue)
            .sink(receiveCompletion: { error in
                print(error)
            }, receiveValue: { [weak self] arriveInfo in
                guard arriveInfo.count > 0 else { return }
                self?.nextStation = arriveInfo[0].nextStation
                self?.classifyByRouteType(with: arriveInfo)
            })
            .store(in: &self.cancellables)
    }
    
    private func bindFavoriteItems() {
        self.usecase.$favoriteItems
            .receive(on: StationUsecase.queue)
            .sink(receiveValue: { [weak self] items in
                self?.favoriteItems = items.filter() { $0.arsId == self?.arsId }
            })
            .store(in: &self.cancellables)
    }

    private func classifyByRouteType(with buses: [StationByUidItemDTO]) {
        var activeBuses: [BBusRouteType: BusArriveInfos] = [:]
        var noInfoBuses: [BBusRouteType: [BusArriveInfo]] = [:]
        buses.forEach() { bus in
            guard let routeType = BBusRouteType(rawValue: Int(bus.routeType) ?? 0) else { return }
            
            let info: BusArriveInfo
            info.routeType = routeType
            info.firstBusCongestion = BusCongestion(rawValue: bus.congestion)
            
            info.nextStation = bus.nextStation
            info.busNumber = bus.busNumber
            info.stationOrd = bus.stationOrd
            info.busRouteId = bus.busRouteId
            
            let timeAndPositionInfo1 = AlarmSettingBusArriveInfo.seperateTimeAndPositionInfo(with: bus.firstBusArriveRemainTime)
            if timeAndPositionInfo1.time.checkInfo() {
                info.firstBusArriveRemainTime = timeAndPositionInfo1.time
                info.firstBusRelativePosition = timeAndPositionInfo1.position
                
                let timeAndPositionInfo2 = AlarmSettingBusArriveInfo.seperateTimeAndPositionInfo(with: bus.secondBusArriveRemainTime)
                info.secondBusArriveRemainTime = timeAndPositionInfo2.time
                info.secondBusRelativePosition = timeAndPositionInfo2.position
                info.secondBusCongestion = timeAndPositionInfo2.time.checkInfo() ? info.firstBusCongestion : nil

                activeBuses.updateValue((activeBuses[routeType] ?? BusArriveInfos()) + BusArriveInfos(infos: [info]), forKey: routeType)
            }
            else {
                info.firstBusArriveRemainTime = nil
                info.firstBusRelativePosition = nil
                info.secondBusArriveRemainTime = nil
                info.secondBusRelativePosition = nil
                info.secondBusCongestion = nil
                
                noInfoBuses.updateValue((noInfoBuses[routeType] ?? []) + [info], forKey: routeType)
            }
        }
        self.activeBuses = activeBuses
        self.noInfoBuses = noInfoBuses

        let sortedInfoBusesKey = Array(activeBuses.keys).sorted(by: { $0.rawValue < $1.rawValue })
        let sortedNoInfoBusesKey = Array(noInfoBuses.keys).sorted(by: { $0.rawValue < $1.rawValue })
        self.busKeys = BusSectionKeys(keys: sortedInfoBusesKey) + BusSectionKeys(keys: sortedNoInfoBusesKey)
    }
    
    func add(favoriteItem: FavoriteItemDTO) {
        self.usecase.add(favoriteItem: favoriteItem)
    }
    
    func remove(favoriteItem: FavoriteItemDTO) {
        self.usecase.remove(favoriteItem: favoriteItem)
    }
}
