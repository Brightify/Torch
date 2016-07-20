//
//  ApiDraft.swift
//  Torch
//
//  Created by Filip Dolnik on 19.07.16.
//  Copyright © 2016 Brightify. All rights reserved.
//

import Foundation

import CoreData

public struct StoreConfiguration {
    public let storeType: String
    public let configuration: String?
    public let storeURL: NSURL?
    public let options: [NSObject : AnyObject]?
}

public let inMemoryStore = StoreConfiguration(storeType: NSInMemoryStoreType, configuration: nil, storeURL: nil, options: nil)

public class Torch {
    private let context = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)

    public convenience init(store: StoreConfiguration, entities: TorchEntityRegistration...) throws {
        try self.init(store: store, entities: entities)
    }

    public init(store: StoreConfiguration, entities: [TorchEntityRegistration]) throws {
        let entityRegistry = EntityRegistry()

        TorchMetadata.torch_describe(to: entityRegistry)

        for registration in entities {
            registration.describeToFunction(entityRegistry)
        }

        let managedObjectModel = NSManagedObjectModel()
        managedObjectModel.entities = Array(entityRegistry.registeredEntities.values)

        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)
        try coordinator.addPersistentStoreWithType(store.storeType, configuration: store.configuration, URL: store.storeURL, options: store.options)
        context.persistentStoreCoordinator = coordinator

        var allMetadata = try load(TorchMetadata.self)
        for entity in entityRegistry.registeredEntities.values {
            guard let entityName = entity.name else { fatalError("Entity has to have a name!") }
            if allMetadata.contains({ $0.entityName == entityName }) {
                continue
            }

            var metadata = TorchMetadata(id: allMetadata.count, entityName: entityName, lastAssignedId: -1)
            let metadataObject = createManagedObject(TorchMetadata)
            try metadata.torch_updateManagedObject(metadataObject, torch: self)
            allMetadata.append(metadata)
        }

        try write()
    }

    public func load<T: TorchEntity>(type: T.Type) throws -> [T] {
        return try load(type, where: BoolPredicate(value: true))
    }

    // TODO Default values
    public func load<T: TorchEntity, P: PredicateConvertible where T == P.ParentType>(type: T.Type, where predicate: P, orderBy: SortDescriptor = SortDescriptor()) throws -> [T] {
        let request = NSFetchRequest(entityName: type.torch_name)
        request.predicate = predicate.toPredicate()
        request.sortDescriptors = orderBy.toSortDescriptors()
        let entities = try context.executeFetchRequest(request) as! [NSManagedObject]
        return try entities.map { try T(fromManagedObject: $0, torch: self) }
    }

    public func save<T: TorchEntity>(inout entity: T) throws -> Torch {
        try storeEntity(&entity)
        try updateLastAssignedId(entity)
        return self
    }

    public func delete<T: TorchEntity>(entities: T...) throws -> Torch {
        return try delete(entities)
    }

    public func delete<T: TorchEntity>(entities: [T]) throws -> Torch {
        try entities.forEach {
            if let managedObject = try getEntityManagedObject($0) {
                context.deleteObject(managedObject)
            }
        }
        return self
    }

    public func delete<T: TorchEntity, P: PredicateConvertible where T == P.ParentType>(type: T.Type, where predicate: P) throws -> Torch {
        let request = NSFetchRequest(entityName: type.torch_name)
        request.predicate = predicate.toPredicate()
        (try context.executeFetchRequest(request) as! [NSManagedObject]).forEach {
            context.deleteObject($0)
        }
        return self
    }

    public func deleteAll<T: TorchEntity>(type: T.Type) throws -> Torch {
        return try delete(type, where: BoolPredicate(value: true))
    }

    public func rollback() -> Torch {
        context.rollback()
        return self
    }

    public func write(@noescape closure: () throws -> Void = {}) throws -> Torch {
        try closure()
        try context.save()
        return self
    }

    private func createManagedObject<T: TorchEntity>(entityType: T.Type) -> NSManagedObject {
        let entityDescription = NSEntityDescription.entityForName(T.torch_name, inManagedObjectContext: context)
        guard let description = entityDescription else {
            fatalError("Entity \(T.torch_name) is not registered!")
        }

        return NSManagedObject(entity: description, insertIntoManagedObjectContext: context)
    }

    private func storeEntity<T: TorchEntity>(inout entity: T) throws {
        let managedObject: NSManagedObject
        if let existingManagedObject = try getEntityManagedObject(entity) {
            managedObject = existingManagedObject
        } else {
            managedObject = createManagedObject(T)

            if entity.id == nil {
                entity.id = try getNextId(T)
            }
        }
        try entity.torch_updateManagedObject(managedObject, torch: self)
    }

    private func getEntityManagedObject<T: TorchEntity>(entity: T) throws -> NSManagedObject? {
        if let id = entity.id {
            let request = NSFetchRequest(entityName: T.torch_name)
            request.predicate = NSPredicate(format: "id = %@", id as NSNumber)
            return (try context.executeFetchRequest(request) as! [NSManagedObject]).first
        } else {
            return nil
        }
    }

    public func managedObject<E: TorchEntity>(inout for entity: E) throws -> NSManagedObject {
        let managedObject: NSManagedObject
        if let existingManagedObject = try getEntityManagedObject(entity) {
            managedObject = existingManagedObject
        } else {
            managedObject = createManagedObject(E)

            if entity.id == nil {
                entity.id = try getNextId(E)
            }
        }
        try entity.torch_updateManagedObject(managedObject, torch: self)
        return managedObject
    }

    private func getNextId<T: TorchEntity>(entityType: T.Type) throws -> Int {
        var metadata = try getMetadata(T.torch_name)
        let nextId = metadata.lastAssignedId.successor()
        metadata.lastAssignedId = nextId
        try storeEntity(&metadata)
        return nextId
    }

    private func updateLastAssignedId<T: TorchEntity>(entity: T) throws {
        guard let id = entity.id else { return }

        var metadata = try getMetadata(T.torch_name)
        print(metadata)
        metadata.lastAssignedId = max(metadata.lastAssignedId as Int, id)
        try storeEntity(&metadata)
    }

    private func getMetadata(entityName: String) throws -> TorchMetadata {
        guard let metadata = try load(TorchMetadata.self, where: TorchMetadata.entityName.equalTo(entityName)).first else {
            fatalError("Could not load metadata for entity \(entityName)!")
        }
        return metadata
    }
    //
    //    private func tryGetMetadata(entityName: String) throws -> TorchMetadata? {
    //        return
    //
    ////        return nil // (try context.executeFetchRequest(request) as? [TorchMetadata])?.first ?? uncommitedMetadata.filter { $0.entityType == entityName }.first
    //    }


}

