# DiscordSafari
This is a super simple WebKit wrapper around Discord to run it in Safari instead of Electron. The hope is that this will use less power than the electron 
version (at the cost of fewer features). It supports drag-n-drop file and open links.

![Energy usage: 6.8 to 3.6](energy_usage.png)

Your mileage may vary.

The entire code is in [ViewController.swift](DiscordSafari/ViewController.swift) (plus a few lines in  [AppDelegate.swift](DiscordSafari/AppDelegate.swift) to close when the window is closed)  and is under 100 lines long total.

The icon comes from [Elias' macosicons](https://github.com/elrumo/macOS_Big_Sur_icons_replacements)

I believe this is allowed under Discord ToS - since I am not modifying the application in anyway, and am simply behaving as a web browser.

Use at your own risk, but it's an extremely simple app, so you can easily audit the code yourself. I recommend building the app for yourself; but a release is provided in releases.

LICENSE:

All content in this repo is public domain, except the icon, which is subject to the license of [Elias' macosicons](https://github.com/elrumo/macOS_Big_Sur_icons_replacements), which is GPLv3.
