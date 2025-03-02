import CoreData
import UIKit

class StoreClient: Store {

    let managedContext: NSManagedObjectContext

    init?() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return nil
        }

        managedContext = appDelegate.persistentContainer.viewContext
    }

    func save() throws {
        try managedContext.save()
    }

    func rollback() {
        managedContext.rollback()
    }

    func delete<T: NSManagedObject>(_ object: T) {
        managedContext.delete(object)
    }
}
