//
//  ViewController.swift
//  KrasnoyarskNews
//
//  Created by Anton on 20.11.2018.
//  Copyright © 2018 Home. All rights reserved.
//

import UIKit
import HLBarIndicatorView
import PullToBounce
import MagicalRecord
import SideMenuSwift

let cityName = "Нижнего Новгорода"

class ViewController: UIViewController {

    let cellIdentifier = "cell"
    var news: [String:[News]]?
    var headers: [String] = []
    
    var tableView: UITableView!
    @IBOutlet weak var activityView: HLBarIndicatorView!
    
    let cellInfoIdentifier = "NewsATableViewCell"
    
    @IBAction func menuButtonDidClicked(_ sender: Any) {
        sideMenuController?.revealMenu()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        print("[SideMenu] View Will Transition")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationController()
        
        let bodyView = UIView()
        bodyView.frame = CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height)
        self.view.addSubview(bodyView)
        
        let window = UIApplication.shared.keyWindow
        let bottomPadding = window?.safeAreaInsets.bottom
        tableView = UITableView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height-60-(bottomPadding!*2)), style: UITableViewStyle.plain)
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINib(nibName: cellInfoIdentifier, bundle: nil), forCellReuseIdentifier: cellInfoIdentifier)
        
        //🌟 Usage
        let tableViewWrapper = PullToBounceWrapper(scrollView: tableView)
        bodyView.addSubview(tableViewWrapper)
        tableViewWrapper.didPullToRefresh = {
            let delayInSeconds = 0.3
            NewsParser.downloadNews(completion: { (success) in
                let data = News.mr_findAll(in: NSManagedObjectContext.mr_rootSaving()) as! [News]
                self.news = Dictionary(grouping: data.sorted(by: { (fNews, sNews) -> Bool in
                    return fNews.time! > sNews.time!
                }), by: { $0.date! })
                
                if let resultData = self.news {
                    self.headers = Array(resultData.keys).sorted(by: { (fDate, sDate) -> Bool in
                        return fDate > sDate
                    })
                }
            })
            
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + delayInSeconds) {
                tableViewWrapper.stopLoadingAnimation()
                self.tableView.reloadData()
            }
        }
        view.bringSubview(toFront: activityView)
        
        fetchNewsData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tableView.reloadData()
    }
    
    fileprivate func setupNavigationController() {
        navigationController?.navigationBar.isTranslucent = false;
        navigationController?.navigationBar.barTintColor = UIColor.color_redMain()
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        title = "Новости " + cityName
    }
    
    fileprivate func fetchNewsData() {
        self.activityView.isHidden = false
        activityView.startAnimating()
        activityView.barColor = UIColor.color_redMain()
        self.tableView.isHidden = true
        NewsParser.downloadNews(completion: { (success) in
            self.activityView.isHidden = true
            self.activityView.pauseAnimating()
            self.tableView.isHidden = false
            
            let data = News.mr_findAll(in: NSManagedObjectContext.mr_rootSaving()) as! [News]
            self.news = Dictionary(grouping: data.sorted(by: { (fNews, sNews) -> Bool in
                print(fNews.time ?? "Def")
                return fNews.time! > sNews.time!
            }), by: { $0.date! })
            
            if let resultData = self.news {
                self.headers = Array(resultData.keys).sorted(by: { (fDate, sDate) -> Bool in
                    return fDate > sDate
                })
            }
            self.tableView.reloadData()
        })
    }
    
}
    
extension ViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
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
        performSegue(withIdentifier: "pushNews", sender: indexPath)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "pushNews" {
            let indexPath = sender!
            if let destinationVC = segue.destination as? SingleNewsViewController {
                let key = headers[(indexPath as AnyObject).section]
                let new = news![key]![(indexPath as AnyObject).row]
                destinationVC.news = new
            }
        }
    }
}

extension UIView {
    
    var safeTopAnchor: NSLayoutYAxisAnchor {
        if #available(iOS 11.0, *) {
            return self.safeAreaLayoutGuide.topAnchor
        } else {
            return self.topAnchor
        }
    }
    
    var safeLeftAnchor: NSLayoutXAxisAnchor {
        if #available(iOS 11.0, *){
            return self.safeAreaLayoutGuide.leftAnchor
        }else {
            return self.leftAnchor
        }
    }
    
    var safeRightAnchor: NSLayoutXAxisAnchor {
        if #available(iOS 11.0, *){
            return self.safeAreaLayoutGuide.rightAnchor
        }else {
            return self.rightAnchor
        }
    }
    
    var safeBottomAnchor: NSLayoutYAxisAnchor {
        if #available(iOS 11.0, *) {
            return self.safeAreaLayoutGuide.bottomAnchor
        } else {
            return self.bottomAnchor
        }
    }
}
