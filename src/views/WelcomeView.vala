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
     * The {@code WelcomeView} class.
     *
     * @since 1.0.0
     */
	public class WelcomeView : Gtk.Viewport {

		/**
         * Constructs a new {@code WelcomeView} object.
         */
		public WelcomeView () {
            var welcome = new Granite.Widgets.Welcome (_("Start monitoring your sites"), _("Add a new site to begin"));
            this.add (welcome);
        }
	}
}
