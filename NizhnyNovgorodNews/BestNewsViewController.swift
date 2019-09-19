//
//  BestNewsViewController.swift
//  KrasnoyarskNews
//
//  Created by Anton on 24.12.2018.
//  Copyright © 2018 Home. All rights reserved.
//

import UIKit
import MagicalRecord

class BestNewsViewController: UIViewController {

//    let cellIdentifier = "cell"
    var news: [String:[News]]?
    var headers: [String] = []
    let cellInfoIdentifier = "NewsATableViewCell"
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationController()
    }
    
    fileprivate func setupNavigationController() {
        navigationController?.navigationBar.isTranslucent = false;
        navigationController?.navigationBar.barTintColor = UIColor.color_redMain()
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        title = "Избранные Новости"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.register(UINib(nibName: cellInfoIdentifier, bundle: nil), forCellReuseIdentifier: cellInfoIdentifier)
        fetchNewsData()
    }
    
    fileprivate func fetchNewsData() {
        let data = News.mr_find(byAttribute: "favotite", withValue: true) as! [News]
        //mr_findAll(in: NSManagedObjectContext.mr_rootSaving()) as! [News]
//        print (data)
//        print("-")
        self.news = Dictionary(grouping: data.sorted(by: { (fNews, sNews) -> Bool in
            return fNews.time! > sNews.time!
        }), by: { $0.date! })
//        print (self.news)
//        print("-")
        if let resultData = self.news {
            self.headers = Array(resultData.keys).sorted(by: { (fDate, sDate) -> Bool in
                return fDate > sDate
            })
        }
        
        if headers.count == 0 {
            tableView.isHidden = true
        } else {
            tableView.isHidden = false
        }
        
        tableView.reloadData()
    }
    
    @IBAction func menuButtonDidClicked(_ sender: Any) {
        sideMenuController?.revealMenu()
    }

}

extension BestNewsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        print("H")
        print(headers)
        return headers.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let key = headers[section]
        
        let formatter = DateFormatter()
        formatter.locale = Locale.init(identifier: "ru_RU")
        
        formatter.dateFormat = "dd.MM.yyyy"
        let toDate = formatter.date(from: key)
        
        formatter.dateFormat = "dd MMMM"
        let stringDate = formatter.string(from: toDate!)
        
        let v = UIView()
        v.backgroundColor = .color_lightGrayMain()
        let label = UILabel(frame: CGRect(x: 16, y: 0, width: 200, height: 28))
        label.text = stringDate
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.textColor = .color_grayDark()
        v.addSubview(label)
        return v
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let key = headers[section]
        let new = news![key]!
        print("newH")
        print(new)
        return new.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellInfoIdentifier, for: indexPath) as! NewsATableViewCell
        cell.tag = indexPath.row
        
        let key = headers[indexPath.section]
        let new = news![key]![indexPath.row]
        
        cell.newsTimeLabel.text = new.title
        cell.newsTitleLabel.text = "\(new.date!)" + ", " + "\(new.time!)"
        cell.newsDescriptionLabel.text = new.shortDescr
        
        cell.eyeIcon.isHidden = true
        cell.eyeIcon.image = UIImage(named: "icons8-eye")
        if new.viewed {
            cell.eyeIcon.isHidden = false
        }
        
        if let backgroundImage = UIImage(contentsOfFile: NewsParser.getDocumentsDirectory().appendingPathComponent("\(new.title!).jpg").path) {
            cell.newsImageView.image = backgroundImage
        } else {
            cell.newsImageView.image = UIImage(named: "loadIco")
            DispatchQueue.global(qos: .userInitiated).async {
                print("Start download for cell")
                NewsParser.downloadCityImage(path: new.croppedPicture, name: "\(new.title!).jpg", completion:{ (success: Bool) -> Void in
                    if success {
                        DispatchQueue.main.async {
                            if cell.tag == indexPath.row {
                                cell.newsImageView.image = UIImage(contentsOfFile: NewsParser.getDocumentsDirectory().appendingPathComponent("\(new.title!).jpg").path)
                                cell.setNeedsLayout()
                            }
                        }
                    }
                })
            }
        }
        
        cell.newsImageView.layer.cornerRadius = 6
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: "pushFavorNews", sender: indexPath)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "pushFavorNews" {
            let indexPath = sender!
            if let destinationVC = segue.destination as? SingleNewsViewController {
                let key = headers[(indexPath as AnyObject).section]
                let new = news![key]![(indexPath as AnyObject).row]
                destinationVC.news = new
            }
        }
    }
}
