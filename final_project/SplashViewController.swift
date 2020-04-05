//
//  SplashViewController.swift
//  final_project
//
//  Created by sinze vivens on 2020/3/20.
//

import UIKit

class SplashViewController: UIViewController {

    @IBOutlet weak var versionLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        versionLabel.text = "Current Version " + (Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                  // Your code with navigate to another controller
                   print("load splash over")
                   let vc = self.storyboard?.instantiateViewController(withIdentifier: "mapViewController") as! MapViewController
                   vc.modalPresentationStyle = .fullScreen
                   vc.modalTransitionStyle = .crossDissolve
                   self.present(vc, animated: true, completion: nil)
               }
        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
