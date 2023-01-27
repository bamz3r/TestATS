//
//  ViewController.swift
//  Test ATS
//
//  Created by Bambang on 25/01/23.
//

import UIKit
import Alamofire
import AlamofireImage

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var sbKeyword: UISearchBar!
    
    var isLoading: Bool = false
    
    var keyword: String = ""
    
    var items: [UserGithubModel] = []
    var currenPage = 1
    var totalPage = 1
    var totalCount = 0
    
    var isFirst: Bool = true
    
    private let myRefreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("viewDidLoad...")
        
        sbKeyword.delegate = self
        initRefreshControl()
        showErrorMessage(title: "Info", message: "Please type a name")
    }
    
    func showErrorMessage(title: String, message: String) {
        items.removeAll()
        let err = UserGithubModel(error_title: title, error_message: message)
    
        items.append(err)
        self.tableView.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let k = searchBar.text {
            self.keyword = k
            refreshMainData()
        }
    }
    
    func initRefreshControl() {
        self.myRefreshControl.tintColor = UIColor.gray
        self.myRefreshControl.addTarget(self, action: #selector(self.refreshMainData), for: .valueChanged)
        
        if #available(iOS 10.0, *) {
            tableView.refreshControl = self.myRefreshControl
        } else {
            tableView.addSubview(self.myRefreshControl)
        }
    }
    
    @objc func refreshMainData() {
        self.currenPage = 1
        self.getDatas()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        print("heightForRowAt tableView \(indexPath.row)")
        let item = self.items[indexPath.row]
        if(item.isError()) {
            return 500
        } else {
            return 60
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("cellForRowAt tableView \(indexPath.row)")
        
        let item = self.items[indexPath.row]
        if(item.isError()) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "errorCell", for: indexPath) as! errorCell
            cell.displayContent(item: item)
            cell.tag = indexPath.row
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "tvcUserCell", for: indexPath) as! tvcUserCell
            cell.displayContent(item: item)
            cell.tag = indexPath.row
            return cell
        }
    }
    
     func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.items.count
    }
    
     func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = self.items[indexPath.row]
        if (!item.isError() && !item.htmlUrl.isEmpty) {
            if UIApplication.shared.canOpenURL(URL(string: item.htmlUrl)!) {
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(URL(string: item.htmlUrl)!, options: [:], completionHandler: nil)
                } else {
                    UIApplication.shared.openURL(URL(string: item.htmlUrl)!)
                }
            } else {
                let alertController = UIAlertController(title: "Sorry", message: "Browser app is not installed", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                alertController.addAction(okAction)
                self.present(alertController, animated: true, completion: nil)
            }
        }
    }
    
     func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == self.items.count-1 {
            if(self.totalPage > self.currenPage && !self.isLoading) {
              print("Begin next page")
              self.currenPage += 1
              self.getDatas()
          }
        }
    }
    
    func getDatas() {
        if !isLoading {
            if currenPage > 1 {
//                self.aiLoading.show()
            } else {
                self.view.showBlurLoader()
            }
            self.isLoading = true
            if(currenPage == 1/* && !isFirst*/) {
                items.removeAll()
                self.tableView.reloadData()
            }
            isFirst = false;
            
            ApiCall.getUsers (query: keyword, page: currenPage, completion: {(newItems, total) in
                self.totalCount = total
                self.totalPage = Int(ceil(Double(total/20)))
                self.isLoading = false
                self.view.removeBluerLoader()
                self.myRefreshControl.endRefreshing()
                
                if(newItems!.count > 0) {
                    self.items.append(contentsOf: newItems!)
                } else {
                    if(self.currenPage == 1) {
                        self.showErrorMessage(title: "Error", message: "Opps, no data available")
                    }
                }
                
                self.tableView.reloadData()
            }, onerror: {error in
                self.isLoading = false
                self.view.removeBluerLoader()
                self.myRefreshControl.endRefreshing()
                self.tableView.reloadData()
                self.showErrorMessage(title: "Error", message: error!)
            })
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

class tvcUserCell: UITableViewCell {
    @IBOutlet weak var labelName: UILabel!
    @IBOutlet weak var ivAvatar: UIImageView!
    
    var cellItem: UserGithubModel = UserGithubModel()
    
    func displayContent(item: UserGithubModel) {
        cellItem = item
        labelName.text = cellItem.name
        if(!item.avatarUrl.isEmpty) {
            Alamofire.request(item.avatarUrl).responseImage { response in
                if let imageRes: UIImage = response.result.value {
                    let size = self.ivAvatar.frame.size
                    let aspectScaledToFillImage = imageRes.af_imageAspectScaled(toFit: size)
                    self.ivAvatar.image = aspectScaledToFillImage
                }
            }
        }
    }
}


class errorCell: UITableViewCell {
    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var labelMessage: UILabel!
    
    func displayContent(item: UserGithubModel) {
        labelTitle.text = item.error_title
        labelMessage.text = item.error_message
    }
}






