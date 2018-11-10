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

namespace App.Models {

    /**
     * The {@code BaseModel} class.
     *
     * @since 1.0.0
     */
    public abstract class BaseModel {

        protected unowned App.Database.DB db { get { return App.Database.DB.GetInstance (); } }

        public abstract bool get (int id);
        public abstract bool load (Sqlite.Statement statement);
        public abstract bool save ();
        public abstract bool delete ();
    }

}
