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
     * @since 1.0.0
     */
	public class SiteView : Gtk.Box {

        private Gtk.ScrolledWindow scrollResultsWindow;
        private Gtk.Viewport resultsViewport;
        private Gee.HashMap<SiteModel, SiteItem> sitesList = new Gee.HashMap<SiteModel, SiteItem> ();

        private string    _iconDir;
        private SiteModel _site;

        private SiteFormView formView;
        private Gtk.Box   header;
        private Granite.AsyncImage  iconImage;
        private Gtk.Label titleLabel;
        private Gtk.TreeView treeView;
        private Gtk.Button updateButton;
        private Gtk.Popover updatePopover;
        private Gtk.Box urlBox;
        private Gtk.Label urlLabel;

        public SiteModel Site { get { return _site; } }

		/**
         * Constructs a new {@code SiteView} object.
         */
        public SiteView (SiteModel site) {
            this.orientation = Gtk.Orientation.VERTICAL;

            this._iconDir = Environment.get_home_dir () + "/.local/share/com.github.kjlaw89.webwatcher/icons/";
            this._site = site;

            this.titleLabel = new Gtk.Label (null);
            this.titleLabel.wrap = true;
            this.titleLabel.justify = Gtk.Justification.CENTER;
            this.titleLabel.get_style_context ().add_class ("h4");

            this.urlLabel = new Gtk.Label (null);
            this.updateButton = new Gtk.Button.from_icon_name ("edit-symbolic", Gtk.IconSize.BUTTON);
            this.updateButton.get_style_context ().add_class ("image-button");
            this.updateButton.margin_start = 10;
            this.updateButton.clicked.connect (() => {
                this.updatePopover.show ();
                this.formView.clear ();
            });

            this.urlBox = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
            this.urlBox.halign = Gtk.Align.CENTER;
            this.urlBox.margin_bottom = 10;
            this.urlBox.add (this.urlLabel);
            this.urlBox.add (this.updateButton);
            

            this.iconImage = new Granite.AsyncImage ();
            this.iconImage.margin = 10;
            this.iconImage.width_request = 64;
            this.iconImage.height_request = 64;

            this.header = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
            this.header.add (iconImage);
            this.header.add (titleLabel);
            this.header.add (urlBox);
            this.header.hexpand = true;

            this.resultsViewport = new Gtk.Viewport (null, null);
            this.scrollResultsWindow = new Gtk.ScrolledWindow (null, null);
            this.scrollResultsWindow.add (resultsViewport);
            this.scrollResultsWindow.get_style_context ().add_class (Gtk.STYLE_CLASS_VIEW);
            this.scrollResultsWindow.get_style_context ().add_class (Granite.STYLE_CLASS_WELCOME);
            this.scrollResultsWindow.vexpand = true;

            this.treeView = new Gtk.TreeView ();
            this.treeView.expand = true;

            var cell = new Gtk.CellRendererText ();
            cell.xalign = 0.5f;

            var statusCell = new Gtk.CellRendererText ();
            statusCell.xalign = 0.9f;

            this.treeView.insert_column_with_attributes (-1, "Time", cell, "text", 0);
            this.treeView.insert_column_with_attributes (-1, "Response", cell, "text", 1);
            this.treeView.insert_column_with_attributes (-1, "Status Code", cell, "text", 2);
            this.treeView.insert_column_with_attributes (-1, "Status", statusCell, "text", 3);

            var column = this.treeView.get_column (0);
            column.min_width = 100;
            column.alignment = 0.5f;

            column = this.treeView.get_column (1);
            column.min_width = 120;
            column.alignment = 0.5f;

            column = this.treeView.get_column (2);
            column.min_width = 120;
            column.alignment = 0.5f;

            column = this.treeView.get_column (3);
            column.min_width = 100;
            column.alignment = 0.9f;

            resultsViewport.add (this.treeView);

            this.add (header);
            this.add (scrollResultsWindow);
            this.expand = true;

            this.update ();

            site.changed.connect ((site, event) => {
                this.update ();
            });

            this.setup_popover ();
            this.show_all ();
        }

        private void setup_popover () {
            this.formView = new SiteFormView (Site);
            this.formView.site_event.connect ((site, event) => {
                this.updatePopover.hide ();
                //this.site_event (site, event);
            });

            this.updatePopover = new Gtk.Popover (this.updateButton);
            this.updatePopover.set_size_request (450, 150);
            this.updatePopover.modal = true;
            this.updatePopover.add (formView);
        }

        private void update () {
            this.titleLabel.label = Site.title ?? "--";
            this.titleLabel.tooltip_text = Site.title ?? "--";

            this.urlLabel.set_markup ("<a href='"+ Site.url +"'>"+ Site.url +"</a>");

            var iconFile = Site.get_icon_file ();
            if (iconFile != null) {
                this.iconImage.set_from_file_async.begin (iconFile, 64, 64, true);
            }
            else {
                this.iconImage.set_from_icon_name_async.begin ("www", Gtk.IconSize.DIALOG);
            }

            Gtk.TreeIter iter;
            var store = new Gtk.ListStore (4, typeof (string), typeof (string), typeof (string), typeof (string));

            var db = App.Database.DB.GetInstance ();
            var sql = "
                SELECT 
                    created_dt, 
                    response, 
                    response_code, 
                    status
                FROM `results` 
                WHERE site_id = $SITE_ID AND created_dt >= $CREATED_DT
                ORDER BY created_dt DESC";

            var statement = db.Prepare (sql);
            db.bind_int (statement, "$SITE_ID", Site.id);
            db.bind_int64 (statement, "$CREATED_DT", new DateTime.now_utc ().to_unix () - 7200);
            
            var columns = statement.column_count ();
            while (statement.step () == Sqlite.ROW) {
                var time = "";
                var response = "";
                var statusCode = 0;
                var status = "";

                for (int i = 0; i < columns; i++) {
                    unowned Sqlite.Value val = statement.column_value (i);

                    switch (i) {
                        case 0:
                            time = new DateTime.from_unix_utc (val.to_int64 ()).to_local ().format (Granite.DateTime.get_default_time_format (false, true));
                            break;
                        case 1:
                            response = val.to_int ().to_string () + "ms";
                            break;
                        case 2:
                            statusCode = val.to_int ();
                            break;
                        case 3:
                            switch (val.to_text ()) {
                                case "good":
                                    status = "Good";
                                    break;
                                case "warning":
                                    status = "Unknown";
                                    break;
                                default:
                                    status = "Offline";
                                    break;
                            }
                            break;
                    }
                }

                store.append (out iter);
                store.set (iter, 0, time, 1, response, 2, statusCode.to_string (), 3, status);
            }

            this.treeView.set_model (store);
            this.treeView.show_all ();
        }
	}
}
