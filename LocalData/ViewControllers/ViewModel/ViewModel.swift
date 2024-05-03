//
//  ViewModel.swift
//  LocalData
//
//  Created by Sathish on 29/04/24.
//

import Foundation
import Alamofire
import CoreData

class ViewModel {
    let web = WebServices.shared
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var userModel:[User] = []
    
    func createUser(name: String, email: String, mobile: String, gender: String,completion: @escaping (Bool) -> Void){
        let params = [
            "name": name,
            "email": email,
            "mobile": mobile,
            "gender": gender
        ]
        self.web.createData(data: params) { result in
            switch result {
            case .success(let responseData):
                do{
                    let json = try JSONSerialization.jsonObject(with: responseData!)
                    print(json)
                    completion(true)
                }catch{
                    print(error.localizedDescription)
                    completion(false)
                }
            case .failure(let error):
                print("Error creating data: \(error)")
                completion(false)
            }
        }
    }
    
    func fetchUsers(completion: @escaping (Bool) -> Void){
        self.web.fetchData { result in
            switch result {
            case .success(let responseData):
                do{
                    let json = try JSONSerialization.jsonObject(with: responseData!)
                    print(json)
                    do {
                        let decoder = JSONDecoder()
                        let items = try decoder.decode([User].self, from: responseData!)
                        let result = self.saveDataToCoreData(items: items)
                        if result{
                            completion(true)
                        }else{
                            completion(false)
                        }
                    }catch{
                        completion(false)
                        print(error.localizedDescription)
                    }
                    
                }catch{
                    completion(false)
                    print(error.localizedDescription)
                }
            case .failure(let error):
                completion(false)
                print("Error Fetch data: \(error)")
            }
        }
    }
    
    func saveDataToCoreData(items: [User]) -> Bool {
        let managedContext = self.appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Users")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try managedContext.execute(deleteRequest)
            for item in items {
                let entity = NSEntityDescription.entity(forEntityName: "Users", in: managedContext)!
                let newItem = NSManagedObject(entity: entity, insertInto: managedContext)
                newItem.setValue(item.id, forKey: "id")
                newItem.setValue(item.name, forKey: "name")
                newItem.setValue(item.email, forKey: "email")
                newItem.setValue(item.gender, forKey: "gender")
                newItem.setValue(item.mobile, forKey: "mobile")
            }
            
            try managedContext.save()
            self.fetchModelObjects { users in
                self.userModel = users
                print("Data saved to CoreData")
            }
            return true
        } catch {
            print("Error saving to CoreData: \(error)")
            return false
        }
    }
    
    func fetchModelObjects(completion: @escaping ([User]) -> Void) {
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Users")
        var users: [User] = []
        do {
            let result = try managedContext.fetch(fetchRequest)
            for data in result as! [NSManagedObject] {
                let id = data.value(forKey: "id") as? String ?? ""
                let name = data.value(forKey: "name") as? String ?? ""
                let email = data.value(forKey: "email") as? String ?? ""
                let mobile = data.value(forKey: "mobile") as? String ?? ""
                let gender = data.value(forKey: "gender") as? String ?? ""
                let result = User()
                result.id = id
                result.name = name
                result.mobile = mobile
                result.email = email
                result.gender = gender
                users.append(result)
            }
            completion(users)
        } catch {
            print("Error fetching data from CoreData: \(error)")
            completion(users)
        }
    }
    
    
    func updateData(id: String, name: String, email: String, mobile: String, gender: String,completion: @escaping (Bool) -> Void){
        let params = [
            "name": name,
            "email": email,
            "mobile": mobile,
            "gender": gender
        ]
        self.web.updateData(id: id, data: params) { result in
            switch result {
            case .success(let responseData):
                do{
                    let json = try JSONSerialization.jsonObject(with: responseData!)
                    print(json)
                    completion(true)
                }catch{
                    print(error.localizedDescription)
                    completion(true)
                }
            case .failure(let error):
                print("Error Updating data: \(error)")
                completion(true)
            }
        }
        
    }
    
    func deleteData(id: String, completion: @escaping (Bool) -> Void){
        self.web.deleteData(id: id) { result in
            switch result {
            case .success(let responseData):
                do{
                    let json = try JSONSerialization.jsonObject(with: responseData!)
                    print(json)
                    completion(true)
                }catch{
                    print(error.localizedDescription)
                    completion(false)
                }
            case .failure(let error):
                print("Error Deleting data: \(error)")
                completion(false)
            }
        }
    }
    
    
}
