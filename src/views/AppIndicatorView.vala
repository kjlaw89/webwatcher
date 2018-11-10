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
using App.Enums;
using App.Models;
using App.Widgets;

namespace App.Views {

    /**
     * The {@code AppView} class.
     *
     * @since 1.0.0
     */
    public class AppIndicatorView : Gtk.Menu {

        public signal void menu_event (SiteModel? site, IndicatorEvent event);

        private Gee.HashMap<SiteModel, IndicatorItem> sitesList = new Gee.HashMap<SiteModel, IndicatorItem> ();
        private AppIndicator.Indicator indicator;

        /**
         * Constructs a new {@code AppIndicatorView} object.
         */
        public AppIndicatorView (AppIndicator.Indicator indicator) {
            this.indicator = indicator;
            build_menu ();
        }

        public void addSite (SiteModel site) {
            var item = new IndicatorItem (site);
            item.show_all ();

            item.changed.connect (() => {
                build_menu (true);
            });

            item.activate.connect (() => {
                this.menu_event (item.Site, IndicatorEvent.SELECTED);
            });

            sitesList.set (site, item);
            build_menu ();
        }

        public void removeSite (SiteModel site) {
            sitesList.unset (site);

            build_menu ();
        }

        public void sort_list () {

        }

        private void build_menu (bool refresh = false) {
            /*
            ToDO: Find a way to refresh widgets without destroying
            if (refresh) {
                foreach (var child in this.get_children ()) {
                    child.hide ();
                }

                this.show_all ();

                return;
            }*/

            foreach (var child in this.get_children ()) {
                this.remove (child);
            }

            foreach (var entry in sitesList.entries) {
                if (entry.key.active == false) {
                    continue;
                }

                this.add (entry.value);
            }


            var showItem = new Gtk.MenuItem.with_label (_("Show Web Watcher"));
            showItem.activate.connect (() => {
                this.menu_event (null, IndicatorEvent.SHOW);
            });

            var quitItem = new Gtk.MenuItem.with_label (_("Quit"));
            quitItem.activate.connect (() => {
                this.menu_event (null, IndicatorEvent.QUIT);
            });

            var separator = new Gtk.SeparatorMenuItem ();

            this.append (separator);
            this.append (showItem);
            this.append (quitItem);
            this.show_all ();

            this.indicator.set_menu (this);
            this.indicator.set_secondary_activate_target (quitItem);
        }
    }
}
