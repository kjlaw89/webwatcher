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
using App.Models;
using App.Views;
using App.Widgets;


namespace App.Views {

	/**
     * The {@code SiteListView} class.
     *
     * @since 1.0.0
     */
	public class SiteListView : Gtk.Viewport {

        private Gtk.Label headerLabel;
        private Gtk.Box content;
        private Gee.HashMap<SiteModel, SiteItem> sitesList = new Gee.HashMap<SiteModel, SiteItem> ();

        public signal void site_selected (SiteModel site);

		/**
         * Constructs a new {@code SiteListView} object.
         */
        public SiteListView () {
            get_style_context ().add_class (Gtk.STYLE_CLASS_VIEW);
            get_style_context ().add_class (Granite.STYLE_CLASS_WELCOME);
            
            this.content = new Gtk.Box (Gtk.Orientation.VERTICAL, 10);

            this.headerLabel = new Granite.HeaderLabel ("");
            this.headerLabel.margin_start = 15;
            this.headerLabel.get_style_context ().add_class ("h1");

            this.content.add (this.headerLabel);
            this.add (this.content);
            this.update_header ();
        }

        public void addSite (SiteModel site) {
            var item = new SiteItem (site);
            item.show_all ();
            item.event.connect ((event) => {
                if (event.type == Gdk.EventType.BUTTON_RELEASE) {
                    this.site_selected (site);
                }

                return false;
            });

            sitesList.set (site, item);
            this.content.add (item);
            this.update_header ();

            Gtk.StyleContext.reset_widgets (get_style_context ().screen);
        }

        public void removeSite (SiteModel site) {
            var item = sitesList.get (site);
            sitesList.unset (site);

            this.content.remove (item);
            this.update_header ();
            
            Gtk.StyleContext.reset_widgets (get_style_context ().screen);
        }

        private void update_header (int? results = null) {
            var text = "";

            if (results != null && results >= 0) {
                switch (results) {
                    case 0:
                        text = _("No results...");
                        break;
                    case 1:
                        text = "1 " + _("result");
                        break;
                    default:
                        text = results.to_string () +" "+ _("results");
                        break;
                }
            }
            else if (this.sitesList.size == 1) {
                text = "1 " + _("Monitored Site");
            }
            else {
                text = this.sitesList.size.to_string () + " " + _("Monitored Sites");
            }

            this.headerLabel.label = text;
            this.headerLabel.show ();
        }

        public void filter (string filter) {
            foreach (var child in this.content.get_children ()) {
                this.content.remove (child);
            }

            this.content.add (this.headerLabel);

            if (filter == null || filter == "") {
                foreach (var entry in sitesList.entries) {
                    this.content.add (entry.value);
                }

                this.update_header ();
                Gtk.StyleContext.reset_widgets (get_style_context ().screen);
                return;
            }

            var results = 0;
            foreach (var entry in sitesList.entries) {
                var title = entry.key.title ?? "";
                var url = entry.key.url;

                if (title.index_of (filter) == -1 && url.index_of (filter) == -1) {
                    continue;
                }

                this.content.add (entry.value);
                results++;
            }

            this.update_header (results);
            Gtk.StyleContext.reset_widgets (get_style_context ().screen);
        }
	}
}