public class UnsafeTorch {

    private let torch: Torch

    public init(store: StoreConfiguration, entities: TorchEntityRegistration...) {
        torch = try! Torch(store: store, entities: entities)
    }

    public func load<T: TorchEntity>(type: T.Type) -> [T] {
        return load(type, where: BoolPredicate(value: true))
    }

    // TODO Default values
    // TODO Add proper error handling
    public func load<T: TorchEntity, P: PredicateConvertible where T == P.ParentType>(type: T.Type, where predicate: P, orderBy: SortDescriptor = SortDescriptor()) -> [T] {
        return try! torch.load(type, where: predicate, orderBy: orderBy)
    }

    public func save<T: TorchEntity>(inout entity: T) -> UnsafeTorch {
        try! torch.save(&entity)
        return self
    }

    public func delete<T: TorchEntity>(entities: T...) -> UnsafeTorch {
        delete(entities)
        return self
    }

    public func delete<T: TorchEntity>(entities: [T]) -> UnsafeTorch {
        try! torch.delete(entities)
        return self
    }

    public func delete<T: TorchEntity, P: PredicateConvertible where T == P.ParentType>(type: T.Type, where predicate: P) -> UnsafeTorch {
        try! torch.delete(type, where: predicate)
        return self
    }

    public func deleteAll<T: TorchEntity>(type: T.Type) -> UnsafeTorch {
        try! torch.deleteAll(type)
        return self
    }

