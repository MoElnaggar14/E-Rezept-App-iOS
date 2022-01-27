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
import CoreData
import eRpKit

extension ErxTaskCoreDataStore: ErxMedicationDispenseDataStore {
    public func fetchLatestHandOverDateForMedicationDispenses() -> AnyPublisher<String?, Error> {
        let request: NSFetchRequest<ErxTaskMedicationDispenseEntity> = ErxTaskMedicationDispenseEntity.fetchRequest()
        request.fetchLimit = 1
        request.sortDescriptors = [NSSortDescriptor(
            key: #keyPath(ErxTaskMedicationDispenseEntity.whenHandedOver),
            ascending: false
        )]
        if let identifier = profileId {
            request.predicate = NSPredicate(
                format: "%K == %@",
                argumentArray: [#keyPath(ErxTaskMedicationDispenseEntity.task.profile.identifier), identifier]
            )
        }
        return fetch(request)
            .map { $0.first?.whenHandedOver }
            .eraseToAnyPublisher()
    }

    public func listAllMedicationDispenses(
        after _: String?
    ) -> AnyPublisher<[ErxTask.MedicationDispense], Error> {
        let request: NSFetchRequest<ErxTaskMedicationDispenseEntity> = ErxTaskMedicationDispenseEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(
            key: #keyPath(ErxTaskMedicationDispenseEntity.whenHandedOver),
            ascending: false
        )]
        if let identifier = profileId {
            request.predicate = NSPredicate(
                format: "%K == %@",
                argumentArray: [#keyPath(ErxTaskMedicationDispenseEntity.task.profile.identifier), identifier]
            )
        }
        return fetch(request)
            .map { list in list.compactMap(ErxTask.MedicationDispense.init) }
            .eraseToAnyPublisher()
    }

    public func save(medicationDispenses: [ErxTask.MedicationDispense]) -> AnyPublisher<Bool, Error> {
        save(mergePolicy: .mergeByPropertyObjectTrump) { moc in
            _ = medicationDispenses.map { medicationDispense -> ErxTaskMedicationDispenseEntity in
                let medicationDispenseEntity = ErxTaskMedicationDispenseEntity.from(
                    medicationDispense: medicationDispense,
                    in: moc
                )
                // Set relationship to related `ErxTask`
                let request: NSFetchRequest<ErxTaskEntity> = ErxTaskEntity.fetchRequest()
                request.predicate = NSPredicate(
                    format: "%K == %@",
                    #keyPath(ErxTaskEntity.identifier),
                    medicationDispense.taskId
                )
                medicationDispenseEntity.task = try? request.execute().first

                return medicationDispenseEntity
            }
        }
    }
}
