/*
* Copyright (c) 2017 KJ Lawrence <kjtehprogrammer@gmail.com>
*
* This program is free software; you can redistribute it and/or
* modify it under the terms of the GNU General Public
* License as published by the Free Software Foundation; either
* version 2 of the License, or (at your option) any later version.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
* General Public License for more details.
*
* You should have received a copy of the GNU General Public
* License along with this program; if not, write to the
* Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
* Boston, MA 02110-1301 USA
*/

using App.Configs;
using App.Models;

namespace App.Widgets {

     /**
     * The {@code SiteItem} class is responsible for displaying the options
     * where the user can add and remove sites from the monitor
     *
     * @see Gtk.Grid
     * @since 0.0.1
     */
    public class SiteItem : Gtk.Grid {

        private Gtk.Label titleLabel;
        private Gtk.Label urlLabel;
        private Gtk.Label responseLabel;
        private Gtk.Label lastUpdatedLabel;
        private Gtk.Image statusImage;
        private Gtk.Image iconImage;
        

        /**
         * Constructs a new {@code Toolbar} object.
         */
        public SiteItem (SiteModel site) {
            this.set_row_baseline_position (0, Gtk.BaselinePosition.CENTER);
            this.height_request = 50;

            this.titleLabel = new Gtk.Label (site.title ?? "--");
            this.titleLabel.halign = Gtk.Align.START;

            this.urlLabel = new Gtk.Label (null);
            this.urlLabel.set_markup ("<a href='"+ site.url +"'>"+ site.url +"</a>");
            this.urlLabel.halign = Gtk.Align.START;
            //this.responseLabel = new Gtk.Label (site.response ?? "--ms");
            //this.lastUpdatedLabel = new Gtk.Label (site.updated_dt > 0  )
            this.statusImage = new Gtk.Image ();
            this.iconImage = new Gtk.Image ();

            var textBox = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
            textBox.add (titleLabel);
            textBox.add (urlLabel);

            this.attach (iconImage, 0, 0);
            this.attach (textBox, 1, 0);
        }
    }
}
