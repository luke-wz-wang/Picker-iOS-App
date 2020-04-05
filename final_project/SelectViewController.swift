//
//  selectViewController.swift
//  final_project
//
//  Created by Yangjun Bie on 3/17/20.
//

/*Attribute to:
 https://www.hackingwithswift.com/example-code/uikit/how-to-load-a-remote-image-url-into-uiimageview
 */

import UIKit

struct url_id {
    var photoURL: String?
    var restaurantID: Int?
}

class selectViewController: UIViewController {
    
    @IBOutlet var picsView: UIImageView!
    @IBOutlet var likeAndTrash: [UIImageView]!
    
    let oriPos = CGPoint(x: 207, y: 471 )
    var urlArr =  [url_id]()
    var restaurants = [Restaurant]()
    var scores = [Int]()
    var imgIndex = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        var panGesture  = UIPanGestureRecognizer()
        panGesture = UIPanGestureRecognizer(target: self, action: #selector(self.panGestureHandler(recognizer: )))
        
        picsView.isUserInteractionEnabled = true
        picsView.addGestureRecognizer(panGesture)
        
        picsView.load(url: URL(string: urlArr[imgIndex].photoURL!)!)

        scores = Array(repeating: 0, count: urlArr.count)
        
    }
    
    func userChoice(choices: [UIImageView], center: CGPoint) -> Int {
        for i in 0...choices.count - 1 {
            if choices[i].frame.contains(center) {
                return i
            }
        }
        return -1;
    }
    
    @IBAction func panGestureHandler( recognizer:UIPanGestureRecognizer) {
        switch recognizer.state {
        case .changed:
            let translation = recognizer.translation(in: self.view)
            if let view = recognizer.view {
                view.center = CGPoint(x:view.center.x + translation.x,
                                      y:view.center.y + translation.y)
            }
        case .ended:
            let endPos = CGPoint(x: recognizer.view!.center.x, y: recognizer.view!.center.y)

            let index = self.userChoice(choices: likeAndTrash, center: endPos)
            if index == -1 {
                recognizer.view!.center = CGPoint(x: self.oriPos.x, y: self.oriPos.y)
            }
            else if index == 0 {
                scores[urlArr[imgIndex].restaurantID!] += 1
                imgIndex += 1
                
                if imgIndex >= urlArr.count {
                    showResult()
                }
                else {
                    recognizer.view!.center = CGPoint(x: self.oriPos.x, y: self.oriPos.y)
                    self.picsView.image = UIImage(named: "loading")
                    self.picsView.load(url: URL(string: urlArr[imgIndex].photoURL!)!)
                }
            }
            else {

                imgIndex += 1
                if imgIndex >= urlArr.count {
                    showResult()
                }
                else{
                    recognizer.view!.center = CGPoint(x: self.oriPos.x, y: self.oriPos.y)
                    self.picsView.image = UIImage(named: "loading")
                    self.picsView.load(url: URL(string: urlArr[imgIndex].photoURL!)!)
                }
                
            }
            
        default:
            recognizer.setTranslation(CGPoint.zero, in: self.view)
        }
        
        recognizer.setTranslation(CGPoint.zero, in: self.view)
    }
    
    func showResult() {
        var results = [Restaurant]()
        var a = 0
        var b = 0
        var c = 0
        
        for i in 1...scores.count-1 {
            if scores[i] > scores[a] {
                a = i
            }
        }
        
        for i in 0...scores.count-1 {
            if scores[i] >= scores[b] && scores[i] <= scores[a] &&  a != i {
                b = i
            }
        }
        
        for i in 0...scores.count-1 {
            if scores[i] >= scores[c] && scores[i] <= scores[a] && scores[i] <= scores[b] && a != i && b != i {
                c = i
            }
        }
      
        results.append(restaurants[a])
        results.append(restaurants[b])
        results.append(restaurants[c])
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "resultViewController") as! resultViewController
        vc.modalPresentationStyle = .fullScreen
        vc.modalTransitionStyle = .crossDissolve
        
        vc.finalResults = results
        
        self.present(vc, animated: true, completion: nil)
    }
    

}

extension UIImageView {
    func load(url: URL) {
        DispatchQueue.global().async { [weak self] in
            if let data = try? Data(contentsOf: url) {
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self?.image = image
                    }
                }
            }
        }
    }
}
