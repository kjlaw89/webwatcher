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
*
*/

namespace App.Database {

    /**
     * The {@code Database} provides all of the basic functions
     * needed to access and maintain the Sqlite database
     *
     * @see Sqlite.Database
     * @since 1.0.0
     */
    public class DB {

        private static DB? instance = null;
        private Sqlite.Database db;

        public static unowned DB GetInstance () {
            if (instance == null) {
                instance = new DB ();
            }

            return instance;
        }

        public Sqlite.Database conn { get { return this.db; } }

        /**
         * Constructs a new {@code Application} object.
         *
         * @see webwatcher.Configs.Constants
         */
        private DB () {
            var dataDir = Environment.get_home_dir () + "/.local/share/com.github.kjlaw89.webwatcher";

            int status = Sqlite.Database.open (dataDir + "/sites.db", out this.db);
            if (status != Sqlite.OK) {
                error (_("Unable to open sites database: %d: %s\n"), this.db.errcode (), this.db.errmsg ());
            }

            Migrations ();
        }

        private void Migrations () {
            var oldVersion = 0;

            string[] results;
            int rows;
            int columns;

            this.db.get_table ("SELECT value FROM `settings` WHERE key = 'version'", out results, out rows, out columns);

            if (rows > 0) {
                oldVersion = (int)results[0].replace (".", "");
            }

            // Initial migration
            if (1 > oldVersion) {
                var settingsSQL = """
                    CREATE TABLE `settings` (
                        id          INTEGER     PRIMARY KEY AUTOINCREMENT,
                        key         TEXT        NOT NULL,
                        value       TEXT        NOT NULL
                    );

                    INSERT INTO `settings` (`key`, `value`) VALUES ('version', '1.0.0');
                    CREATE INDEX `key` ON `settings` (key);
                """;

                this.Execute (settingsSQL);

                var sitesSQL = """
                    CREATE TABLE `sites` (
                        id          INTEGER     PRIMARY KEY AUTOINCREMENT,
                        url         TEXT        NOT NULL,
                        description TEXT        NULL,
                        title       TEXT        NULL,
                        icon        TEXT        NULL,
                        response    REAL        NULL,
                        active      INTEGER     NOT NULL,
                        `order`     INTEGER     NOT NULL,
                        status      TEXT        NOT NULL,
                        notify      INTEGER     NOT NULL,
                        updated_dt  INTEGER     NULL,
                        icon_updated_dt INTEGER NULL
                    );

                    CREATE INDEX `active` ON `sites` (active);
                    CREATE INDEX `title` ON `sites` (title);
                    CREATE INDEX `updated_dt` ON `sites` (updated_dt);
                    CREATE UNIQUE INDEX `url` ON `sites` (url);
                """;

                this.Execute (sitesSQL);

                var siteResultSQL = """
                    CREATE TABLE `results` (
                        id            INTEGER     PRIMARY KEY AUTOINCREMENT,
                        site_id       INTEGER     NOT NULL,
                        response      REAL        NOT NULL,
                        response_code INTEGER     NOT NULL,
                        status        TEXT        NOT NULL,
                        offline       INTEGER     NOT NULL,
                        created_dt    INTEGER     NOT NULL
                    );

                    CREATE INDEX `site_id` ON `results` (site_id);
                    CREATE INDEX `status` ON `results` (status);
                    CREATE INDEX `created_dt` ON `results` (created_dt);
                """;

                this.Execute (siteResultSQL);
            }

            var updateSQL = "UPDATE `settings` SET value = '" + App.Configs.Constants.VERSION +"' WHERE key = 'version'";
            this.Execute (updateSQL);
        }

        public int64 LastID () {
            return this.db.last_insert_rowid ();
        }

        public bool Execute (string query, Sqlite.Callback? callback = null) {
            string error;
            var result = this.db.exec (query, callback, out error);
            if (result != Sqlite.OK) {
                warning ("Error performing query: %s", error);
                return false;
            }

            return true;
        }

        public bool ExecuteStatement (Sqlite.Statement statement) {
            statement.step ();

            var status = this.db.errcode ();
            if (status > 0 && status < 100) {
                warning ("Error execute statement: %d - %s", this.db.errcode (), this.db.errmsg ());
                return false;
            }

            return true;
        }

        public Sqlite.Statement? Prepare (string query, out string? errorMsg = null) {
            Sqlite.Statement statement;
            var result = this.db.prepare_v2 (query, query.length, out statement);
            errorMsg = "";

            if (result != Sqlite.OK) {
                warning ("Error querying DB: %d - %s", this.db.errcode (), this.db.errmsg ());
                errorMsg = this.db.errmsg ();
            }

            return statement;
        }

        public void bind_int (Sqlite.Statement statement, string name, int? val = null) {
            int pos = statement.bind_parameter_index (name);
            if (pos == 0) {
                return;
            }

            if (val != null) {
                statement.bind_int (pos, val);
            }
            else {
                statement.bind_null (pos);
            }
        }

        public void bind_int64 (Sqlite.Statement statement, string name, int64? val = null) {
            int pos = statement.bind_parameter_index (name);
            if (pos == 0) {
                return;
            }

            if (val != null) {
                statement.bind_int64 (pos, val);
            }
            else {
                statement.bind_null (pos);
            }
        }

        public void bind_string (Sqlite.Statement statement, string name, string? val = null) {
            int pos = statement.bind_parameter_index (name);
            if (pos == 0) {
                return;
            }

            if (val != null) {
                statement.bind_text (pos, val);
            }
            else {
                statement.bind_null (pos);
            }
        }

        public void bind_text (Sqlite.Statement statement, string name, string? val = null) {
            bind_string (statement, name, val);
        }

        public void bind_bool (Sqlite.Statement statement, string name, bool? val = null) {
            int pos = statement.bind_parameter_index (name);
            if (pos == 0) {
                return;
            }

            if (val != null) {
                statement.bind_int (pos, (int)val);
            }
            else {
                statement.bind_null (pos);
            }
        }

        public void bind_double (Sqlite.Statement statement, string name, double? val = null) {
            int pos = statement.bind_parameter_index (name);
            if (pos == 0) {
                return;
            }

            if (val != null) {
                statement.bind_double (pos, val);
            }
            else {
                statement.bind_null (pos);
            }
        }
    }
}
