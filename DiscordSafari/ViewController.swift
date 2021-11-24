//
//  ViewController.swift
//  DiscordSafari
//
//  Created by Christopher Freestone on 11/21/20.
//

import Cocoa
import WebKit
import AVFoundation

class ViewController: NSViewController, WKUIDelegate, WKNavigationDelegate {
    @IBOutlet weak var webview: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.webview.uiDelegate = self
        self.webview.navigationDelegate = self
        self.webview.customUserAgent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/15.1 Safari/605.1.15"
        
        AVCaptureDevice.requestAccess(for: .audio, completionHandler: {_ in})
        
        let myURL = URL(string: "https://discord.com/app")
        let myRequest = URLRequest(url: myURL!)
        self.webview.load(myRequest)
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        
        if navigationAction.navigationType == .linkActivated {
            // You clicked a link, check it to open it in safari, don't navigate
            if let url = navigationAction.request.url {
                openInOS(url)
            }
            decisionHandler(.cancel)
        } else {
            // Allow only navigation to discord.com
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
            openInOS(url)
        }
        return nil
    }
    
    @IBAction func reload(_ sender: Any) {
        self.webview.reload()
    }
    
    func openInOS(_ url: URL) {
        // If it's an HTTP or HTTPS url, open it in default browser
        // Maybe should pop up a warning dialog and support all schemes at some point.
        if (url.scheme == "http" || url.scheme == "https") {
            NSWorkspace.shared.open(url)
        }
    }
}

