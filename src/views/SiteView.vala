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
     * The {@code SiteView} class.
     *
     * @since 0.0.1
     */
	public class SiteView : Gtk.Box {

        private Gtk.Label headerLabel;
        private Gtk.Box content;
        private Gee.HashMap<SiteModel, SiteItem> sitesList = new Gee.HashMap<SiteModel, SiteItem> ();

		/**
         * Constructs a new {@code SiteView} object.
         */
        public SiteView (SiteModel site) {
            get_style_context ().add_class (Gtk.STYLE_CLASS_VIEW);
            get_style_context ().add_class (Granite.STYLE_CLASS_WELCOME);

        }

	}
}
