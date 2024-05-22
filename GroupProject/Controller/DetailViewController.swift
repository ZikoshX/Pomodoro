//
//  DetailViewController.swift
//  GroupProject
//
//  Created by Admin on 20.11.2023.
//

import UIKit
protocol DetailViewControllerDelegate: AnyObject {
      func didUpdateTask(_ newTask: String)
  }
class DetailViewController: UIViewController {
    
  
    weak var delegate: DetailViewControllerDelegate?
    
    
    var task: String?
    
    var desc: String?
    
    lazy var startButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Start", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .blue
        button.layer.cornerRadius = 15
        button.addTarget(self, action: #selector(startButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    var titleTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Enter title"
        textField.borderStyle = .roundedRect
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    
    let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "You-can-do-it.png")
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    let saveButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Save", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .green
        button.layer.cornerRadius = 15
        button.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemGray6
        view.addSubview(startButton)
        view.addSubview(titleTextField)
        view.addSubview(imageView)
        view.addSubview(saveButton)
        
        if task != nil {
            let label = UILabel()
            label.text = task
            label.frame = CGRect(x: 170, y: 100, width: 400, height: 100)
            label.textColor = .black
            label.font = .boldSystemFont(ofSize: 20)
            view.addSubview(label)
        }
        
        NSLayoutConstraint.activate([
            titleTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 70),
            titleTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            titleTextField.heightAnchor.constraint(equalToConstant: 40),
            
            saveButton.topAnchor.constraint(equalTo: titleTextField.bottomAnchor, constant: 20),
            saveButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            saveButton.widthAnchor.constraint(equalToConstant: 100),
            saveButton.heightAnchor.constraint(equalToConstant: 40),
            
            startButton.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 70),
            startButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            startButton.widthAnchor.constraint(equalToConstant: 100),
            startButton.heightAnchor.constraint(equalToConstant: 40),
            
            imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 200),
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            imageView.heightAnchor.constraint(equalToConstant: 200),
        ])
        
        animateImageView()
    }
    
    func animateImageView() {
        UIView.animate(withDuration: 2.0, animations: {
            self.imageView.center = CGPoint(x: 200, y: 400)
            self.imageView.backgroundColor = .white
        }) { _ in
            print("You can do it!")
        }
    }
    @objc func startButtonTapped() {
        self.tabBarController?.selectedIndex = 1
        
    }
    func updateTask(newTask: String) {
         delegate?.didUpdateTask(newTask)
         navigationController?.popViewController(animated: true)
     }
    
    @objc func saveButtonTapped() {
        if let newTitle = titleTextField.text, !newTitle.isEmpty {
            task = newTitle
            delegate?.didUpdateTask(newTitle)
            if let existingLabel = view.subviews.first(where: { $0 is UILabel }) as? UILabel {
                existingLabel.text = newTitle
            } else {
                let label = UILabel()
                label.text = task
                label.frame = CGRect(x: 170, y: 100, width: 400, height: 100)
                label.textColor = .black
                label.font = .boldSystemFont(ofSize: 20)
                view.addSubview(label)
            }
        }
    }
        }
    
    
    

