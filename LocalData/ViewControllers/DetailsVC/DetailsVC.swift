//
//  DetailsVC.swift
//  LocalData
//
//  Created by Sathish on 29/04/24.
//

import UIKit
import MapKit
import CoreLocation

class DetailsVC: UIViewController,MKMapViewDelegate {
    
    @IBOutlet weak var navigationView: UIView!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var nameTF: UITextField!
    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var phoneTF: UITextField!
    @IBOutlet weak var maleView: UIView!
    @IBOutlet weak var maleSelView: UIView!
    @IBOutlet weak var femaleView: UIView!
    @IBOutlet weak var femaleSelView: UIView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var maleBtn: UIButton!
    @IBOutlet weak var femaleBtn: UIButton!
    
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var user : User!
    var manager = CLLocationManager()
    var vm = ViewModel()
    var gender = "male"
    var isFor = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        self.configLocationManager()
        self.configUI()
        if self.isFor != "create"{
            self.setDetails()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        DispatchQueue.global(qos: .background).async{
            self.manager.stopUpdatingLocation()
        }
    }
    
    func configLocationManager(){
        manager.delegate = self
        manager.requestWhenInUseAuthorization()
        manager.requestAlwaysAuthorization()
        manager.startUpdatingLocation()
    }
    
    func showLocationPermissionAlert() {
        let alertController = UIAlertController(title: "Location Access Denied",
                                                message: "To enable location-based features, please go to Settings and turn on Location Services for this app.",
                                                preferredStyle: .alert)
        let settingsAction = UIAlertAction(title: "Settings", style: .default) { (_) -> Void in
            guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                return
            }
            if UIApplication.shared.canOpenURL(settingsUrl) {
                UIApplication.shared.open(settingsUrl, completionHandler: nil)
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alertController.addAction(settingsAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    
    func configUI(){
        self.maleSelView.roundView()
        self.maleView.roundView()
        self.femaleView.roundView()
        self.femaleSelView.roundView()
        
        self.maleBtn.tag = 0
        self.femaleBtn.tag = 1
        
        self.maleSelView.backgroundColor = .blue
        self.femaleSelView.backgroundColor = .blue
        
        if self.gender == "male"{
            self.maleSelView.isHidden = false
            self.femaleSelView.isHidden = true
        }else{
            self.maleSelView.isHidden = true
            self.femaleSelView.isHidden = false
        }
        
        self.maleView.setBorder(value: 2.0)
        self.femaleView.setBorder(value: 2.0)
        
        self.mapView.layer.cornerRadius = 5
        self.mapView.clipsToBounds = true
        self.mapView.delegate = self
    }
    
    func setDetails(){
        self.nameTF.text = user.name
        self.emailTF.text = user.email
        self.phoneTF.text = user.mobile
        
        let gender = user.gender
        if gender == "male"{
            self.maleSelView.isHidden = false
            self.femaleSelView.isHidden = true
        }else{
            self.maleSelView.isHidden = true
            self.femaleSelView.isHidden = false
        }
    }

    
    @IBAction func SaveBtnTapped(_ sender: UIButton){
        var isValid = false
        var msg = ""
        if self.nameTF.text == ""{
            msg = "Name Field not be Empty!"
            isValid = false
        }else if self.emailTF.text == ""{
            msg = "Email Field not be Empty!"
            isValid = false
        }else if self.phoneTF.text == ""{
            msg = "Mobile Field not be Empty!"
            isValid = false
        }else{
            isValid = true
        }
        
        if isValid{
            if self.isFor == "create"{
                self.vm.createUser(name: self.nameTF.text!, email: self.emailTF.text!, mobile: self.phoneTF.text!, gender: self.gender) { status in
                    var msg = "User Created Successfully"
                    if !status{
                        msg = "Something went wrong"
                    }
                    let alert = UIAlertController(title: "Alert", message: msg, preferredStyle: .alert)
                    let okay = UIAlertAction(title: "Okay", style: .default) { _ in
                        if status{
                            self.navigationController?.popViewController(animated: true)
                        }
                    }
                    alert.addAction(okay)
                    self.present(alert, animated: true)
                    
                }
            }else{
                self.vm.updateData(id: self.user.id ?? "", name: self.nameTF.text!, email: self.emailTF.text!, mobile: self.phoneTF.text!, gender: self.gender) { status in
                    var msg = "User Updated Successfully"
                    if !status{
                        msg = "Something went wrong"
                    }
                    let alert = UIAlertController(title: "Alert", message: msg, preferredStyle: .alert)
                    let okay = UIAlertAction(title: "Okay", style: .default) { _ in
                        if status{
                            self.navigationController?.popViewController(animated: true)
                        }
                    }
                    alert.addAction(okay)
                    self.present(alert, animated: true)
                }
            }
        }else{
            let alert = UIAlertController(title: "Alert", message: msg, preferredStyle: .alert)
            let okay = UIAlertAction(title: "Okay", style: .default)
            alert.addAction(okay)
            self.present(alert, animated: true)
        }
    }
    
    
    @IBAction func backBtnTapped(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func genderBtnTapped(_ sender: UIButton){
        if sender.tag == 0{
            self.maleSelView.isHidden = false
            self.femaleSelView.isHidden = true
            self.gender = "male"
        }else{
            self.maleSelView.isHidden = true
            self.femaleSelView.isHidden = false
            self.gender = "female"
        }
    }
    

}


extension DetailsVC: CLLocationManagerDelegate{

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.last
       let center = CLLocationCoordinate2D(latitude: location!.coordinate.latitude, longitude: location!.coordinate.longitude)
       let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
       self.mapView.setRegion(region, animated: true)
       if self.mapView.annotations.count != 0 {
          let annotation = self.mapView.annotations[0]
          self.mapView.removeAnnotation(annotation)
       }
       let pointAnnotation = MKPointAnnotation()
       pointAnnotation.coordinate = location!.coordinate
       pointAnnotation.title = ""
       mapView.addAnnotation(pointAnnotation)
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            // Permission granted, you can now use location services
            manager.startUpdatingLocation()
            break
        case .denied, .restricted:
            // Permission denied, handle accordingly
            self.showLocationPermissionAlert()
            break
        case .notDetermined:
            // Permission not yet determined, request again
            manager.requestWhenInUseAuthorization()
            manager.requestAlwaysAuthorization()
            break
        @unknown default:
            break
        }
    }
    
}

extension DetailsVC: UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
    }
}
