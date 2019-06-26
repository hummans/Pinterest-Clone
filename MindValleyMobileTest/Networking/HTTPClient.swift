//
//  HTTPClient.swift
//  MindValleyMobileTest
//
//  Created by Engineer 144 on 24/06/2019.
//  Copyright © 2019 Engineer 144. All rights reserved.
//

import Foundation
import SwiftyJSON


public enum HTTPMethod: String {
  
    case get     = "GET"
    case post    = "POST"
 
}
extension Dictionary {
    mutating func update(other:Dictionary) {
        for (key,value) in other {
            self.updateValue(value, forKey:key)
        }
    }
}




class HTTPClient: NSObject {
    
    private let dataLoader = MOperationManager()
    
    var parameters:[String:String]?
    
    var url:URL?
    
    var method = HTTPMethod.get
    
    var headers: [String:String] = {
        var defaultHeaders = [String:String]()
        defaultHeaders["Content-Type"] = "application/json"
       return defaultHeaders
    }()
    
    
    
    
    //Use method chanining
    @discardableResult
    func setMethod(_ method:HTTPMethod) -> HTTPClient {
        self.method = method
        return self
    }
    
    @discardableResult
    func setParameter(params: [String:String]) -> HTTPClient{
        
        parameters = params
        
        
        return self
    }
    
    @discardableResult
    func setURL(url: String?) -> HTTPClient{
        
        if let urlString = url {
            self.url = URL(string: urlString)
        }
        
        return self
    }
    
    @discardableResult
    func setHeader(header: [String:String]) -> HTTPClient{
        headers.update(other: headers)
        return self
    }
    
    
    //Prepare URL for Get Request
   private func queryString(_ value: String, params: [String: String]) -> String? {
        var components = URLComponents(string: value)
        components?.queryItems = params.map { element in URLQueryItem(name: element.key, value: element.value) }
        return components?.url?.absoluteString
    }
    
    
    //Response
    func response(complete: @escaping (MOperationResponse) -> Void)   {
        
        makeAPICall(url: self.url!,
                    parameters: JSON(self.parameters ?? [:]),
                    withHTTPmethod: self.method,
                    headers: self.headers )
        { (data) in
            complete(data)
        }
        
    }
    
    private func makeAPICall(url: URL,
                     parameters: JSON,
                     withHTTPmethod: HTTPMethod,
                     headers: [String:String],
                     taskCompletion: @escaping (MOperationResponse) -> Void){
        
        
        
        
        
        self.headers.update(other: headers)
        
        
        
        
        print("Headers \(self.headers)")
        print("Parameters \(parameters)")
        print("URLSTRING \(url.absoluteString)")
        print("method \(withHTTPmethod)")
        
        
        var urlRequest = URLRequest(url: url)
        urlRequest.allHTTPHeaderFields = self.headers
        urlRequest.httpMethod = withHTTPmethod.rawValue
        
        if withHTTPmethod == .get{
            
            //OVERRIDE URLRESQUEST STRING IF ITS .get
            urlRequest.url = URL(string: queryString(url.absoluteString, params: parameters.dictionaryObject as! [String : String]) ?? "")
            
        }else{
            
            if let jsonData =  try? parameters.rawData(options: .prettyPrinted) {
                urlRequest.httpBody = jsonData
                
                
            }
        }
        
    
        
        
        // DATA Loader is used to to make API CALLS
        
        dataLoader.loadData(request: urlRequest) { (data) in
            
            print(urlRequest.debugDescription)
            print(JSON(data.data ?? Data()).description)
            
            taskCompletion(data)
            
            
        }
        
        
    }
    
}
