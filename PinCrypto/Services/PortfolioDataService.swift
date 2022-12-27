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
            self.getPortfolio()
        }
    }
    
    func updatePortfolio(coin: CoinModel, amount: Double) {
        // check if coin is already in portfolio
        if let entity = savedEntities.first(where: { $0.coinID == coin.id }) {
            if amount > 0 {
                update(entity: entity, amount: amount)
            } else {
                delete(entity: entity)
            }
        } else {
            add(coin: coin, amount: amount)
        }
    }
}

// MARK: - Private functions
private extension PortfolioDataService {
    func getPortfolio() {
        let request = NSFetchRequest<PortfolioEntity>(entityName: entityName)
        
        do {
            savedEntities = try contanier.viewContext.fetch(request)
        } catch let error {
            print("Error fetching Portfolio Entities. \(error)")
        }
    }
    
    func add(coin: CoinModel, amount: Double) {
        // convert coin model to entity
        let entity = PortfolioEntity(context: contanier.viewContext)
        entity.coinID = coin.id
        entity.amount = amount
        applyChanges()
    }
    
    func update(entity: PortfolioEntity, amount: Double) {
        entity.amount = amount
        applyChanges()
    }
    
    func delete(entity: PortfolioEntity) {
        contanier.viewContext.delete(entity)
        applyChanges()
    }
    
    func save() {
        do {
            try contanier.viewContext.save()
        } catch let error {
            print("Error saving to Core Data. \(error)")
        }
    }
    
    func applyChanges() {
        save()
        getPortfolio()
    }
}
