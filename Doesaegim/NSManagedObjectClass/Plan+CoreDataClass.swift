//
//  Plan+CoreDataClass.swift
//  Doesaegim
//
//  Created by sun on 2022/11/14.
//
//

import CoreData
import Foundation


public class Plan: NSManagedObject {
    
    // MARK: - Functions
    
    @discardableResult
    static func addAndSave(with object: PlanDTO) throws -> Plan {
        let context = PersistentManager.shared.context
        let plan = Plan(context: context)
        plan.id = object.id
        plan.name = object.name
        plan.content = object.content
        plan.date = object.date
        plan.isComplete = object.isComplete
        object.travel.addToPlan(plan)

        try PersistentManager.shared.saveContext()
        
        return plan
    }

    /// 모든 Plan엔티티를 가져옴
    static func fetchRequest(
        predicate: NSPredicate,
        sortDescriptors: [NSSortDescriptor]
    ) -> NSFetchRequest<Plan> {

        let request = NSFetchRequest<Plan>(entityName: Plan.name)
        request.predicate = predicate
        request.sortDescriptors = sortDescriptors

        return request
    }

    /// 특정 Travel 엔티티의 모든 Plan을 호출하는 리퀘스트로 순서를 지정하지 않으면 (오래된) 날짜 순서로 정렬
    static func fetchRequest(
        travel: Travel,
        sortDescriptors: [NSSortDescriptor] = [.init(key: "date", ascending: false)]
    ) -> NSFetchRequest<Plan> {

        let predicate = NSPredicate(format: "travel == %@", argumentArray: [travel])
        return fetchRequest(predicate: predicate, sortDescriptors: sortDescriptors)
    }
}
