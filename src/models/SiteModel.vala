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
     * The {@code SiteModel} class.
     *
     * @since 1.0.0
     */
    public class SiteModel : BaseModel {

        private int failures = 0;
        private bool fetching_icon = false;
        private string _iconDir;
        private Granite.AsyncImage _iconImage;
        private bool running = false;
        private Soup.Session session;

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
        public int64 updated_dt { get; set; default = 0; }
        public int64 icon_updated_dt { get; set; default = 0; }

        public signal void changed (SiteModel site, SiteEvent event);

        /**
         * Constructs a new {@code SiteModel} object.
         */
        public SiteModel () {
            session = new Soup.Session ();
            session.timeout = 60;
            session.user_agent = "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/66.0.3359.117 Safari/537.36";
            session.ssl_strict = false;

            _iconDir = Environment.get_home_dir () + "/.local/share/com.github.kjlaw89.webwatcher/icons/";
            _iconImage = new Granite.AsyncImage ();
        }

        public SiteModel.with_url (string url, bool notify) {
            this.url = url;
            this.notify = notify;

            session = new Soup.Session ();
            session.timeout = 60;
            session.user_agent = "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/66.0.3359.117 Safari/537.36";
            session.ssl_strict = false;

            _iconDir = Environment.get_home_dir () + "/.local/share/com.github.kjlaw89.webwatcher/icons/";
            _iconImage = new Granite.AsyncImage ();
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
                        case "icon":
                            this.icon = val.to_text ();
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
                            this.updated_dt = val.to_int64 ();
                            break;
                        case "icon_updated_dt":
                            this.icon_updated_dt = val.to_int64 ();
                            break;
                    }
                }
            }

            var iconFile = File.new_for_path (this._iconDir + this.icon);
            if (this.icon != null && !iconFile.query_exists ()) {
                this.icon = null;
                this.icon_updated_dt = 0;
                this.save ();
            }

            this.update_icon ();

            return loaded;
        }

        public override bool save () {
            var sql = "";
            var state = SiteEvent.ADDED;

            // Update SQL
            if (id > 0) {
                state = SiteEvent.UPDATED;
                sql = """
                    UPDATE `sites` SET
                        `url` = $URL,
                        `description` = $DESCRIPTION,
                        `title` = $TITLE,
                        `icon` = $ICON,
                        `response` = $RESPONSE,
                        `active` = $ACTIVE,
                        `order` = $ORDER,
                        `status` = $STATUS,
                        `notify` = $NOTIFY,
                        `updated_dt` = $UPDATED_DT,
                        `icon_updated_dt` = $ICON_UPDATED_DT
                    WHERE
                        `id` = $ID
                """;
            }

            // Insert SQL
            else {
                sql = """
                    INSERT INTO `sites` (`url`, `description`, `active`, `order`, `status`, `notify`)
                    VALUES ($URL, $DESCRIPTION, $ACTIVE, $ORDER, $STATUS, $NOTIFY)
                """;
            }

            var statement = this.db.Prepare (sql);

            this.updated_dt = (new DateTime.now_utc ()).to_unix ();

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
            this.db.bind_int64 (statement, "$UPDATED_DT", updated_dt);
            this.db.bind_int64 (statement, "$ICON_UPDATED_DT", icon_updated_dt);

            if (!this.db.ExecuteStatement (statement)) {
                return false;
            }

            if (state == SiteEvent.ADDED) {
                this.id = (int)this.db.LastID ();
            }

            this.update_icon ();
            this.changed (this, state);
            return true;
        }

        public override bool delete () {
            var siteStatement = this.db.Prepare ("DELETE FROM `sites` WHERE id = $ID");
            var resultsStatement = this.db.Prepare ("DELETE FROM `results` WHERE site_id = $ID");

            this.db.bind_int (siteStatement, "$ID", id);
            this.db.bind_int (resultsStatement, "$ID", id);

            this.db.ExecuteStatement (siteStatement);
            this.db.ExecuteStatement (resultsStatement);

            this.changed (this, SiteEvent.DELETED);
            return false;
        }

        public void run () {
            if (this.running) {
                return;
            }

            if (!this.active) {
                this.running = false;
                return;
            }

            var time = (new DateTime.now_utc ()).to_unix ();
            if (this.status == "good" && time - this.updated_dt < 60) {
                return;
            }
            else if (this.status != "good" && time - this.updated_dt < 10) {
                return;
            }

            this.running = true;

            var titleRegex = new Regex ("""\<title[a-z \-]*\>(.+)\<\/title\>""", RegexCompileFlags.CASELESS);
            var message = new Soup.Message ("GET", this.url);
            var timer = new Timer ();
            session.queue_message (message, (ses, response) => {
                timer.stop ();

                var currentTime = (new DateTime.now_utc ()).to_unix ();
                var data = (string) response.response_body.data ?? "";
                var statusCode = response.status_code;

                // Timer is in seconds - multiple by 1000 to get MS, the cast to int to drop remainder
                this.response = (int)(timer.elapsed () * 1000);

                // Update the status based on the status code value (200 is usually expected)
                if (statusCode >= 200 && statusCode < 300 && this.response < 30000) {
                    if (this.status == "bad") {
                        this.changed (this, SiteEvent.ONLINE);
                    }

                    this.status = "good";
                    this.failures = 0;
                }

                // Permanent redirect - update our link to it
                else if (statusCode == 308) {
                    var headers = response.response_headers;
                    this.url = headers.get_one ("Location");
                }

                else if (this.status == "bad") {}

                // 30 second timeout should be considered an offline situation
                else if (this.response >= 30000) {
                    this.failures = 3;
                }

                // 300+ is redirect, 400+ are user/permission errors, 500+ are server errors
                else {
                    this.status = "warning";
                    this.failures++;
                }

                // After 5 failed attempts, display a notification if enabled
                if (this.failures >= 3 && this.status != "bad") {
                    this.status = "bad";
                    this.changed (this, SiteEvent.OFFLINE);
                }

                // Attempt to parse out <title> tag
                MatchInfo match;
                if (titleRegex.match (data, 0, out match)) {
                    this.title = App.Utils.StringUtil.html_entity_decode (match.fetch (1) ?? "").strip ();
                }

                new ResultModel.with_details (this.id, this.response, (int)statusCode, this.status);

                this.running = false;
                this.save ();

                // If everything is good and the last time we updated the icon was more than 5 minutes ago, fetch a new icon
                if (this.status == "good" && currentTime - this.icon_updated_dt > 300) {
                    this.fetching_icon = false;  // if it's still running after 5 minutes just let it run again
                    this.fetch_icon ();
                }
            });
        }

        public void fetch_icon () {
            if (this.fetching_icon) {
                return;
            }

            info ("Fetching updated icon for " + this.url);
            this.fetching_icon = true;

            var currentTime = (new DateTime.now_utc ()).to_unix ();
            var message = new Soup.Message ("GET", "https://favicongrabber.com/api/grab/" + this.url.replace ("http://", "").replace ("https://", ""));

            session.queue_message (message, (ses, response) => {
                try {
                    if (response.status_code > 200) {
                        this.fetching_icon = false;
                        this.icon_updated_dt = currentTime - 60; // try again in a minute
                        this.save ();
                        return;
                    }

                    var node = Json.from_string ((string) response.response_body.data);
                    var obj = node.get_object ();

                    if (obj.has_member ("error")) {
                        this.fetching_icon = false;
                        this.icon_updated_dt = currentTime;
                        this.save ();
                        return;
                    }

                    var url = "";
                    var icons = obj.get_array_member ("icons");
                    if (icons.get_length () == 1) {
                        var icon = icons.get_element (0);
                        var iconObj = icon.get_object ();
                        url = iconObj.get_string_member ("src");
                    }
                    else {
                        var size = 0;

                        foreach (unowned Json.Node icon in icons.get_elements ()) {
                            var iconObj = icon.get_object ();

                            if (url == "") {
                                url = iconObj.get_string_member ("src");
                            }

                            if (size == 0 && iconObj.has_member ("type") && iconObj.get_string_member ("type") == "image/x-icon") {
                                url = iconObj.get_string_member ("src");
                            }

                            if (iconObj.has_member ("sizes")) {
                                string sizeString = iconObj.get_string_member ("sizes");
                                int64 iconSize;

                                if (!int64.try_parse (sizeString.substring (sizeString.index_of ("x") + 1), out iconSize)) {
                                    continue;
                                }

                                if (iconSize > size) {
                                    size = (int)iconSize;
                                    url = iconObj.get_string_member ("src");
                                }
                            }
                        }
                    }

                    download_icon (url);
                }
                catch (Error error) {
                }
            });
        }

        public void download_icon (string url) {
            if (url == null || url == "") {
                this.fetching_icon = false;
                this.icon_updated_dt = (new DateTime.now_utc ()).to_unix ();
                this.save ();
                return;
            }

            var type = url.substring (-3, 3);

            var currentTime = (new DateTime.now_utc ()).to_unix ();
            var message = new Soup.Message ("GET", url);
            var name = this.id.to_string () + "." + type;

            session.queue_message (message, (ses, response) => {
                if (response.status_code > 200) {
                    this.fetching_icon = false;
                    this.icon_updated_dt = currentTime - 60; // try again in a minute
                    this.save ();
                    return;
                }

                var data = response.response_body.data;

                try {
                    var file = File.new_for_path (_iconDir + name);
                    var outputStream = file.replace (null, false, FileCreateFlags.NONE);
                    var dataOutputStream = new DataOutputStream (outputStream);

                    long written = 0;
                    while (written < data.length) {
                        written += dataOutputStream.write (data[written:data.length]);
                    }

                    this.fetching_icon = false;

                    this.icon = name;
                    this.icon_updated_dt = (new DateTime.now_utc ()).to_unix ();
                    this.save ();
                }
                catch (Error error) {
                    warning ("Unable to save icon " + name);
                }
            });
        }

        private void update_icon () {
            var iconFile = this.get_icon_file ();
            if (iconFile != null) {
                this._iconImage.set_from_file_async.begin (iconFile, 32, 32, true);
            }
            else {
                this._iconImage.set_from_icon_name_async.begin ("www", Gtk.IconSize.DND);
            }
        }

        public Granite.AsyncImage get_icon_image () {
            return this._iconImage;
        }

        public File? get_icon_file () {
            if (this.icon == null) {
                return null;
            }

            var iconFile = File.new_for_path (this._iconDir + this.icon);
            if (iconFile.query_exists ()) {
                return iconFile;
            }

            return null;
        }
    }

}
