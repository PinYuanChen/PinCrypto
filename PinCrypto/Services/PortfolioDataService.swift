//
// Created on 2022/12/27.
//

import Foundation
import CoreData

class PortfolioDataService {
    
    private let contanier: NSPersistentContainer
    private let contanierName = "PortfolioContainer"
    private let entityName = "PortfolioEntity"
    
    @Published var savedEntities = [PortfolioEntity]()
    
    init() {
        contanier = NSPersistentContainer(name: contanierName)
        contanier.loadPersistentStores { _, error in
            if let error = error {
                print("Error loading Core Data! \(error)")
            }
        }
    }
}

private extension PortfolioDataService {
    func getPortfolio() {
        let request = NSFetchRequest<PortfolioEntity>(entityName: entityName)
        
        do {
            savedEntities = try contanier.viewContext.fetch(request)
        } catch let error {
            print("Error fetching Portfolio Entities. \(error)")
        }
    }
}
