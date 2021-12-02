//
//  GetOnAlarmUsecase.swift
//  BBus
//
//  Created by 김태훈 on 2021/11/22.
//

import Foundation
import Combine

protocol GetOnAlarmAPIUsable: BaseUseCase {
    func fetch(withVehId vehId: String)
}

final class GetOnAlarmAPIUseCase: GetOnAlarmAPIUsable {

    private let useCases: GetBusPosByVehIdUsable
    private var cancellable: AnyCancellable?
    @Published private(set) var networkError: Error?
    @Published private(set) var busPosition: BusPosByVehicleIdDTO?

    init(useCases: GetBusPosByVehIdUsable) {
        self.useCases = useCases
        self.cancellable = nil
        self.networkError = nil
        self.busPosition = nil
    }

    func fetch(withVehId vehId: String) {
        self.cancellable = self.useCases.getBusPosByVehId(vehId)
            .decode(type: JsonMessage.self, decoder: JSONDecoder())
            .retry({ [weak self] in
                self?.fetch(withVehId: vehId)
            }, handler: { [weak self] error in
                self?.networkError = error
            })
            .map({ item in
                item.msgBody.itemList.first
            })
            .assign(to: \.busPosition, on: self)
    }
}
