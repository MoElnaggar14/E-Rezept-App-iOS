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
import CoreData
import eRpKit

/// Store for fetching, creating, updating or deleting `Profile`s on the provided `CoreDataController`
public class ProfileCoreDataStore: ProfileDataStore, CoreDataCrudable {
    let coreDataControllerFactory: CoreDataControllerFactory
    let foregroundQueue: AnySchedulerOf<DispatchQueue>
    let backgroundQueue: AnySchedulerOf<DispatchQueue>

    /// Initialize a Profile Core Data Store
    /// - Parameters:
    ///   - coreDataControllerFactory: Factory that is capable of providing a CoreDataController
    ///   - foregroundQueue: read queue, remember never to access the read NSManagedObjects properties/relations on any
    ///     other queue (Default: DispatchQueue.main)
    ///   - backgroundQueue:
    ///     write queue (Default: DispatchQueue(label: "profile-queue", qos: .userInitiated))
    public init(
        coreDataControllerFactory: CoreDataControllerFactory,
        foregroundQueue: AnySchedulerOf<DispatchQueue> = AnyScheduler.main,
        backgroundQueue: AnySchedulerOf<DispatchQueue> = DispatchQueue(label: "profile-queue", qos: .userInitiated)
            .eraseToAnyScheduler()
    ) {
        self.coreDataControllerFactory = coreDataControllerFactory
        self.foregroundQueue = foregroundQueue
        self.backgroundQueue = backgroundQueue
    }

    public func fetchProfile(by identifier: Profile.ID)
        -> AnyPublisher<Profile?, LocalStoreError> {
        let request: NSFetchRequest<ProfileEntity> = ProfileEntity.fetchRequest()
        request.predicate = NSPredicate(
            format: "%K == %@",
            argumentArray: [#keyPath(ProfileEntity.identifier), identifier]
        )
        request.sortDescriptors = [NSSortDescriptor(key: #keyPath(ProfileEntity.created), ascending: true)]
        return fetch(request)
            .map { results in
                guard let profileEntity = results.first else {
                    return nil
                }
                if results.count > 1 {
                    assertionFailure("error: there should always be just one profile per id in store")
                }
                return Profile(entity: profileEntity)
            }
            .eraseToAnyPublisher()
    }

    public func listAllProfiles() -> AnyPublisher<[Profile], LocalStoreError> {
        let request: NSFetchRequest<ProfileEntity> = ProfileEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: #keyPath(ProfileEntity.created), ascending: true)]

        return fetch(request)
            .map { list in list.compactMap(Profile.init) }
            .eraseToAnyPublisher()
    }

    // creates or updates a `Profile`. Note that the `erxTasks` relationship will not be saved
    public func save(profiles: [Profile]) -> AnyPublisher<Bool, LocalStoreError> {
        save(mergePolicy: NSMergePolicy.error) { moc in
            _ = profiles.map { profile -> ProfileEntity in
                let request: NSFetchRequest<ProfileEntity> = ProfileEntity.fetchRequest()
                request.predicate = NSPredicate(
                    format: "%K == %@",
                    argumentArray: [#keyPath(ProfileEntity.identifier), profile.identifier]
                )

                if let profileEntity = try? moc.fetch(request).first {
                    profileEntity.name = profile.name
                    profileEntity.emoji = profile.emoji
                    profileEntity.insuranceId = profile.insuranceId
                    profileEntity.color = profile.color.rawValue
                    profileEntity.lastAuthenticated = profile.lastAuthenticated
                    return profileEntity
                } else {
                    return ProfileEntity.from(profile: profile, in: moc)
                }
            }
        }
    }

    public func update(
        profileId: UUID,
        mutating: @escaping (inout Profile) -> Void
    ) -> AnyPublisher<Bool, LocalStoreError> {
        save(mergePolicy: NSMergePolicy.error) { moc in
            let request: NSFetchRequest<ProfileEntity> = ProfileEntity.fetchRequest()
            request.fetchLimit = 1
            request.predicate = NSPredicate(
                format: "%K == %@",
                argumentArray: [#keyPath(ProfileEntity.identifier), profileId]
            )

            if let profileEntity = try? moc.fetch(request).first,
               var profile = Profile(entity: profileEntity) {
                mutating(&profile)
                profileEntity.name = profile.name
                profileEntity.insuranceId = profile.insuranceId
                profileEntity.emoji = profile.emoji
                profileEntity.color = profile.color.rawValue
                profileEntity.lastAuthenticated = profile.lastAuthenticated
            } else {
                throw Error.noMatchingEntity
            }
        }
    }

    public func delete(profiles: [Profile]) -> AnyPublisher<Bool, LocalStoreError> {
        let request: NSFetchRequest<ProfileEntity> = ProfileEntity.fetchRequest()
        let ids = profiles.map(\.identifier)
        request.predicate = NSPredicate(format: "%K in %@", #keyPath(ProfileEntity.identifier), ids)
        request.sortDescriptors = [NSSortDescriptor(key: #keyPath(ProfileEntity.name), ascending: false)]
        return delete(resultsOf: request)
    }

    enum Error: Swift.Error {
        case noMatchingEntity
    }
}
