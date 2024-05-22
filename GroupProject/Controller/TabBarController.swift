//
//  TabBarController.swift
//  GroupProject
//
//  Created by Admin on 18.11.2023.
//

import UIKit

class TabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupTabs()
        self.tabBar.barTintColor = .white
        self.tabBar.tintColor = .blue
        self.tabBar.unselectedItemTintColor = .black
    }
    
    private func setupTabs(){
            let home = self.createNav(with: "Task", and: UIImage(systemName: "list.bullet.circle"), vc: TaskViewController())
            let history = self.createNav(with: "Timer", and: UIImage(systemName: "timer"), vc: TimerViewController())
            let workout = self.createNav(with: "Settings", and: UIImage(systemName: "person.circle"), vc: SettingsViewController())
            self.setViewControllers([home,history,workout], animated: true)
        }
  
   
    
    private func createNav(with title: String, and image:UIImage?, vc:UIViewController)-> UINavigationController{
        let nav = UINavigationController(rootViewController: vc)
        nav.tabBarItem.title = title
        nav.tabBarItem.image = image
        nav.viewControllers.first?.navigationItem.title = title
        return nav
    }
    


}