    public func rollback() -> UnsafeTorch {
        torch.rollback()
        return self
    }

    public func write(@noescape closure: () -> () = {}) -> UnsafeTorch {
        try! torch.write(closure)
        return self
    }
}

// FIXME Remove its publicity!
public struct TorchMetadata: TorchEntity {
    public var id: Int?
    var entityName: String
    var lastAssignedId: Int
}

extension TorchMetadata {
    public static var torch_name: String {
        return "TorchSwift.TorchMetadata"
    }

    public static var torch_properties: [AnyProperty<TorchMetadata>] {
        return [
            id.typeErased(),
            entityName.typeErased(),
            lastAssignedId.typeErased()
        ]
    }

    static let id = ScalarProperty<TorchMetadata, Int>(name: "id")
    static let entityName = ScalarProperty<TorchMetadata, String>(name: "entityName")
    static let lastAssignedId = ScalarProperty<TorchMetadata, Int>(name: "lastAssignedId")

    public init(fromManagedObject object: NSManagedObject, torch: Torch) throws {
        id = object.valueForKey("id") as! Int?
        entityName = object.valueForKey("entityName") as! String
        lastAssignedId = object.valueForKey("lastAssignedId") as! Int
    }

    public mutating func torch_updateManagedObject(object: NSManagedObject, torch: Torch) throws {
        object.setValue(id, forKey: "id")
        object.setValue(entityName, forKey: "entityName")
        object.setValue(lastAssignedId, forKey: "lastAssignedId")
    }

    public static func torch_describe(to registry: EntityRegistry) {
        registry.description(of: TorchMetadata.self)
    }
}

public protocol TorchEntity {

    var id: Int? { get set }

    init(fromManagedObject object: NSManagedObject, torch: Torch) throws

    mutating func torch_updateManagedObject(object: NSManagedObject, torch: Torch) throws

    static var torch_name: String { get }

    static var torch_properties: [AnyProperty<Self>] { get }

    static func torch_describe(to registry: EntityRegistry)
}

extension TorchEntity {
    public static func registration() -> TorchEntityRegistration {
        return TorchEntityRegistration(describeToFunction: torch_describe)
    }
}

public struct TorchEntityRegistration {
    let describeToFunction: (EntityRegistry) -> Void
}

public protocol PredicateConvertible {
    associatedtype ParentType

    func toPredicate() -> NSPredicate
}

extension PredicateConvertible {
    public func typeErased() -> AnyPredicate<ParentType> {
        return AnyPredicate(toPredicateFunction: toPredicate)
    }
}

extension PredicateConvertible {

    public func or<OTHER: PredicateConvertible where OTHER.ParentType == ParentType>(other: OTHER) -> AnyPredicate<ParentType> {
        return AnyPredicate {
            NSCompoundPredicate(orPredicateWithSubpredicates: [self.toPredicate(), other.toPredicate()])
        }
    }

    public func and<OTHER: PredicateConvertible where OTHER.ParentType == ParentType>(other: OTHER) -> AnyPredicate<ParentType> {
        return AnyPredicate {
            NSCompoundPredicate(andPredicateWithSubpredicates: [self.toPredicate(), other.toPredicate()])
        }
    }
}

public struct SingleValuePredicate<PARENT, VALUE: NSObject>: PredicateConvertible {
    public typealias ParentType = PARENT

    public let propertyName: String
    public let operatorString: String
    public let value: VALUE

    public func toPredicate() -> NSPredicate {
        return NSPredicate(format: "%K \(operatorString) %@", propertyName, value)
    }
}

