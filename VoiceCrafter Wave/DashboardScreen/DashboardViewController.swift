//
//  DashboardViewController.swift
//  VoiceCrafter Wave
//
//  Created by UCF 2 on 23/01/2025.
//

import UIKit
import Photos
import Vision
class DashboardViewController: UIViewController {
    
    @IBOutlet weak var quickTranslate:UIButton!
    @IBOutlet weak var visualReader:UIButton!
    @IBOutlet weak var voiceCapture:UIButton!
    @IBOutlet weak var appPreferences:UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        roundCorner(button: quickTranslate)
        roundCorner(button: visualReader)
        roundCorner(button: voiceCapture)
        roundCorner(button: appPreferences)

    
        // Do any additional setup after loading the view.
    }


    @IBAction func quickTranslate(_ sender:UIButton)
    {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let newViewController = storyBoard.instantiateViewController(withIdentifier: "QuicktranslateViewController") as! QuicktranslateViewController
        newViewController.modalPresentationStyle = UIModalPresentationStyle.fullScreen
        newViewController.modalTransitionStyle = .crossDissolve
        self.present(newViewController, animated: true, completion: nil)

    }
    @IBAction func visualReader(_ sender:UIButton)
    {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let newViewController = storyBoard.instantiateViewController(withIdentifier: "VisualReaderViewController") as! VisualReaderViewController
        newViewController.modalPresentationStyle = UIModalPresentationStyle.fullScreen
        newViewController.modalTransitionStyle = .crossDissolve
        self.present(newViewController, animated: true, completion: nil)

    }
    @IBAction func voiceCapture(_ sender:UIButton)
    {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let newViewController = storyBoard.instantiateViewController(withIdentifier: "VoiceCaptureViewController") as! VoiceCaptureViewController
        newViewController.modalPresentationStyle = UIModalPresentationStyle.fullScreen
        newViewController.modalTransitionStyle = .crossDissolve
        self.present(newViewController, animated: true, completion: nil)

    }
    
    @IBAction func appPreferences(_ sender:UIButton)
    {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let newViewController = storyBoard.instantiateViewController(withIdentifier: "SettingsViewController") as! SettingsViewController
        newViewController.modalPresentationStyle = UIModalPresentationStyle.fullScreen
        newViewController.modalTransitionStyle = .crossDissolve
        self.present(newViewController, animated: true, completion: nil)

    }
    
    @IBAction func hitorybntn(_ sender:UIButton)
    {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let newViewController = storyBoard.instantiateViewController(withIdentifier: "HistoryViewController") as! HistoryViewController
        newViewController.modalPresentationStyle = UIModalPresentationStyle.fullScreen
        newViewController.modalTransitionStyle = .crossDissolve
        self.present(newViewController, animated: true, completion: nil)

    }



}
