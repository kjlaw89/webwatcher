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
using App.Enums;
using App.Models;

namespace App.Widgets {

     /**
     * The {@code IndicatorItem} class is responsible for displaying the options
     * where the user can add and remove sites from the monitor
     *
     * @see Gtk.Grid
     * @since 0.0.1
     */
    public class IndicatorItem : Gtk.ImageMenuItem {

        private string previousLabel;
        private string previousStatus;
        private SiteModel _site;

        public signal void changed ();
        public SiteModel Site { get { return _site; } }
        

        /**
         * Constructs a new {@code Toolbar} object.
         */
        public IndicatorItem (SiteModel site) {
            this._site = site;

            this.always_show_image = true;
            this.image = new Gtk.Image ();
            this.update ();

            site.changed.connect ((site, event) => {
                this.update ();
            });
        }

        private void update () {
            var label = Site.url + ((Site.title.length > 0) ? " - " + Site.title : "");
            if (label.length > 45) {
                label = label.substring (0, 45) + "...";
            }

            if (this.previousLabel != null && this.previousLabel != this.label) {
                this.changed ();
            }

            this.previousLabel = label;
            this.label = label;

            if (this.previousStatus == null || this.previousStatus != Site.status) {
                var image = (this.image as Gtk.Image);
                switch (Site.status) {
                    case "pending":
                        image.set_from_icon_name ("emblem-synchronized", Gtk.IconSize.MENU);
                        break;
                    case "good":
                        image.set_from_icon_name ("process-completed", Gtk.IconSize.MENU);
                        break;
                    case "bad":
                        image.set_from_icon_name ("process-stop", Gtk.IconSize.MENU);
                        break;
                    default:
                        image.set_from_icon_name ("dialog-warning", Gtk.IconSize.MENU);
                        break;
                }

                if (this.previousStatus != null) {
                    this.changed ();
                }

                this.previousStatus = Site.status;
            }
        }
    }
}
