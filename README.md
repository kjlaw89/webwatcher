<div align="center">
  <span align="center"> <img width="80" height="70" class="center" src="https://github.com/kjlaw89/web-watcher/blob/master/data/images/com.github.kjlaw89.web-watcher.png" alt="Icon"></span>
  <h1 align="center">Web Watcher</h1>
  <h3 align="center">Know when your websites are misbehaving!</h3>
</div>

<br/>

<p align="center">
   <a href="https://github.com/kjlaw89/web-watcher/blob/master/LICENSE">
    <img src="https://img.shields.io/badge/License-GPL--3.0-blue.svg">
   </a>
  <a href="https://github.com/kjlaw89/web-watcher/releases">
    <img src="https://img.shields.io/badge/Release-v%200.0.1-orange.svg">
   </a>
  <a href="https://github.com/kjlaw89/web-watcher/releases/download/0.0.1/com.github.kjlaw89.web-watcher_0.0.1_amd64.deb">
     <img src="https://img.shields.io/badge/Download-%20Package .deb-yellow.svg">
    </a>
</p>

<p align="center">
    <img  src="https://github.com/kjlaw89/web-watcher/blob/master/data/images/screenshot1.png" alt="Screenshot 1"> <br>
    <img  src="https://github.com/kjlaw89/web-watcher/blob/master/data/images/screenshot2.png" alt="Screenshot 1"> <br>
    <a href="https://github.com/kjlaw89/web-watcher/issues/new"> Report a problem! </a>
</p>

## Features

* Easily add as many sites as you wish to monitor
* All sites are checked every minute
* Extra meta-data (title and icon) are automatically grabbed
* Get a notification if a site goes down or comes back up
* View all historical data for the past 2 hours (with eventual capabilities to export all data)
* Does not require an external service (uses local network to check sites)
* Runs in background automatically once started via System tray indicator

<hr />

## Installation

### Dependencies
These dependencies must be present before building
 - `meson (>=0.40)`
 - `valac (>=0.16)`
 - `debhelper (>= 9)`
 - `libgranite-dev`
 - `libgtk-3-dev`
 - `sqlite3-dev`
 - `unity-dev`
 - `appindicator3-0.1-dev`

 ### Building

```
git clone https://github.com/kjlaw89/web-watcher.git && cd web-watcher
meson build && cd build
meson configure -Dprefix=/usr
ninja
sudo ninja install
com.github.kjlaw89.web-watcher
```

### Deconstruct

```
sudo ninja uninstall
```

### Contributing

To help, access the links below:

- [Guide on Code Style](https://github.com/kjlaw89/web-watcher/wiki/Guide-on-code-style)

- [Proposing Design Changes](https://github.com/kjlaw89/web-watcher/wiki/Proposing-Design-Changes)

- [Reporting Bugs](https://github.com/kjlaw89/web-watcher/wiki/Reporting-Bugs)

- [Translate](https://github.com/kjlaw89/web-watcher/wiki/Translate)


### License

This project is licensed under the GPL3 License - see the [LICENSE](LICENSE.md) file for details.
