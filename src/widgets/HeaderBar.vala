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
using App.Utils;
using App.Views;

namespace App.Widgets {

    /**
     * The {@code HeaderBar} class is responsible for displaying top bar. Similar to a horizontal box.
     *
     * @see Gtk.HeaderBar
     * @since 1.0.0
     */
    public class HeaderBar : Gtk.HeaderBar {

        public signal void site_event (SiteModel site, SiteEvent event);
        public signal void back ();
        public signal void filter (string filter);
        
        private Gtk.Button         backButton;
        private Gtk.Box            buttonBox;
        private Views.SiteFormView formView;
        private Gtk.Button         newButton;
        private Gtk.Popover        newPopover;
        private Gtk.SearchEntry    searchEntry;
        

        /**
         * Constructs a new {@code HeaderBar} object.
         *
         * @see App.Configs.Properties
         * @see icon_settings
         */
        public HeaderBar () {
            this.show_close_button = true;
            icon_settings ();
        }

        /**
         * Add gear icon to open settings menu.
         * 
         * @see menu_settings
         * @return {@code void}
         */
        private void icon_settings () {

            this.newButton = new Gtk.Button.with_mnemonic (_("_New"));
            this.newButton.get_style_context ().add_class ("suggested-action");
            this.newButton.clicked.connect (() => {
                this.newPopover.show ();
                this.formView.clear ();
            });

            this.backButton = new Gtk.Button.with_mnemonic (_("_Back"));
            this.backButton.get_style_context ().add_class ("back-button");
            this.backButton.clicked.connect (() => {
                this.hide_back ();
                this.back ();
            });
            

            this.searchEntry = new Gtk.SearchEntry ();
            this.searchEntry.placeholder_text = _("Filter sites...");
            this.searchEntry.search_changed.connect (() => {
                this.filter (this.searchEntry.text);
            });

            buttonBox = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
            buttonBox.add (this.newButton);

            this.pack_start (buttonBox);
            this.pack_end (this.searchEntry);

            this.setup_popover ();
        }

        private void setup_popover () {
            this.formView = new Views.SiteFormView ();
            this.formView.site_event.connect ((site, event) => {
                this.newPopover.hide ();
                this.site_event (site, event);
            });

            this.newPopover = new Gtk.Popover (this.newButton);
            this.newPopover.set_size_request (450, 150);
            this.newPopover.modal = true;
            this.newPopover.add (formView);
        }

        public void show_back () {
            foreach (var child in this.buttonBox.get_children ()) {
                this.buttonBox.remove (child);
            }

            this.buttonBox.add (this.backButton);
            this.buttonBox.show_all ();
            this.searchEntry.sensitive = false;
        }

        public void hide_back () {
            foreach (var child in this.buttonBox.get_children ()) {
                this.buttonBox.remove (child);
            }

            this.buttonBox.add (this.newButton);
            this.buttonBox.show_all ();
            this.searchEntry.sensitive = true;
        }

        public void search () {
            if (!this.searchEntry.sensitive) {
                return;
            }

            this.searchEntry.has_focus = true;
        }
    }
}
