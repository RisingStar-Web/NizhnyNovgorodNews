//
//  Parser.swift
//  KrasnoyarskNews
//
//  Created by Anton on 20.11.2018.
//  Copyright © 2018 Home. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyXMLParser
import MagicalRecord

//struct News {
//    let date: String
//    let time: String
//    let title: String
//    let shortDescription: String
//    let fullDescription: String
//    let croppedPicture: String
//    let picture: String
//}

class NewsParser: NSObject, XMLParserDelegate {
        
    class func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    
    class func downloadNews(completion: @escaping ((_ success: Bool) -> Void)) {
        var newsArray: [News] = []
        let url = URL(string: "https://raw.githubusercontent.com/newsappsrus/NizhnyNovgorod/master/news.xml")!
        let task = URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, error == nil else {
                DispatchQueue.main.async {
                    completion(false)
                }
                return
            }
            guard let xmlString = String(data: data, encoding: String.Encoding.utf8) as String! else {
                DispatchQueue.main.async {
                    completion(false)
                }
                return
            }
            
            let xml = try! XML.parse(xmlString)
            MagicalRecord.save({ (context) in
                for news in xml["xml", "news"] {
                    var newsEntity = News.mr_findFirst(byAttribute: "title", withValue: news.title.text!, in: context)
                    if newsEntity == nil {
                        newsEntity = News.mr_createEntity(in: context)
                        newsEntity?.title = news.title.text
                        newsEntity?.date = news.date.text
                        newsEntity?.time = news.time.text
                        newsEntity?.shortDescr = news.shortDescription.text
                        newsEntity?.fullDescr = news.fullDescription.text
                        newsEntity?.croppedPicture = news.croppedPicture.text
//                        newsEntity?.picture = news.picture.text
                        newsEntity?.dataSource = news.source.text
                        newsEntity?.viewed = false
                        newsEntity?.favotite = false
                    }
                }
            }, completion: { (bool , error) in
                completion (true)
            })
        }
        task.resume()
    }
    
    // MARK: - load Images methods
    
    class func downloadCityImage(path: String?, name: String, completion: ((_ success: Bool) -> Void)?) {
        guard let path = path, let url = URL(string: path) else {
            print("Path is invalid")
            return
        }
        guard NetworkHelper.isInternetAvailable() else {
            print("Internet is not available")
            return
        }
        do {
            let data = try Data(contentsOf: url)
            if let image = UIImage(data: data) {
                let filename = self.getDocumentsDirectory().appendingPathComponent(name)
                try UIImageJPEGRepresentation(image, 1.0)?.write(to: filename)
            }
            if let completion = completion {
                completion(true)
            }
        } catch {
            print("Error when loading image:", error)
            return
        }
    }
    
}
