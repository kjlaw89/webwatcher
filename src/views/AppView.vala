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
    public class AppView : Gtk.Grid {

        private Gtk.ApplicationWindow   app;
        private SiteView                activeSiteView;
        public HeaderBar                headerbar;
        public Gtk.ScrolledWindow       mainContent;
        public Gtk.Box                  siteContent;
        public SiteListView             siteListView;
        public Gtk.Stack                stack;
        public WelcomeView              welcomeView;

        public signal void menu_event (SiteModel? site, IndicatorEvent event);
        public signal void site_event (SiteModel site, SiteEvent event);

        /**
         * Constructs a new {@code AppView} object.
         */
        public AppView (Gtk.ApplicationWindow app) {
            this.app = app;
            this.app.set_default_size (700, 600);
            this.app.set_size_request (700, 600);
            this.app.deletable = true;
            this.app.resizable = true;
            
            this.headerbar = new HeaderBar ();
            this.headerbar.menu_event.connect ((site, event) => { this.menu_event (site, event); });
            this.headerbar.site_event.connect ((site, event) => { this.site_event (site, event); });
            this.headerbar.back.connect (() => {
                this.hide_site ();
            });

            this.headerbar.filter.connect ((filter) => {
                this.siteListView.filter (filter);
            });

            this.app.set_titlebar (this.headerbar);

            // Initialize our views first
            this.welcomeView = new WelcomeView ();
            this.siteListView = new SiteListView ();
            this.siteListView.site_selected.connect ((site) => {
                this.show_site (site);
            });

            // Initialize our control view
            this.stack = new Gtk.Stack ();
            this.stack.expand = true;
            this.stack.transition_type = Gtk.StackTransitionType.SLIDE_LEFT_RIGHT;
            this.add (stack);
            
            this.mainContent = new Gtk.ScrolledWindow (null, null);
            this.siteContent = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
            this.siteContent.hexpand = true;
            this.siteContent.vexpand = true;

            this.stack.add_named (mainContent, "main-content");
            this.stack.add_named (siteContent, "site-content");
            this.stack.visible_child_name = "main-content";
        }
        
        public void show_welcome () {
            foreach (var child in mainContent.get_children ()) {
                mainContent.remove (child);
            }
            
            mainContent.add (this.welcomeView);
            mainContent.show_all ();
        }

        public void show_sites () {
            foreach (var child in mainContent.get_children ()) {
                mainContent.remove (child);
            }

            mainContent.add (this.siteListView);
            mainContent.show_all ();
        }

        public void show_site (SiteModel site) {
            this.activeSiteView = new SiteView (site);
            this.stack.visible_child_name = "site-content";

            this.siteContent.add (this.activeSiteView);
            this.headerbar.show_back ();
        }

        public void hide_site () {
            foreach (var child in this.siteContent.get_children ()) {
                this.siteContent.remove (child);
            }

            this.activeSiteView = null;
            this.stack.visible_child_name = "main-content";
            this.headerbar.hide_back ();
        }
    }
}
