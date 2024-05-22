//
//  TaskViewController.swift
//  GroupProject
//
//  Created by Admin on 18.11.2023.
//

import UIKit

class TaskViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
   
        let tableView: UITableView = {
            let tableView = UITableView()
            tableView.translatesAutoresizingMaskIntoConstraints = false
            return tableView
        }()
    var items: [String] = []
    var descp: String?
        override func viewDidLoad() {
            super.viewDidLoad()

            self.items = UserDefaults.standard.stringArray(forKey: "items") ?? []
            view.backgroundColor = .white
            view.addSubview(tableView)
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(didTapadd))
            // Set up constraints
            NSLayoutConstraint.activate([
                tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
                tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                tableView.bottomAnchor.constraint(equalTo: view.topAnchor),
            ])

            tableView.dataSource = self
            tableView.delegate = self
            tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
  
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
            if editingStyle == .delete {
                items.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
                UserDefaults.standard.setValue(items, forKey: "items")
                
            }
        }
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return items.count
        }

        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            cell.textLabel?.text = items[indexPath.row]
            return cell
        }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let list=items[indexPath.row]
        let desc=DetailViewController()
        desc.task = list
        desc.desc = descp
        self.navigationController?.pushViewController(desc, animated: true)
    }
   

        // MARK: - Button Actions
       @objc func didTapadd(){
           let alert = UIAlertController(title: "New task", message: "Add a new task", preferredStyle: .alert)
           alert.addTextField{field in field.placeholder = "Each task"}
           alert.addAction(UIAlertAction(title: "Cancel", style:.cancel,handler: nil))
           alert.addAction(UIAlertAction(title: "Done", style: .default, handler: { [weak self](_) in
               if let field = alert.textFields?.first, let text = field.text, !text.isEmpty {
                   self?.items.append(text)
                   self?.tableView.reloadData()
                   UserDefaults.standard.setValue(self?.items, forKey: "Tasks")
                   }
                                         }))
           present(alert, animated: true)
           
    }
}
