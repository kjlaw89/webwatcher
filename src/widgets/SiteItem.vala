/*
* Copyright (c) 2018 KJ Lawrence <kjtehprogrammer@gmail.com>
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
using App.Enums;
using App.Models;

namespace App.Widgets {

     /**
     * The {@code SiteItem} class is responsible for displaying the options
     * where the user can add and remove sites from the monitor
     *
     * @see Gtk.Grid
     * @since 1.0.0
     */
    public class SiteItem : Gtk.EventBox {

        private string    _iconDir;
        private SiteModel _site;

        private Gtk.Grid  grid;
        private Gtk.Label lastUpdateLabel;
        private Gtk.Image nextImage;
        private Gtk.Label responseLabel;
        private Gtk.Image statusImage;
        private Gtk.Label titleLabel;
        private Gtk.Label urlLabel;
        
        public SiteModel Site { get { return _site; } }
        
        /**
         * Constructs a new {@code Toolbar} object.
         */
        public SiteItem (SiteModel site) {
            this._iconDir = Environment.get_home_dir () + "/.local/share/com.github.kjlaw89.webwatcher/icons/";
            this._site = site;

            this.titleLabel = new Gtk.Label (null);
            this.titleLabel.halign = Gtk.Align.START;

            this.urlLabel = new Gtk.Label (null);
            this.urlLabel.halign = Gtk.Align.START;

            this.lastUpdateLabel = new Gtk.Label (null);
            this.lastUpdateLabel.halign = Gtk.Align.END;

            this.responseLabel = new Gtk.Label (null);
            this.statusImage = new Gtk.Image ();
            this.nextImage = new Gtk.Image.from_icon_name ("go-next-symbolic", Gtk.IconSize.SMALL_TOOLBAR);
            this.nextImage.opacity = 0.3;

            var imageBox = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
            imageBox.margin_start = 10;
            imageBox.valign = Gtk.Align.CENTER;
            imageBox.width_request = 28;
            imageBox.add (Site.get_icon_image ());

            var textBox = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
            textBox.add (titleLabel);
            textBox.add (urlLabel);            

            var statusGrid = new Gtk.Grid ();
            statusGrid.hexpand = true;
            statusGrid.halign = Gtk.Align.END;
            statusGrid.valign = Gtk.Align.CENTER;
            statusGrid.margin_end = 10;

            var statusBox = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
            statusBox.width_request = 100;
            statusBox.add (statusImage);
            statusBox.add (responseLabel);

            statusGrid.attach (this.lastUpdateLabel, 0, 0);
            statusGrid.attach (statusBox, 1, 0);
            statusGrid.attach (nextImage, 2, 0);

            this.grid = new Gtk.Grid ();
            this.grid.attach (imageBox, 0, 0);
            this.grid.attach (textBox, 1, 0);
            this.grid.attach (statusGrid, 2, 0, 4);
            this.grid.column_spacing = 10;
            this.grid.set_row_baseline_position (0, Gtk.BaselinePosition.CENTER);
            this.grid.height_request = 50;
            this.add (this.grid);

            this.update ();
            site.changed.connect ((site, event) => {
                this.update ();
            });

            Timeout.add_seconds_full (1, 1, () => {
                this.refreshTime ();
                return true;
            });
        }

        public void update () {
            var title = Site.title ?? "--";
            if (title.length > 35) {
                title = title.substring (0, 35) + "…";
            }

            this.titleLabel.label = title;
            this.titleLabel.tooltip_text = Site.title ?? "--";

            this.urlLabel.set_markup ("<a href='"+ Site.url +"'>"+ Site.url +"</a>");

            switch (Site.status) {
                case "pending":
                    this.statusImage.set_from_icon_name ("emblem-synchronized", Gtk.IconSize.LARGE_TOOLBAR);
                    break;
                case "good":
                    this.statusImage.set_from_icon_name ("process-completed", Gtk.IconSize.LARGE_TOOLBAR);
                    break;
                case "bad":
                    this.statusImage.set_from_icon_name ("process-stop", Gtk.IconSize.LARGE_TOOLBAR);
                    break;
                default:
                    this.statusImage.set_from_icon_name ("dialog-warning", Gtk.IconSize.LARGE_TOOLBAR);
                    break;
            }

            if (Site.status == "good") {
                this.responseLabel.label = Site.response.to_string () + "ms";
            }

            this.grid.opacity = (!Site.active) ? 0.5f : 1;

            this.refreshTime ();
        }

        public void refreshTime () {
            this.lastUpdateLabel.label = Granite.DateTime.get_relative_datetime (new DateTime.from_unix_utc (Site.updated_dt).to_local ());

            if (Site.status == "good") {
                this.responseLabel.show ();
            }
            else {
                this.responseLabel.hide ();
            }
        }
    }
}
