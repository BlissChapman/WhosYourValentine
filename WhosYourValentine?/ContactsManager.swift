//
//  ContactsManager.swift
//  WhosYourValentine?
//
//  Created by Bliss Chapman on 1/5/16.
//  Copyright © 2016 Bliss Chapman. All rights reserved.
//

import Foundation
import UIKit
import Contacts

struct ContactsManager {
    
    private let contactStore = CNContactStore()

    ///Detects the users permission to view their contacts and requests permission if necessary, passing the result of the request to the completionHandler.
    func requestAccess(withCompletionHandler completionHandler: @escaping (_ accessGranted: Bool, _ accessError: Error?) -> Void) {
        let authorizationStatus = CNContactStore.authorizationStatus(for: .contacts)
        
        switch authorizationStatus {
        case .authorized:
            completionHandler(true, nil)
        case .notDetermined:
            contactStore.requestAccess(for: .contacts) { access, accessError in
                completionHandler(access, accessError)
            }
        case .denied, .restricted:
            completionHandler(false, nil)
        }
    }
    
    ///Finds a random contact with a valid name and contact photo.  If successful, the name and photo will be passed into the completion handler, otherwise the tuple will be nil.
    func chooseRandomValentine(withCompletionHandler completionHandler: @escaping ((name: String, contactPhoto: UIImage)?) -> Void) {
        
        retrievePotentialValentines { contacts in
            guard let potentialValentines = contacts else {
                completionHandler(nil)
                return
            }
            
            //chose random contact from potentialValentines
            let randomContactIndex = Int(arc4random_uniform(UInt32(potentialValentines.count)))
            let randomlyChosenValentine = potentialValentines[randomContactIndex]
            
            //retrieve the contacts full name
            guard let fullName = CNContactFormatter.string(from: randomlyChosenValentine, style: .fullName) else {
                completionHandler(nil)
                return
            }
            
            //retrieve the contacts photo which is guaranteed to exist
            let contactPhoto = UIImage(data: randomlyChosenValentine.imageData!)!
            
            //send the contacts info to the completionHandler
            let valentinesInfo = (name: fullName, contactPhoto: contactPhoto)
            completionHandler(valentinesInfo)
        }
    }

    private func retrievePotentialValentines(withCompletionHandler completionHandler: @escaping ([CNContact]?) -> Void) {
        
        // move off the main queue while doing computationally intensieve tasks like enumerating through a users entire contacts list
        DispatchQueue.global(qos: .userInitiated).async {
            
            //an array of contact properties to be fetched in the returned contacts
            let keys: [CNKeyDescriptor] = [
                CNContactImageDataAvailableKey as CNKeyDescriptor,
                CNContactImageDataKey as CNKeyDescriptor,
                CNContactFormatter.descriptorForRequiredKeys(for: .fullName) as CNKeyDescriptor
            ]
            
            //the contact fetch request that will fetch all contacts and the requested properties
            let fetchRequest = CNContactFetchRequest(keysToFetch: keys)
            
            //an array we will fill with the results of the fetch
            var validResults: [CNContact] = []
            
            
            do {
                //fetch all contacts
                try self.contactStore.enumerateContacts(with: fetchRequest) { contact, stop in
                    
                    //if the contact could be our valentine, then add it to the array of valid results
                    if contact.isPotentialValentine {
                        validResults.append(contact)
                    }
                }

                // pass the valid results to the completionHandler
                validResults.isEmpty ? completionHandler(nil) : completionHandler(validResults)
                
            } catch {
                debugPrint(error)
                completionHandler(nil)
            }
        }
    }
}


extension CNContact {
    ///Represents whether a contact could be a potential valentine by checking if it has existing image data and a full name.
    var isPotentialValentine: Bool {
        return self.imageDataAvailable && CNContactFormatter.string(from: self, style: .fullName) != nil
    }
}
