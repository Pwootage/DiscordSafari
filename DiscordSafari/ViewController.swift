//
//  ViewController.swift
//  DiscordSafari
//
//  Created by Christopher Freestone on 11/21/20.
//

import Cocoa
import WebKit
import UserNotifications
import CryptoKit
import AVFoundation
class ViewController: NSViewController, WKUIDelegate, WKNavigationDelegate {
    @IBOutlet weak var webview: WKWebView!
    weak var appDelegate: AppDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup delegates
        self.appDelegate = (NSApplication.shared.delegate as! AppDelegate)
        self.webview.uiDelegate = self
        self.webview.navigationDelegate = self
        let allowedDefault = "'granted'"
        let notificationInterface = """
        var __$notif_enabled = \(allowedDefault);
        class NotificationOverride {
            static get permission() {
                return __$notif_enabled;
            }

            static requestPermission(callback) {
                // TODO: actually request permissions instead of at launch
                callback(__$notif_enabled);
            }

            constructor(title, opts) {
                window.webkit.messageHandlers.sendNotification.postMessage({title, ...opts});
            }
        }
        window.Notification = NotificationOverride;
        """
        let userScript = WKUserScript(source: notificationInterface, injectionTime: .atDocumentStart, forMainFrameOnly: false)
        self.webview.configuration.userContentController.addUserScript(userScript)
        self.webview.configuration.userContentController.add(SendNotificationHandler(), name: "sendNotification")
        
        // Load discord
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


class SendNotificationHandler: NSObject, WKScriptMessageHandler {
    weak var appDelegate: AppDelegate! = (NSApplication.shared.delegate as! AppDelegate)
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        let content = UNMutableNotificationContent()
        let body = message.body as! [String: Any]
        content.title = body["title"] as! String
        content.body = body["body"] as! String
        if let icon = body["icon"] as? String,
           let iconUrl = URL(string: icon) {
            do {
                let cachesDir = try FileManager.default.url(
                    for: .cachesDirectory,
                    in: .userDomainMask,
                    appropriateFor: nil,
                    create: true
                )
                let iconDir = cachesDir.appendingPathComponent("icons")
                try FileManager.default.createDirectory(at: iconDir, withIntermediateDirectories: true, attributes: nil)
                let iconHash = MD5(string: icon)
                let iconExt = (iconUrl.lastPathComponent.split(separator: ".").last ?? "png")
                    .addingPercentEncoding(withAllowedCharacters: CharacterSet.urlPathAllowed) ?? "png"
                let iconFile = iconDir.appendingPathComponent(iconHash + "." + iconExt)
                print(iconFile)
                download(url: iconUrl, to: iconFile) { success in
                    if !success {
                        return
                    }
                    do {
                        let attachment = try UNNotificationAttachment(
                            identifier: iconHash,
                            url: iconFile,
                            options: [
                             UNNotificationAttachmentOptionsThumbnailHiddenKey: false,
                             UNNotificationAttachmentOptionsThumbnailClippingRectKey: CGRect(x: 0, y: 0, width: 1, height: 1).dictionaryRepresentation,
                             UNNotificationAttachmentOptionsThumbnailTimeKey: 0
                            ])
                        content.attachments.append(attachment)
                        
                        let uuidString = UUID().uuidString
                        let request = UNNotificationRequest(identifier: uuidString, content: content, trigger: nil)

                        let notificationCenter = UNUserNotificationCenter.current()
                        notificationCenter.add(request) { (error) in
                            if error != nil {
                                NSLog(error.debugDescription)
                            }
                        }
                    } catch {
                        print(error)
                    }
                }
            } catch {
                print(error)
            }
        }
    }
}

func MD5(string: String) -> String {
    let digest = Insecure.MD5.hash(data: string.data(using: .utf8) ?? Data())
    return digest.map { String(format: "%02hhx", $0) }.joined()
}


func download(url: URL, to destination: URL, completion: @escaping (_ success: Bool) -> ()) {
    if FileManager.default.fileExists(atPath: destination.path) {
        completion(true)
        return
    }
    
    let session = URLSession(configuration: URLSessionConfiguration.default)
    var request = URLRequest(url: url)
    request.httpMethod = "GET"
    let task = session.downloadTask(with: request) { (tempLocalUrl, response, error) in
        if let tempLocalUrl = tempLocalUrl, error == nil {
            do {
                let success = (response as? HTTPURLResponse)?.statusCode == 200
                if (success) {
                    try FileManager.default.copyItem(at: tempLocalUrl, to: destination)
                }
                completion(success)
            } catch (let writeError) {
                completion(false)
                print("error writing file \(url) -> \(destination) : \(writeError)")
            }

        } else {
            completion(false)
            print("error downloading \(url) \(error?.localizedDescription ?? "null")");
        }
    }
    task.resume()
}