public struct OptionalSingleValuePredicate<PARENT, VALUE: NSObject>: PredicateConvertible {
    public typealias ParentType = PARENT

    public let propertyName: String
    public let operatorString: String
    public let value: VALUE?

    public func toPredicate() -> NSPredicate {
        return NSPredicate(format: "%K \(operatorString) %@", propertyName, value ?? NSNull())
    }
}

public struct BoolPredicate<PARENT>: PredicateConvertible {
    public typealias ParentType = PARENT

    public let value: Bool

    public func toPredicate() -> NSPredicate {
        return NSPredicate(value: value)
    }
}

public struct AnyPredicate<PARENT>: PredicateConvertible {
    public typealias ParentType = PARENT

    public let toPredicateFunction: () -> NSPredicate

    public func toPredicate() -> NSPredicate {
        return toPredicateFunction()
    }
}

public func || <P1: PredicateConvertible, P2: PredicateConvertible where P1.ParentType == P2.ParentType>(lhs: P1, rhs: P2) -> AnyPredicate<P1.ParentType> {
    return lhs.or(rhs)
}

public func && <P1: PredicateConvertible, P2: PredicateConvertible where P1.ParentType == P2.ParentType>(lhs: P1, rhs: P2) -> AnyPredicate<P1.ParentType> {
    return lhs.and(rhs)
}


public protocol TorchProperty {
    associatedtype ParentType: TorchEntity

    var name: String { get }

    func describe(to registry: PropertyRegistry)
}

extension TorchProperty {
    public func typeErased() -> AnyProperty<ParentType> {
        return AnyProperty(name: name, describeFunction: describe)
    }
}

public protocol TypedTorchProperty: TorchProperty {
    associatedtype ValueType
}

public protocol NSObjectConvertible {
    func toNSObject() -> NSObject
}

public protocol NSNumberConvertible: NSObjectConvertible {
    func toNSNumber() -> NSNumber
}

extension NSNumberConvertible {
    public func toNSObject() -> NSObject {
        return toNSNumber()
    }
}

extension Int: NSNumberConvertible {
    public func toNSNumber() -> NSNumber {
        return NSNumber(integer: self)
    }
}

extension String: NSObjectConvertible {
    public func toNSObject() -> NSObject {
        return NSString(string: self)
    }
}

public extension TypedTorchProperty where ValueType: NSObjectConvertible {
    public func equalTo(value: ValueType) -> AnyPredicate<ParentType> {
        return SingleValuePredicate(propertyName: name, operatorString: "==", value: value.toNSObject()).typeErased()
    }
}

public extension TypedTorchProperty where ValueType: NSNumberConvertible {

    public func lessThan(value: ValueType) -> AnyPredicate<ParentType> {
        return SingleValuePredicate(propertyName: name, operatorString: "<", value: value.toNSNumber()).typeErased()
    }

    public func lessThanOrEqualTo(value: ValueType) -> AnyPredicate<ParentType> {
        return SingleValuePredicate(propertyName: name, operatorString: "<=", value: value.toNSNumber()).typeErased()
    }

    public func greaterThanOrEqualTo(value: ValueType) -> AnyPredicate<ParentType> {
        return SingleValuePredicate(propertyName: name, operatorString: ">=", value: value.toNSNumber()).typeErased()
    }

    public func greaterThan(value: ValueType) -> AnyPredicate<ParentType> {
        return SingleValuePredicate(propertyName: name, operatorString: ">", value: value.toNSNumber()).typeErased()
    }
}

public extension TypedTorchProperty where ValueType: OptionalType, ValueType.WrappedType: NSObjectConvertible {
    public func equalTo(value: ValueType) -> AnyPredicate<ParentType> {
        return OptionalSingleValuePredicate(propertyName: name, operatorString: "==", value: value.value?.toNSObject()).typeErased()
    }
}

