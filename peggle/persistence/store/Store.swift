import CoreData

protocol Store {

    var managedContext: NSManagedObjectContext { get }

    mutating func save() throws

    mutating func rollback()

    mutating func delete<T: NSManagedObject>(_ object: T)
}
