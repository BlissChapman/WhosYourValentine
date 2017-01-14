//
//  ViewController.swift
//  WhosYourValentine?
//
//  Created by Bliss Chapman on 1/4/16.
//  Copyright © 2016 Bliss Chapman. All rights reserved.
//

import UIKit

final class ViewController: UIViewController {
    
    @IBOutlet weak var promptLabel: UILabel!
    @IBOutlet weak var valentinesPortraitImageView: UIImageView!
    @IBOutlet weak var valentinesNameLabel: UILabel!
    
    private let contactsManager = ContactsManager()

    // MARK: - View Controller Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func motionEnded(_ motion: UIEventSubtype, with event: UIEvent?) {
        
        if motion == .motionShake {
            self.promptLabel.text = "Searching..."
            
            contactsManager.requestAccess { (accessGranted, accessError) -> Void in
                guard accessError == nil else {
                    debugPrint(accessError!)
                    return
                }
                
                if accessGranted {
                    self.contactsManager.chooseRandomValentine { valentineInfo in
                        
                        //explicitly move back to the main queue to handle UI related tasks
                        DispatchQueue.main.async { () -> Void in
                            
                            guard let valentineInfo = valentineInfo else {
                                self.promptLabel.text = "You will be lonely for life."
                                return
                            }
                            
                            self.promptLabel.text = "We found you a match!"
                            self.valentinesPortraitImageView.image = valentineInfo.contactPhoto
                            self.valentinesNameLabel.text = "\(valentineInfo.name)"
                        }
                    }
                } else {
                    self.promptLabel.text = "We require access to your contacts in order to function.  Please adjust your privacy settings."
                }
            }
        }
    }
}