public func == <P1: TypedTorchProperty where P1.ValueType: NSObjectConvertible>(lhs: P1, rhs: P1.ValueType) -> AnyPredicate<P1.ParentType> {
    return lhs.equalTo(rhs)
}

public func < <P1: TypedTorchProperty where P1.ValueType: NSNumberConvertible>(lhs: P1, rhs: P1.ValueType) -> AnyPredicate<P1.ParentType> {
    return lhs.lessThan(rhs)
}

public func <= <P1: TypedTorchProperty where P1.ValueType: NSNumberConvertible>(lhs: P1, rhs: P1.ValueType) -> AnyPredicate<P1.ParentType> {
    return lhs.lessThanOrEqualTo(rhs)
}

public func >= <P1: TypedTorchProperty where P1.ValueType: NSNumberConvertible>(lhs: P1, rhs: P1.ValueType) -> AnyPredicate<P1.ParentType> {
    return lhs.greaterThanOrEqualTo(rhs)
}

public func > <P1: TypedTorchProperty where P1.ValueType: NSNumberConvertible>(lhs: P1, rhs: P1.ValueType) -> AnyPredicate<P1.ParentType> {
    return lhs.greaterThan(rhs)
}

public struct SortDescriptor {

    func toSortDescriptors() -> [NSSortDescriptor] {
        return []
    }
}

public protocol OptionalType {
    associatedtype WrappedType

    var value: WrappedType? { get }
}

extension Optional: OptionalType {
    public typealias WrappedType = Wrapped

    public var value: Wrapped? {
        return self
    }
}

public class EntityRegistry {
    public private(set) var registeredEntities: [String: NSEntityDescription] = [:]

    public init() { }

    public func description<E: TorchEntity>(of entityType: E.Type) -> NSEntityDescription {
        if let registeredEntity = registeredEntities[entityType.torch_name] {
            return registeredEntity
        }

        let entity = NSEntityDescription()
        entity.name = entityType.torch_name

        // Assume that there is a correct `E` managed object class.
        //        entity.managedObjectClassName = String(E) <-- FIXME Do we need this?

        let propertyRegistry = PropertyRegistry(entityRegistry: self)

        for property in entityType.torch_properties {
            property.describe(to: propertyRegistry)
        }

        entity.properties = Array(propertyRegistry.registeredProperties.values)

        registeredEntities[entityType.torch_name] = entity
        return entity
    }
}

struct PropertyHelper {
    private static let typesArray: [(Any.Type, NSAttributeType)] = [
        (Int.self, NSAttributeType.Integer64AttributeType),
        (String.self, NSAttributeType.StringAttributeType),

        (Optional<Int>.self, NSAttributeType.Integer64AttributeType),
        (Optional<String>.self, NSAttributeType.StringAttributeType),
        ]

    private static let types: [ObjectIdentifier: NSAttributeType] = typesArray
        .reduce([:]) { acc, item in
            var mutableAccumulator = acc
            mutableAccumulator[ObjectIdentifier(item.0)] = item.1
            return mutableAccumulator
    }

    static func attributeType<T>(forType type: T.Type) -> NSAttributeType {
        let key = ObjectIdentifier(type)
        return types[key] ?? NSAttributeType.UndefinedAttributeType
    }
}

public class PropertyRegistry {
    let entityRegistry: EntityRegistry

    public private(set) var registeredProperties: [String: NSPropertyDescription] = [:]

    public init(entityRegistry: EntityRegistry) {
        self.entityRegistry = entityRegistry
    }

    public func attribute<P: TypedTorchProperty>(property: P) -> NSAttributeDescription {
        let attribute = NSAttributeDescription()
        attribute.name = property.name
        attribute.attributeType = PropertyHelper.attributeType(forType: P.ValueType.self)
        attribute.optional = false

        return registered(attribute)
    }

