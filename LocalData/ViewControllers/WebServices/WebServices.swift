//
//  WebServices.swift
//  LocalData
//
//  Created by Sathish on 29/04/24.
//

import Foundation
import Alamofire

class WebServices{
    static let shared = WebServices()
        
        private let baseURL = "https://crudcrud.com/api/37a9c3150d474cf28c6cf119149f5305/createuser"
        
        func createData(data: [String: Any], completion: @escaping (Result<Data?, Error>) -> Void) {
            AF.request(baseURL, method: .post, parameters: data, encoding: JSONEncoding.default)
                .validate()
                .responseData { response in
                    switch response.result {
                    case .success(let responseData):
                        completion(.success(responseData))
                    case .failure(let error):
                        completion(.failure(error))
                    }
                }
        }
        
        func fetchData(completion: @escaping (Result<Data?, Error>) -> Void) {
            print("Base url: ",self.baseURL)
            AF.request(baseURL, method: .get)
                .validate()
                .responseData { response in
                    switch response.result {
                    case .success(let responseData):
                        completion(.success(responseData))
                    case .failure(let error):
                        completion(.failure(error))
                    }
                }
        }
        
    func updateData(id: String, data: [String: Any], completion: @escaping (Result<Data?, Error>) -> Void) {
        let updateURL = "\(baseURL)/\(id)"
        print("Api url: ",updateURL)
        AF.request(updateURL, method: .put, parameters: data, encoding: JSONEncoding.default)
            .validate()
            .responseData { response in
                switch response.result {
                case .success(let responseData):
                    completion(.success(responseData))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
    }

    func deleteData(id: String, completion: @escaping (Result<Data?, Error>) -> Void) {
        let deleteURL = "\(baseURL)/\(id)"
        AF.request(deleteURL, method: .delete)
            .validate()
            .responseData { response in
                switch response.result {
                case .success(let responseData):
                    completion(.success(responseData))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
    }

}
