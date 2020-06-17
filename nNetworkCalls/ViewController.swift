//
//  ViewController.swift
//  nNetworkCalls
//
//  Created by Javier Cruz Santiago on 25/05/20.
//  Copyright © 2020 Banco Azteca. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var tblContent: UITableView!
    
    var rowsString: [String] = []
    var networkCallsData: [Data?] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.tblContent.register(UITableViewCell.self, forCellReuseIdentifier: "id")
        self.tblContent.dataSource = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.makeNetworkCalls(n: 200)
    }
    
    private func showLoader() {
        let alert = UIAlertController(title: nil, message: "Please wait...", preferredStyle: .alert)

        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.style = UIActivityIndicatorView.Style.medium
        loadingIndicator.startAnimating();

        alert.view.addSubview(loadingIndicator)
        present(alert, animated: true, completion: nil)
    }
    
    private func hideLoader() {
        dismiss(animated: true, completion: nil)
    }
    
    private func makeNetworkCalls(n: Int) {
        self.showLoader()
        
        DispatchQueue.global(qos: .background).async {
            for _ in 1 ... n {
                DispatchQueue.main.async {
                    switch self.makeNetworkCall() {
                    case .success(let data):
                        self.networkCallsData.append(data)
                    case .failure(_):
                        self.networkCallsData.append(nil)
                    }
                }
            }
            DispatchQueue.main.async {
                self.hideLoader()
                self.drawRows()
            }
        }
    }
    
    private func makeNetworkCall() -> Result<Data?, Error> {
        guard let url: URL = URL(string: "https://gorest.co.in/public-api/users?_format=json&access-token=otde8GumlRfe4UjyvLwkQRnUckVp7d7qmUf6") else {
            return .success(nil)
        }
        
        let urlRequest: URLRequest = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 10)
        
        let semaphore = DispatchSemaphore(value: 0)
        
        var result: Result<Data?, Error>!
        
        URLSession.shared.dataTask(with: urlRequest) { (data, urlResponse, error) in
            if let responseError = error {
                result = .failure(responseError)
            } else {
                result = .success(data)
            }
            semaphore.signal()
        }.resume()
        
        _ = semaphore.wait(wallTimeout: .distantFuture)
        
        return result
    }
    
    private func drawRows() {
        self.rowsString = self.networkCallsData.map({ (data) -> String in
            guard let _ = data else { return "nil" }
            return "Elemento"
        })
        
        self.tblContent.reloadData()
    }
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rowsString.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "id", for: indexPath)
        cell.textLabel?.text = "\(rowsString[indexPath.row]) \(indexPath.row)"
        return cell
    }
}
