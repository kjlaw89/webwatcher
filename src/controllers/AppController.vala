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

using App.Database;
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
        private AppView             app_view;
        private DB            database;

        /**
         * Constructs a new {@code AppController} object.
         */
		public AppController (Gtk.ApplicationWindow window, Gtk.Application application,  AppView app_view) {
            var dataDir = Environment.get_home_dir () + "/.local/share/com.github.kjlaw89.site-monitor";
            var dir = File.new_for_path (dataDir);
            if (!dir.query_exists ()) {
                dir.make_directory ();
            }

            this.application = application;
            this.app_view = app_view;
            this.database = DB.GetInstance ();

            var sitesList = new HashSet<SiteModel> ();
            var statement = this.database.Prepare ("SELECT id FROM `sites` WHERE active = 1 ORDER BY `order` ASC");

            while (statement.step () == Sqlite.ROW) {
                var site = new SiteModel ();

                if (site.get (statement.column_value (0).to_int ())) {
                    sitesList.add (site);
                    this.app_view.siteListView.addSite (site);
                }
            }
            
            //on_activate_button_preferences (window);
		}

        /**
         * When select the preferences option in the settings icon located in the headerbar, 
         * this method will call the "DialogPreferences".
         *
         * @see App.Widgets.DialogPreferences
         * @param  {@code Gtk.ApplicationWindow} window
         * @return {@code void}
         */
        private void on_activate_button_preferences (Gtk.ApplicationWindow window) {
            /*this.app_view.headerbar.item_selected.connect ((item) => {
				switch (item) {
					case App.Enums.MenuItem.NEW:
						this.dialog_site = new DialogSite (window);
						this.dialog_site.show_all ();
						break;
					case App.Enums.MenuItem.PREFERENCES:
						this.dialog_preferences = new DialogPreferences (window);
						this.dialog_preferences.show_all ();
						break;
				}
                
            }); */
        }
	}
}
