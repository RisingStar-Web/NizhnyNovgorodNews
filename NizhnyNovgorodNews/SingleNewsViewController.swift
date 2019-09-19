//
//  SingleNewsViewController.swift
//  KrasnoyarskNews
//
//  Created by Anton on 20.11.2018.
//  Copyright © 2018 Home. All rights reserved.
//

import UIKit
import MagicalRecord

class SingleNewsViewController: UIViewController {
    
    let cellIdentifier = "NewImageTableViewCell"
    let cellInfoIdentifier = "NewInformationTableViewCell"
    var news: News!
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib(nibName: cellIdentifier, bundle: nil), forCellReuseIdentifier: cellIdentifier)
        tableView.register(UINib(nibName: cellInfoIdentifier, bundle: nil), forCellReuseIdentifier: cellInfoIdentifier)
        news.viewed = true
        NSManagedObjectContext.mr_default().mr_saveToPersistentStoreAndWait()
//        NSManagedObjectContext.mr_rootSaving().mr_saveToPersistentStoreAndWait()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let statusBar = UIApplication.shared.value(forKey: "statusBar") as? UIView {
            statusBar.backgroundColor = UIColor.color_redMain()
        }
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }

}

extension SingleNewsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! NewImageTableViewCell
                        
            cell.newsBackButton.addTarget(self, action: #selector(backButtonPressed), for: .touchUpInside)
            
//            cell.dateLabel.text = news.date
//            cell.timeLabel.text = news.time
            
            if let backgroundImage = UIImage(contentsOfFile: NewsParser.getDocumentsDirectory().appendingPathComponent("\(news.title!).jpg").path) {
                cell.newsImage.image = backgroundImage
            } else {
                DispatchQueue.global(qos: .userInitiated).async {
                    print("Start download for cell")
                    NewsParser.downloadCityImage(path: self.news.croppedPicture, name: "\(self.news.title!).jpg", completion:{ (success: Bool) -> Void in
                        if success {
                            DispatchQueue.main.async {
                                if cell.tag == indexPath.row {
                                    cell.newsImage.image = UIImage(contentsOfFile: NewsParser.getDocumentsDirectory().appendingPathComponent("\(self.news.title!)"+"\(self.news.date!)"+".jpg").path)
                                    cell.setNeedsLayout()
                                }
                            }
                        }
                    })
                }
            }
            cell.accessoryType = .none
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: cellInfoIdentifier, for: indexPath) as! NewInformationTableViewCell
            
            cell.pressFavoriteBtn.addTarget(self, action: #selector(handleFavorState), for: .touchUpInside)
            news.favotite ? cell.pressFavoriteBtn.setImage(UIImage(named:"ic_star_full")?.withRenderingMode(.alwaysOriginal), for: .normal) : cell.pressFavoriteBtn.setImage(UIImage(named:"ic_star_fill")?.withRenderingMode(.alwaysOriginal), for: .normal)
            
            cell.dateAndTimeLAbel.text = "\(news.date!)" + ", " + "\(news.time!)"
            cell.titleLabel.text = news.title
            cell.fullLabel.text = news.fullDescr! + "\n\n" + "\(news.dataSource ?? " ")"
            cell.accessoryType = .none
            return cell
        }
    }
    
    @objc func handleFavorState(sender: UIButton) {
        news.favotite = !news.favotite
        NSManagedObjectContext.mr_default().mr_saveToPersistentStoreAndWait()
//        NSManagedObjectContext.mr_rootSaving().mr_saveToPersistentStoreAndWait()
        tableView.reloadData()
        print("handleFavorState")
    }
    
    @objc func backButtonPressed(sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
}
