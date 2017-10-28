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

class DocumentTab : Granite.Widgets.Tab {
    private string _file_name;
    private File? _file;
    
    public File? file {
        get {
            return _file;
        }
        set {
            _file = value;
        }
    }

    public DocumentTab (File? file) {
        _file = file;
        var scroll = new Gtk.ScrolledWindow (null, null);
        string contents;
        if (file == null) {
            _file_name = "New File";
            contents = "";
        } else {
            _file_name = file.get_basename ();
            contents = read_file (file);
        }
        var source_view = add_source_view (contents);
        scroll.add (source_view);
        this.label = _file_name;
        this.page = scroll;
        
        source_view.buffer.changed.connect (() => {
            if (source_view.buffer.get_modified ()) {
                this.label = "\u2219 " + _file_name;
            } else {
                this.label = _file_name;
            }
        });
    }

    private Gtk.SourceView add_source_view (string contents) {
        var buffer = new Gtk.SourceBuffer (null);
        buffer.set_text (contents);
        buffer.style_scheme = Gtk.SourceStyleSchemeManager.get_default ().get_scheme ("oblivion");

        var source_view = new Gtk.SourceView.with_buffer (buffer);
        source_view.auto_indent = true;
        source_view.highlight_current_line = true;
        source_view.insert_spaces_instead_of_tabs = true;
        source_view.monospace = true;
        source_view.show_line_numbers = true;
        source_view.smart_backspace = true;
        source_view.smart_home_end = Gtk.SourceSmartHomeEndType.BEFORE;
        source_view.tab_width = 4;
        
        return source_view;
    }
    
    private string read_file (File file) {
        try {
            string contents;
            if (FileUtils.get_contents (file.get_path (), out contents)) {
                return contents;
            }
        } catch (FileError ex) {
            warning ("Cannot read %s: %s", file.get_basename(), ex.message);
        }
        return "";
    }
}

