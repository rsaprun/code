/*
* Copyright (c) 2017 Roman Saprun (https://github.com/rsaprun)
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
* Authored by: Roman Saprun <rsaprun@gmail.com>
*/

class Application : Gtk.Application {
    public Application () {
        Object (
            application_id: "com.github.rsaprun.code",
            flags: ApplicationFlags.FLAGS_NONE);
    }

    protected override void activate () {
        var app_window = new Gtk.ApplicationWindow (this);
        app_window.title = "Code";
        app_window.show_all ();
        app_window.show ();
    }

    public static int main (string[] args) {
        return new Application ().run (args);
    }
}

