//
//  ListVC.swift
//  LocalData
//
//  Created by Sathish on 29/04/24.
//

import UIKit
import CoreData

class ListVC: UIViewController {
    
    @IBOutlet weak var navigationView: UIView!
    @IBOutlet weak var usersTV: UITableView!
    @IBOutlet weak var tblvBgView: UIView!
    @IBOutlet weak var loaderView: UIView!
    @IBOutlet weak var loader: UIActivityIndicatorView!
    
    
    
    let vm = ViewModel()
    var userArray:[User] = []
    let appDelegate = UIApplication.shared.delegate as! AppDelegate

    override func viewDidLoad() {
        super.viewDidLoad()
        self.loader.startAnimating()
        self.loaderView.isHidden = false
        self.registerTblView()
        self.tblvBgView.isHidden = true
        self.fetchUsers()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.loader.startAnimating()
        self.loaderView.isHidden = false
        self.vm.fetchModelObjects { users in
            self.loader.stopAnimating()
            self.loaderView.isHidden = true
            self.userArray.removeAll()
            self.userArray = users
        }
    }
    
    func registerTblView(){
        self.usersTV.register(UINib(nibName: "ListCell", bundle: nil), forCellReuseIdentifier: "ListCell")
        self.usersTV.delegate = self
        self.usersTV.dataSource = self
        self.usersTV.reloadData()
    }

    @IBAction func addUsersBtnTapped(_ sender: UIButton){
        let vc = DetailsVC()
        vc.isFor = "create"
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func fetchUsers(){
        self.vm.fetchUsers { status in
            self.loader.stopAnimating()
            self.loaderView.isHidden = true
            if status{
                if self.vm.userModel.count > 0{
                    self.userArray.removeAll()
                    self.userArray = self.vm.userModel
                    self.tblvBgView.isHidden = false
                    self.usersTV.reloadData()
                }
            }else{
                print("Error while fetching users")
            }
        }
    }
    
    
    
    @IBAction func clearDataBtnTapped(_ sender: UIButton) {
        let managedContext = self.appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Users")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        do{
            try managedContext.execute(deleteRequest)
            self.userArray.removeAll()
            self.tblvBgView.isHidden = false
            self.usersTV.reloadData()
        }catch{
            print("Error clearing Data: ",error.localizedDescription)
        }
    }
    

}

extension ListVC: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.userArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ListCell", for: indexPath) as! ListCell
        cell.selectionStyle = .none
        let user = self.userArray[indexPath.row]
        cell.nameLbl.text = "\(indexPath.row + 1). \(user.name ?? "")"
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = DetailsVC()
        let user = self.userArray[indexPath.row]
        vc.user = user
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
}
