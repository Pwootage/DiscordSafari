//
//  ViewController.swift
//  DiscordSafari
//
//  Created by Christopher Freestone on 11/21/20.
//

import Cocoa
import WebKit

class ViewController: NSViewController, WKUIDelegate, WKNavigationDelegate {
    @IBOutlet weak var webview: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.webview.uiDelegate = self
        self.webview.navigationDelegate = self
        let myURL = URL(string: "https://discord.com/app")
        let myRequest = URLRequest(url: myURL!)
        self.webview.load(myRequest)
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if navigationAction.navigationType == .linkActivated {
            if let url = navigationAction.request.url {
                if (url.scheme == "http" || url.scheme == "https") {
                    NSWorkspace.shared.open(url)
                }
            }
            decisionHandler(.cancel)
        } else {
            if let host = navigationAction.request.url?.host {
                if (host == "discord.com") {
                    decisionHandler(.allow)
                } else {
                    decisionHandler(.cancel)
                }
            } else {
                decisionHandler(.cancel)
            }
        }
    }
    
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        
        if let url = navigationAction.request.url {
            if (url.scheme == "http" || url.scheme == "https") {
                NSWorkspace.shared.open(url)
            }
        }
        
        return nil
    }
    
    @IBAction func reload(_ sender: Any) {
        self.webview.reload()
    }
}

