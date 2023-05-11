//
//  SignUpViewController.swift
//  AudioSound
//
//  Created by Kevin Nguyen on 5/2/23.
//

import Foundation
import UIKit
import ParseSwift

class SignUpViewController: UIViewController {

    @IBOutlet weak var firstNameField: UITextField!
    @IBOutlet weak var lastNameField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    @IBAction func onSignUpTapped(_ sender: Any) {
        guard let username = usernameField.text,
              let firstName = firstNameField.text,
              let lastName = lastNameField.text,
              let email = emailField.text,
              let password = passwordField.text,
              !username.isEmpty,
              !firstName.isEmpty,
              !lastName.isEmpty,
              !password.isEmpty else {

            showMissingFieldsAlert()
            return
    }

        // TODO: Pt 1 - Parse user sign up
        var newUser = User()
        newUser.username = username
        newUser.firstName = firstName
        newUser.lastName = lastName
        newUser.email = email
        newUser.password = password

        newUser.signup { [weak self] result in

            switch result {
            case .success(let user):

                print("✅ Successfully signed up user \(user)")

                // Post a notification that the user has successfully signed up.
                NotificationCenter.default.post(name: Notification.Name("login"), object: nil)

            case .failure(let error):
                // Failed sign up
                // self?.showAlert(description: error.localizedDescription)
                self?.showAlert(description: error.localizedDescription)
            }
        }
    }

    private func showMissingFieldsAlert() {
        let alertController = UIAlertController(title: "Opps...", message: "We need all fields filled out in order to sign you up.", preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default)
        alertController.addAction(action)
        present(alertController, animated: true)
    }
    
    private func showAlert(description: String? = nil) {
        let alertController = UIAlertController(title: "Oops...", message: "\(description ?? "Please try again...")", preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default)
        alertController.addAction(action)
        present(alertController, animated: true)
    }
}
