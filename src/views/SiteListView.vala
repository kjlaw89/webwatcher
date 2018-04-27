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
     * @since 0.0.1
     */
	public class SiteListView : Gtk.Viewport {

        private Gtk.Box content;
        private Gee.HashMap<SiteModel, SiteItem> sitesList = new Gee.HashMap<SiteModel, SiteItem> ();

		/**
         * Constructs a new {@code SiteListView} object.
         */
        public SiteListView () {
            this.content = new Gtk.Box (Gtk.Orientation.VERTICAL, 10);

            var headerLabel = new Granite.HeaderLabel (_("Monitored sites"));
            headerLabel.margin_left = 15;
            headerLabel.get_style_context ().add_class ("h1");

            this.content.add (headerLabel);
            this.add (this.content);
        }

        public void addSite (SiteModel site) {
            var item = new SiteItem (site);
            sitesList.set (site, item);

            this.content.add (item);
        }

        public void removeSite (SiteModel site) {
            var item = sitesList.get (site);
            sitesList.remove (site);

            this.content.remove (item);
        }
	}
}
