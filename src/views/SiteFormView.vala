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
    public class SiteFormView : Gtk.Box {

        public signal void site_event (SiteModel site, SiteEvent event);

        
        private Gtk.Switch  activeSwitch;
        private Gtk.Switch  alertSwitch;
        private Gtk.Button  deleteButton;
        private Gtk.Button  saveButton;
        private SiteModel   site;
        private Gtk.Entry   urlEntry;

        /**
         * Constructs a new {@code SiteFormView} object.
         */
        public SiteFormView (SiteModel? site = null) {
            this.site = site;

            this.urlEntry = new Gtk.Entry ();
            this.urlEntry.hexpand = true;
            this.urlEntry.placeholder_text = _("Site URL");
            this.urlEntry.secondary_icon_name = "dialog-information-symbolic";
            this.urlEntry.secondary_icon_tooltip_text = _("Must be a valid URL that starts with http or https");
            this.urlEntry.key_press_event.connect (this.handleInput);
            this.urlEntry.activate.connect (this.handleInputSubmit);
            
            var urlLabel = new Gtk.Label.with_mnemonic (_("Site _URL") + ":");
            urlLabel.halign = Gtk.Align.END;
            urlLabel.mnemonic_widget = this.urlEntry;

            this.alertSwitch = new Gtk.Switch ();
            this.alertSwitch.halign = Gtk.Align.START;
            this.alertSwitch.active = true;

            var alertLabel = new Gtk.Label.with_mnemonic (_("Alert on _change") + ":");
            alertLabel.halign = Gtk.Align.END;
            alertLabel.mnemonic_widget = this.alertSwitch;

            this.activeSwitch = new Gtk.Switch ();
            this.activeSwitch.halign = Gtk.Align.START;
            this.activeSwitch.active = true;

            var activeLabel = new Gtk.Label.with_mnemonic (_("Monitoring _Enabled") + ":");
            activeLabel.halign = Gtk.Align.END;
            activeLabel.mnemonic_widget = this.activeSwitch;

            this.deleteButton = new Gtk.Button.with_mnemonic (_("_Delete"));
            this.deleteButton.halign = Gtk.Align.START;
            this.deleteButton.get_style_context ().add_class ("destructive-action");
            this.deleteButton.clicked.connect (this.handleDelete);

            this.saveButton = new Gtk.Button.with_mnemonic ((this.site != null) ? _("Update _Site") : _("Monitor _Site"));
            this.saveButton.halign = Gtk.Align.END;
            this.saveButton.get_style_context ().add_class ("suggested-action");
            this.saveButton.sensitive = false;
            this.saveButton.clicked.connect (this.handleSubmit);

            // Setup layout
            var grid = new Gtk.Grid ();
            grid.column_homogeneous = false;
            grid.column_spacing = 12;
            grid.row_spacing = 12;
            
            grid.attach (urlLabel, 0, 0);
            grid.attach (urlEntry, 1, 0);
            grid.attach (alertLabel, 0, 1);
            grid.attach (alertSwitch, 1, 1);

            if (site != null) {
                grid.attach (activeLabel, 0, 2);
                grid.attach (activeSwitch, 1, 2);
            }

            grid.attach (deleteButton, 0, 3);
            grid.attach (saveButton, 1, 3);

            grid.show_all ();
            
            this.pack_start (grid, true, true, 0);
            this.margin = 12;
            this.orientation = Gtk.Orientation.VERTICAL;
            this.show_all ();
        }

        private bool isValid () {
            var url = this.urlEntry.text;
            return Utils.URLUtil.check_url_with_regex (url);
        }

        private bool handleInput (Gdk.EventKey key) {
            
            this.saveButton.sensitive = this.isValid ();
            return false;
        }

        private void handleInputSubmit () {
            this.saveButton.sensitive = this.isValid ();
            this.handleSubmit ();
        }

        private void handleSubmit () {
            if (!this.isValid ()) {
                return;
            }

            if (this.site != null) {
                this.site.active = this.activeSwitch.active;
                this.site.notify = this.alertSwitch.active;
                this.site.url = this.urlEntry.text;
                
                if (this.site.save ()) {
                    site_event (this.site, SiteEvent.UPDATED);
                }
            }
            else {
                var model = new App.Models.SiteModel.with_url (this.urlEntry.text, this.alertSwitch.active);
                if (model.save ()) {
                    site_event (model, SiteEvent.ADDED);
                }
            }
        }

        private void handleDelete () {
            if (this.site == null) {
                return;
            }

            this.site.delete ();
            site_event (this.site, SiteEvent.DELETED);
        }
        
        public void clear () {
            if (this.site != null) {
                this.activeSwitch.active = this.site.active;
                this.alertSwitch.active = this.site.notify;
                this.saveButton.sensitive = true;
                this.urlEntry.text = this.site.url;
            }
            else {
                this.activeSwitch.active = true;
                this.alertSwitch.active = true;
                this.saveButton.sensitive = false;
                this.urlEntry.text = "";
                this.urlEntry.has_focus = true;
            }
            
            this.deleteButton.visible = (this.site != null) ? true : false;
        }
    }
}
