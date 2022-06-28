//
//  Copyright (c) 2022 gematik GmbH
//  
//  Licensed under the EUPL, Version 1.2 or – as soon they will be approved by
//  the European Commission - subsequent versions of the EUPL (the Licence);
//  You may not use this work except in compliance with the Licence.
//  You may obtain a copy of the Licence at:
//  
//      https://joinup.ec.europa.eu/software/page/eupl
//  
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the Licence is distributed on an "AS IS" basis,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the Licence for the specific language governing permissions and
//  limitations under the Licence.
//  
//

import Combine
import CombineSchedulers
import eRpKit
import eRpLocalStorage
import eRpRemoteStorage
import Foundation
import IdentifiedCollections

class DemoErxTaskRepository: ErxTaskRepository {
    typealias ErrorType = ErxRepositoryError
    private let delay: Double
    private var demoDatesIterator = DemoDatesIterator()
    private let currentValue: CurrentValueSubject<[ErxTask], ErrorType> = CurrentValueSubject([])
    private let schedulers: Schedulers
    private var uiScheduler: AnySchedulerOf<DispatchQueue> {
        schedulers.main
    }

    init(requestDelayInSeconds: Double = 0.1, schedulers: Schedulers = Schedulers()) {
        delay = requestDelayInSeconds
        self.schedulers = schedulers
    }

    func loadRemote(by id: ErxTask.ID,
                    accessCode: String?) -> AnyPublisher<ErxTask?, ErrorType> {
        loadLocal(by: id, accessCode: accessCode)
    }

    func loadLocal(
        by id: ErxTask.ID,
        accessCode _: String?
    ) -> AnyPublisher<ErxTask?, ErxRepositoryError> {
        if let result = store.first(where: { $0.id == id }) {
            return Just(result).setFailureType(to: ErrorType.self).eraseToAnyPublisher()
        } else {
            return Empty().setFailureType(to: ErrorType.self).eraseToAnyPublisher()
        }
    }

    func loadLocalAll() -> AnyPublisher<[ErxTask], ErrorType> {
        currentValue
            .first()
            .delay(for: .seconds(delay), scheduler: uiScheduler)
            .eraseToAnyPublisher()
    }

    func loadRemoteAll(for _: String?) -> AnyPublisher<[ErxTask], ErrorType> {
        currentValue.send(nextChunkFromStore())
        return currentValue
            .delay(for: .seconds(delay), scheduler: uiScheduler, options: .none)
            .eraseToAnyPublisher()
    }

    func save(erxTasks: [ErxTask]) -> AnyPublisher<Bool, ErrorType> {
        erxTasks.forEach { task in
            if store.contains(task) {
                store.update(with: task)
            }
        }
        return Just(true).setFailureType(to: ErrorType.self).eraseToAnyPublisher()
    }

    func delete(erxTasks: [ErxTask]) -> AnyPublisher<Bool, ErrorType> {
        store.formUnion(Set(erxTasks))
        return Just(true).setFailureType(to: ErrorType.self).eraseToAnyPublisher()
    }

    func redeem(order: ErxTaskOrder) -> AnyPublisher<ErxTaskOrder, ErrorType> {
        Just(order).setFailureType(to: ErrorType.self).eraseToAnyPublisher()
    }

    func loadLocalCommunications(for _: ErxTask.Communication
        .Profile)
        -> AnyPublisher<[ErxTask.Communication], // swiftlint:disable:this operator_usage_whitespace
            ErxRepositoryError> {
        Just([]).setFailureType(to: ErrorType.self).eraseToAnyPublisher()
    }

    func saveLocal(communications _: [ErxTask.Communication]) -> AnyPublisher<Bool, ErrorType> {
        Just(true).setFailureType(to: ErrorType.self).eraseToAnyPublisher()
    }

    func countAllUnreadCommunications(
        for _: ErxTask.Communication.Profile
    ) -> AnyPublisher<Int, ErrorType> {
        Just(0).setFailureType(to: ErrorType.self).eraseToAnyPublisher()
    }

    private lazy var store: Set<ErxTask> = {
        Set(ErxTask.Demo.erxTasks)
    }()

    /// Demo data is loaded in iterations. With every refresh a next chunk is loaded.
    private struct DemoDatesIterator: IteratorProtocol {
        typealias Element = String
        var index = 0
        let demoDates: [String?] = [
            DemoDate.createDemoDate(.sixteenDaysBefore),
            DemoDate.createDemoDate(.dayBeforeYesterday),
            DemoDate.createDemoDate(.yesterday),
            DemoDate.createDemoDate(.today),
        ]

        mutating func next() -> String? {
            defer {
                if index < demoDates.count - 1 {
                    index += 1
                }
            }
            return demoDates[index]
        }
    }

    private func nextChunkFromStore() -> [ErxTask] {
        let nextDemoDate = demoDatesIterator.next()

        return store.filter { erxTask in
            // convert date strings to real dates for comparison
            if let demoDateString = nextDemoDate,
               let demoDate = globals.fhirDateFormatter.date(from: demoDateString, format: .yearMonthDay),
               let authoredOnString = erxTask.authoredOn,
               let erxDate = globals.fhirDateFormatter.date(from: authoredOnString, format: .yearMonthDay) {
                let compareResult = Calendar.current.compare(demoDate, to: erxDate, toGranularity: .day)
                return compareResult == .orderedSame || compareResult == .orderedDescending
            }
            return false
        }
    }
}
