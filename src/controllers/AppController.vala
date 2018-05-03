/* Copyright 2018 KJ Lawrence <kjtehprogrammer@gmail.com>
*
* This program is free software: you can redistribute it
* and/or modify it under the terms of the GNU General Public License as
* published by the Free Software Foundation, either version 3 of the
* License, or (at your option) any later version.
*
* This program is distributed in the hope that it will be
* useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General
* Public License for more details.
*
* You should have received a copy of the GNU General Public License along
* with this program. If not, see http://www.gnu.org/licenses/.
*/

using App.Configs;
using App.Database;
using App.Enums;
using App.Models;
using App.Widgets;
using App.Views;
using Gee;

namespace App.Controllers {

    /**
     * The {@code AppController} class.
     *
     * @since 0.0.1
     */
	public class AppController {

        private Gtk.Application     application;
        private AppView             appView;
        private DB                  database;
        private AppIndicator.Indicator indicator;
        private AppIndicatorView    indicatorView;
        private Unity.LauncherEntry launcherEntry;
        private int                 offlineCount = 0;
        private App.Configs.Settings  settings;
        private HashSet<SiteModel>  sites = new HashSet<SiteModel> ();
        private Gtk.ApplicationWindow window;

        public AppView View { get { return appView; } }

        /**
         * Constructs a new {@code AppController} object.
         */
		public AppController (Gtk.ApplicationWindow window, Gtk.Application application) {
            this.settings = App.Configs.Settings.get_instance ();
            this.window = window;

            var dataDir = Environment.get_home_dir () + "/.local/share/com.github.kjlaw89.web-watcher";
            var dir = File.new_for_path (dataDir);
            if (!dir.query_exists ()) {
                try { dir.make_directory (); }
                catch (Error ex) {
                    error ("Unable to create settings directory");
                }
            }

            var iconDir = File.new_for_path (dataDir + "/icons");
            if (!iconDir.query_exists ()) {
                try { iconDir.make_directory (); }
                catch (Error ex) {
                    error ("Unable to create icons cache directory");
                }
            }

            // Initialize our application view
            this.application = application;
            this.appView = new AppView (window);
            this.window.add (this.appView);

            // Setup our App Indicator
            this.indicator = new AppIndicator.Indicator (Constants.ID, "applications-internet-symbolic", AppIndicator.IndicatorCategory.APPLICATION_STATUS);
            this.indicator.set_status (AppIndicator.IndicatorStatus.ACTIVE);
            this.indicatorView = new AppIndicatorView (indicator);
            this.indicatorView.menu_event.connect (this.indicator_event);
            
            // Initialize our database and get a list of active locations
            this.database = DB.GetInstance ();
            var statement = this.database.Prepare ("SELECT id FROM `sites` ORDER BY `order` ASC");

            var count = 0;
            while (statement.step () == Sqlite.ROW) {
                var site = new SiteModel ();

                if (site.get (statement.column_value (0).to_int ())) {
                    sites.add (site);
                    this.appView.siteListView.addSite (site);
                    this.indicatorView.addSite (site);

                    // Watch online/offline events
                    site.status_changed.connect (this.site_status_changed);

                    if (site.status == "bad") {
                        this.offlineCount++;
                    }
                }

                count++;
            }

            if (count == 0) {
                this.View.show_welcome ();
                this.window.show_all ();
            }
            else {
                this.View.show_sites ();
                this.window.hide ();
                this.window.deiconify ();
            }
            
            // Handle events to the sites
            this.View.site_event.connect ((site, event) => {
                switch (event) {
                    case SiteEvent.ADDED:
                        if (count == 0) {
                            this.View.show_sites ();
                            count++;
                        }

                        sites.add (site);
                        this.View.siteListView.addSite (site);
                        break;
                }
            });

            // Setup our launcher entry events
            this.launcherEntry = Unity.LauncherEntry.get_for_desktop_id (Constants.ID + ".desktop");
            this.launcherEntry.count_visible = this.offlineCount > 0;
            this.launcherEntry.count = this.offlineCount;

            // Setup our accelerators
            this.setup_accelerators ();

            // Initializes our timer to update each site once a second.
            // Each site can determine if it needs to run or not,
            // buy by default each site will run once a minute.
            // If the site enters a warning/error state it will
            // attempt update every 10 seconds.
            Timeout.add_seconds_full (1, 1, () => {
                foreach (var site in sites) {
                    site.run ();
                }

                return true;
            });
        }
        
        private void site_status_changed (SiteModel site, SiteEvent status) {
            if (!site.notify) {
                return;
            }
            
            var title = (status == SiteEvent.ONLINE) ? _("Website is up") : _("Website is down");
            var body = (site.title != null) ? site.title + "\n" + site.url : site.url;
            
            var notification = new Notification (title);
            notification.set_body (body);
            notification.set_priority (NotificationPriority.NORMAL);

            if (site.icon != null && site.icon != "") {
                notification.set_icon (site.get_icon_image ().gicon_async);
            }
            
            application.send_notification (Constants.ID, notification);

            if (status == SiteEvent.ONLINE) {
                this.offlineCount--;
            }
            else {
                this.offlineCount++;
            }

            this.launcherEntry.count_visible = this.offlineCount > 0;
            this.launcherEntry.count = this.offlineCount;
        }

        private void indicator_event (SiteModel? site, IndicatorEvent event) {
            switch (event) {
                case IndicatorEvent.SELECTED:
                    Granite.Services.System.open_uri (site.url);
                    break;
                case IndicatorEvent.SHOW:
                    application.activate ();
                    break;
                case IndicatorEvent.QUIT:
                    application.quit ();
                    break;
            }
        }

        private void setup_accelerators () {
            var quit_action = new SimpleAction ("quit", null);
            quit_action.activate.connect (() => {
                this.settings.save_window_pos (this.window);

                if (this.window != null) {
                    this.window.destroy ();
                }
            });

            var find_action = new SimpleAction ("find", null);
            find_action.activate.connect (() => {
                this.appView.headerbar.search ();
            });

            this.application.add_action (find_action);
            this.application.add_action (quit_action);
            
            this.application.add_accelerator ("<Control>f", "app.find", null);
            this.application.add_accelerator ("<Control>q", "app.quit", null);
        }
	}
}
