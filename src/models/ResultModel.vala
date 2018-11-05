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

namespace App.Models {

    /**
     * The {@code ResultModel} class.
     *
     * @since 1.0.0
     */
	public class ResultModel : BaseModel {

        public int id { get; set; }
        public int site_id { get; set; }
        public double response { get; set; default = 0; }
        public int response_code { get; set; default = 0; }
        public string status { get; set; default = "pending"; }
        public bool offline { get; set; default = false; }
        public int64 created_dt { get; set; default = 0; }

        public signal void changed (ResultModel site, SiteEvent event);

        /**
         * Constructs a new {@code ResultModel} object.
         */
		public ResultModel () {}

        public ResultModel.with_details (int site, double response, int code, string status) {
            this.site_id = site;
            this.response = response;
            this.response_code = code;
            this.status = status;
            this.save ();
        }

        public override bool get (int id) {
            var statement = this.db.Prepare ("SELECT * FROM `results` WHERE id = $ID");
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
                        case "site_id":
                            this.site_id = val.to_int ();
                            break;
                        case "response":
                            this.response = val.to_double ();
                            break;
                        case "response_code":
                            this.response_code = val.to_int ();
                            break;
                        case "status":
                            this.status = val.to_text ();
                            break;
                        case "offline":
                            this.offline = (bool)val.to_int ();
                            break;
                        case "created_dt":
                            this.created_dt = val.to_int64 ();
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
                sql = """
                    UPDATE `results` SET
                        `site_id` = $SITE_ID,
                        `response` = $RESPONSE,
                        `response_code` = $RESPONSE,
                        `status` = $STATUS,
                        `offline` = $OFFLINE,
                        `created_dt` = $CREATED_DT
                    WHERE
                        `id` = $ID
                """;
            }

            // Insert SQL
            else {
                sql = """
                    INSERT INTO `results` (`site_id`, `response`, `response_code`, `status`, `offline`, `created_dt`)
                    VALUES ($SITE_ID, $RESPONSE, $RESPONSE_CODE, $STATUS, $OFFLINE, $CREATED_DT)
                """;

                this.created_dt = (new DateTime.now_utc ()).to_unix ();
            }

            var statement = this.db.Prepare (sql);

            // Bind parameters
            this.db.bind_int (statement, "$ID", id);
            this.db.bind_int (statement, "$SITE_ID", site_id);
            this.db.bind_double (statement, "$RESPONSE", response);
            this.db.bind_int (statement, "$RESPONSE_CODE", response_code);
            this.db.bind_text (statement, "$STATUS", status);
            this.db.bind_bool (statement, "$OFFLINE", offline);
            this.db.bind_int64 (statement, "$CREATED_DT", created_dt);

            if (!this.db.ExecuteStatement (statement)) {
                return false;
            }

            if (state == SiteEvent.ADDED) {
                this.id = (int)this.db.LastID ();
            }
            
            return true;
        }

        public override bool delete () {
            return false;
        }
	}

}
