//
//  SettingsViewController.swift
//  LingoMate Port
//
//  Created by UCF 2 on 22/01/2025.
//

import UIKit

class SettingsViewController: UIViewController {
    @IBOutlet weak var versionLb:UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
     
        let version = Bundle.main.infoDictionary!["CFBundleShortVersionString"]!
        let build = Bundle.main.infoDictionary!["CFBundleVersion"]!
        versionLb.text = "Version \(version) (\(build))"
       
    }
    
     
    @IBAction func homebtnPressed(_ sender:UIButton)
    {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let newViewController = storyBoard.instantiateViewController(withIdentifier: "DashboardViewController") as! DashboardViewController
        newViewController.modalPresentationStyle = UIModalPresentationStyle.fullScreen
        newViewController.modalTransitionStyle = .crossDissolve
        self.present(newViewController, animated: true)
    }
    
    @IBAction func OCRbtnPressed(_ sender:UIButton)
    {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let newViewController = storyBoard.instantiateViewController(withIdentifier: "VisualReaderViewController") as! VisualReaderViewController
        newViewController.modalPresentationStyle = UIModalPresentationStyle.fullScreen
        newViewController.modalTransitionStyle = .crossDissolve
        self.present(newViewController, animated: true)
    }
    
    
    @IBAction func learnMorebtnPressed(_ sender:UIButton)
    {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let newViewController = storyBoard.instantiateViewController(withIdentifier: "AboutViewController") as! AboutViewController
        newViewController.modalPresentationStyle = UIModalPresentationStyle.fullScreen
        newViewController.modalTransitionStyle = .crossDissolve
        self.present(newViewController, animated: true)
    }
    
    @IBAction func feedbackbtnPressed(_ sender:UIButton)
    {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let newViewController = storyBoard.instantiateViewController(withIdentifier: "FeedbackViewController") as! FeedbackViewController
        newViewController.modalPresentationStyle = UIModalPresentationStyle.fullScreen
        newViewController.modalTransitionStyle = .crossDissolve
        self.present(newViewController, animated: true)
    }

    
    
    @IBAction func sharebtnPressed(_ sender:UIButton)
    {
        let appID = "VoiceCrafterWave"
           let appStoreURL = URL(string: "https://apps.apple.com/app/id\(appID)")!
           
           let activityViewController = UIActivityViewController(activityItems: [appStoreURL], applicationActivities: nil)
           
           // For iPads
           if let popoverController = activityViewController.popoverPresentationController {
               popoverController.barButtonItem = sender as? UIBarButtonItem
           }
           
           present(activityViewController, animated: true, completion: nil)
    }

    @IBAction func backbtnPressed(_ sender:UIButton)
    {
        self.dismiss(animated: true)
    }
    

}