    public func attribute<P: TypedTorchProperty where P.ValueType: OptionalType>(property: P) -> NSAttributeDescription {
        let attribute = NSAttributeDescription()
        attribute.name = property.name
        attribute.attributeType = PropertyHelper.attributeType(forType: P.ValueType.WrappedType.self)
        attribute.optional = true
        return registered(attribute)
    }

    public func relationship<P: TypedTorchProperty where P.ValueType: TorchEntity>(property: P) -> NSRelationshipDescription {
        let relationship = NSRelationshipDescription()
        relationship.name = property.name
        print(relationship)
        relationship.destinationEntity = entityRegistry.description(of: P.ValueType.self)
        relationship.deleteRule = .NullifyDeleteRule
        relationship.minCount = 1
        relationship.maxCount = 1
        print(relationship)
        return registered(relationship)
    }

    public func relationship<P: TypedTorchProperty where P.ValueType: OptionalType, P.ValueType.WrappedType: TorchEntity>(property: P) -> NSRelationshipDescription {
        let relationship = NSRelationshipDescription()
        relationship.name = property.name
        relationship.destinationEntity = entityRegistry.description(of: P.ValueType.WrappedType.self)
        relationship.deleteRule = .NullifyDeleteRule
        relationship.optional = true
        relationship.minCount = 1
        relationship.maxCount = 1
        return registered(relationship)
    }

    public func relationship<P: TypedTorchProperty where P.ValueType: SequenceType, P.ValueType.Generator.Element: TorchEntity>(property: P) -> NSRelationshipDescription {
        let relationship = NSRelationshipDescription()
        relationship.name = property.name
        relationship.destinationEntity = entityRegistry.description(of: P.ValueType.Generator.Element.self)
        relationship.deleteRule = .NullifyDeleteRule
        relationship.minCount = 0
        relationship.maxCount = 0
        return registered(relationship)
    }

    public func relationship<P: TypedTorchProperty where P.ValueType: OptionalType, P.ValueType.WrappedType: SequenceType, P.ValueType.WrappedType.Generator.Element: TorchEntity>(property: P) -> NSRelationshipDescription {
        let relationship = NSRelationshipDescription()
        relationship.name = property.name
        relationship.destinationEntity = entityRegistry.description(of: P.ValueType.WrappedType.Generator.Element.self)
        relationship.deleteRule = .NullifyDeleteRule
        relationship.optional = true
        relationship.minCount = 0
        relationship.maxCount = 0
        return registered(relationship)
    }

    private func registered<D: NSPropertyDescription>(description: D) -> D {
        registeredProperties[description.name] = description
        return description
    }
}

public struct AnyProperty<PARENT: TorchEntity>: TorchProperty {
    public typealias ParentType = PARENT

    public let name: String
    public let describeFunction: (PropertyRegistry) -> Void

    public func describe(to registry: PropertyRegistry) {
        describeFunction(registry)
    }
}

public struct ScalarProperty<PARENT: TorchEntity, T>: TypedTorchProperty {
    public typealias ParentType = PARENT
    public typealias ValueType = T

    public let name: String

    public init(name: String) {
        self.name = name
    }

    public func describe(to registry: PropertyRegistry) {
        registry.attribute(self)
    }
}

public struct ToOneRelationProperty<PARENT: TorchEntity, T: TorchEntity>: TypedTorchProperty {
    public typealias ParentType = PARENT
    public typealias ValueType = T

    public let name: String

    public init(name: String) {
        self.name = name
    }

    public func describe(to registry: PropertyRegistry) {
        registry.relationship(self)
    }
}

public struct ToManyRelationProperty<PARENT: TorchEntity, T: SequenceType where T.Generator.Element: TorchEntity>: TypedTorchProperty {
    public typealias ParentType = PARENT
    public typealias ValueType = T
    
    public let name: String
    
    public init(name: String) {
        self.name = name
    }
    
    public func describe(to registry: PropertyRegistry) {
        registry.relationship(self)
    }
}