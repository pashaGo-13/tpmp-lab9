// MARK: - CoreDataManager.swift
import Foundation
import CoreData

class CoreDataManager {
    static let shared = CoreDataManager()
    
    private var inMemory: Bool = false
    private var customContext: NSManagedObjectContext?
    
    private init() {}
    
    init(inMemory: Bool) {
        self.inMemory = inMemory
    }
    
    func setTestContext(_ context: NSManagedObjectContext) {
        self.customContext = context
    }
    
    lazy var persistentContainer: NSPersistentContainer = {
        if inMemory {
            let container = NSPersistentContainer(name: "GPTravel")
            let description = NSPersistentStoreDescription()
            description.url = URL(fileURLWithPath: "/dev/null")
            container.persistentStoreDescriptions = [description]
            container.loadPersistentStores { _, error in
                if let error = error as NSError? {
                    fatalError("Unresolved error \(error), \(error.userInfo)")
                }
            }
            return container
        } else {
            let container = NSPersistentContainer(name: "GPTravel")
            container.loadPersistentStores { _, error in
                if let error = error as NSError? {
                    fatalError("Unresolved error \(error), \(error.userInfo)")
                }
            }
            return container
        }
    }()
    
    var context: NSManagedObjectContext {
        if let customContext = customContext {
            return customContext
        }
        return persistentContainer.viewContext
    }
    
    func saveContext() {
        let context = context
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                print("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}
