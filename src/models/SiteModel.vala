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

using App.Enums;

namespace App.Models {

    /**
     * The {@code SiteModel} class.
     *
     * @since 0.0.1
     */
	public class SiteModel : BaseModel {

        public int id { get; set; }
        public string url { get; set; }
        public string description { get; set; }
        public string title { get; set; }
        public string icon { get; set; }
        public double response { get; set; default = 0; }
        public bool active { get; set; default = true; }
        public int order { get; set; default = 0; }
        public string status { get; set; default = "pending"; }
        public bool notify { get; set; default = true; }
        public int updated_dt { get; set; default = 0; }

        public signal void changed (SiteModel site, SiteEvent event);

        /**
         * Constructs a new {@code SiteModel} object.
         */
		public SiteModel () {}

        public SiteModel.with_url (string url, bool notify) {
            this.url = url;
            this.notify = notify;
        }

        public override bool get (int id) {
            var statement = this.db.Prepare ("SELECT * FROM `sites` WHERE id = $ID");
            this.db.bind_int (statement, "$ID", id);

            return this.load (statement);
        }

        public override bool load (Sqlite.Statement statement) {
            var loaded = false;

            var columns = statement.column_count ();
            while (statement.step () == Sqlite.ROW) {
                loaded = true;

                for (int i = 0; i < columns; i++) {
                    var column = statement.column_name (i);
                    unowned Sqlite.Value val = statement.column_value (i);

                    switch (column) {
                        case "id":
                            this.id = val.to_int ();
                            break;
                        case "url":
                            this.url = val.to_text ();
                            break;
                        case "description":
                            this.description = val.to_text ();
                            break;
                        case "title":
                            this.title = val.to_text ();
                            break;
                        case "response":
                            this.response = val.to_double ();
                            break;
                        case "active":
                            this.active = (bool)val.to_int ();
                            break;
                        case "order":
                            this.order = val.to_int ();
                            break;
                        case "status":
                            this.status = val.to_text ();
                            break;
                        case "notify":
                            this.notify = (bool)val.to_int ();
                            break;
                        case "updated_dt":
                            this.updated_dt = val.to_int ();
                            break;
                    }
                }
            }

            return loaded;
        }
        
        public override bool save () {
            var sql = "";
            var state = SiteEvent.ADDED;

            // Update SQL
            if (id > 0) {
                state = SiteEvent.UPDATED;
            }

            // Insert SQL
            else {
                sql = "
                    INSERT INTO `sites` (`url`, `description`, `active`, `order`, `status`, `notify`)
                    VALUES ($URL, $DESCRIPTION, $ACTIVE, $ORDER, $STATUS, $NOTIFY)
                ";
            }

            var statement = this.db.Prepare (sql);

            // Bind parameters
            this.db.bind_int (statement, "$ID", id);
            this.db.bind_text (statement, "$URL", url);
            this.db.bind_text (statement, "$DESCRIPTION", description);
            this.db.bind_text (statement, "$TITLE", title);
            this.db.bind_text (statement, "$ICON", icon);
            this.db.bind_double (statement, "$RESPONSE", response);
            this.db.bind_bool (statement, "$ACTIVE", active);
            this.db.bind_int (statement, "$ORDER", order);
            this.db.bind_text (statement, "$STATUS", status);
            this.db.bind_bool (statement, "$NOTIFY", notify);
            this.db.bind_int (statement, "$UPDATED_DT", updated_dt);

            if (!this.db.ExecuteStatement (statement)) {
                return false;
            }
            
            this.changed (this, state);
            return true;
        }

        public override bool delete () {
            return false;
        }
	}

}
