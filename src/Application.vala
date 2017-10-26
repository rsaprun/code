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
    construct {
        application_id = "com.github.rsaprun.code";
        flags = ApplicationFlags.HANDLES_OPEN;
    }

    protected override void activate () {
        var app_window = new MainWindow (this);
        app_window.open_empty ();
        app_window.show ();
    }

    public static int main (string[] args) {
        return new Application ().run (args);
    }
    
    public override void open (File[] files, string hint) {
        Gtk.MessageDialog dialog;
        MainWindow app_window;
        foreach (var file in files) {
            switch (file.query_file_type (FileQueryInfoFlags.NONE)) {
                case FileType.UNKNOWN:
                    dialog = new Gtk.MessageDialog (null, Gtk.DialogFlags.MODAL,
                        Gtk.MessageType.ERROR, Gtk.ButtonsType.OK, "Cannot open '%s'", file.get_basename ());
                    dialog.response.connect (Gtk.main_quit);
                    dialog.show ();
                    Gtk.main ();
                    break;
                case FileType.REGULAR:
                    app_window = new MainWindow (this);
                    app_window.open_file (file);
                    app_window.show ();
                    break;
                case FileType.DIRECTORY:
                    stdout.printf("d %s\n", file.get_uri ());
                    break;
            }
        }
    }
}

