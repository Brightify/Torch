//
//  UnsafeTorch.swift
//  Torch
//
//  Created by Filip Dolnik on 20.07.16.
//  Copyright © 2016 Brightify. All rights reserved.
//

public class UnsafeTorch {
    
    private let torch: Torch
    
    public convenience init(store: StoreConfiguration, entities: TorchEntityDescription.Type...) {
        self.init(store: store, entities: entities)
    }
 
    public init(store: StoreConfiguration, entities: [TorchEntityDescription.Type]) {
        do {
            torch = try Torch(store: store, entities: entities)
        } catch {
            fatalError(String(error))
        }
    }
    
    public func load<T: TorchEntity>(type: T.Type) -> [T] {
        return load(type, where: TorchPredicate(value: true))
    }
    
    public func load<T: TorchEntity>(type: T.Type, where predicate: TorchPredicate<T>, orderBy: SortDescriptor = SortDescriptor()) -> [T] {
        do {
            return try torch.load(type, where: predicate, orderBy: orderBy)
        } catch {
            fatalError(String(error))
        }
    }
    
    public func save<T: TorchEntity>(inout entity: T) -> UnsafeTorch {
        do {
            try torch.save(&entity)
        } catch {
            fatalError(String(error))
        }
        return self
    }
    
    public func delete<T: TorchEntity>(entities: T...) -> UnsafeTorch {
        delete(entities)
        return self
    }
    
    public func delete<T: TorchEntity>(entities: [T]) -> UnsafeTorch {
        do {
            try torch.delete(entities)
        } catch {
            fatalError(String(error))
        }
        return self
    }
    
    public func delete<T: TorchEntity>(type: T.Type, where predicate: TorchPredicate<T>) -> UnsafeTorch {
        do {
            try torch.delete(type, where: predicate)
        } catch {
            fatalError(String(error))
        }
        return self
    }
    
    public func deleteAll<T: TorchEntity>(type: T.Type) -> UnsafeTorch {
        do {
            try torch.deleteAll(type)
        } catch {
            fatalError(String(error))
        }
        return self
    }
    
    public func rollback() -> UnsafeTorch {
        torch.rollback()
        return self
    }
    
    public func write(@noescape closure: () -> () = {}) -> UnsafeTorch {
        do {
            try torch.write(closure)
        } catch {
            fatalError(String(error))
        }
        return self
    }
}
