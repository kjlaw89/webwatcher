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

using App.Widgets;
using App.Configs;

namespace App.Views {

	/**
     * The {@code AppView} class.
     *
     * @since 0.0.1
     */
	public class SiteFormView : Gtk.Box {

        public signal void submit ();

        private Gtk.Entry   urlEntry;
        private Gtk.Switch  alertSwitch;
        private Gtk.Button  actionButton;

		/**
         * Constructs a new {@code SiteFormView} object.
         */
		public SiteFormView () {
            this.urlEntry = new Gtk.Entry ();
            this.urlEntry.hexpand = true;
            this.urlEntry.placeholder_text = _("Site URL");
            this.urlEntry.secondary_icon_name = "dialog-information-symbolic";
            this.urlEntry.secondary_icon_tooltip_text = _("Must be a valid URL (should start with http/https)");
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

            this.actionButton = new Gtk.Button.with_mnemonic (_("Monitor Site"));
            this.actionButton.halign = Gtk.Align.END;
            this.actionButton.get_style_context ().add_class ("suggested-action");
            this.actionButton.sensitive = false;
            this.actionButton.clicked.connect (this.handleSubmit);

            // Setup layout
            var grid = new Gtk.Grid ();
            grid.column_homogeneous = false;
            grid.column_spacing = 12;
            grid.row_spacing = 12;
            
            grid.attach (urlLabel, 0, 0);
            grid.attach (urlEntry, 1, 0);
            grid.attach (alertLabel, 0, 1);
            grid.attach (alertSwitch, 1, 1);
            grid.show_all ();
            
            this.pack_start (grid, true, true, 0);
            this.pack_start (this.actionButton, false, false, 0);
            this.margin = 12;
            this.orientation = Gtk.Orientation.VERTICAL;
            this.show_all ();
        }

        private bool isValid () {
            var url = this.urlEntry.text;
            return Utils.URLUtil.check_url_with_regex (url);
        }

        private bool handleInput (Gdk.EventKey key) {
            
            this.actionButton.sensitive = this.isValid ();
            return false;
        }

        private void handleInputSubmit () {
            this.actionButton.sensitive = this.isValid ();
            this.handleSubmit ();
        }

        private void handleSubmit () {
            if (!this.isValid ()) {
                return;
            }

            var model = new App.Models.SiteModel.with_url (this.urlEntry.text, this.alertSwitch.active);
            model.save ();
        }
        
        public void clear () {
            this.urlEntry.text = "";
            this.alertSwitch.active = true;
            this.actionButton.sensitive = false;
        }
	}
}
