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
    private Gtk.SourceView _source_view;
    private static Gtk.SourceLanguageManager _language_manager;
    
    public File? file {
        get {
            return _file;
        }
        set {
            _file = value;
        }
    }

    static construct {
        _language_manager = Gtk.SourceLanguageManager.get_default ();
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
        create_source_view (contents);
        scroll.add (_source_view);
        this.label = _file_name;
        this.page = scroll;
        
        _source_view.buffer.changed.connect (() => {
            if (_source_view.buffer.get_modified ()) {
                this.label = "\u2219 " + _file_name;
            } else {
                this.label = _file_name;
            }
        });
    }

    private void create_source_view (string contents) {
        var buffer = new Gtk.SourceBuffer (null);
        buffer.undo_manager.begin_not_undoable_action ();
        buffer.set_text (contents);
        buffer.undo_manager.end_not_undoable_action ();
        Gtk.TextIter text_iter;
        buffer.get_start_iter (out text_iter);
        buffer.place_cursor (text_iter);
        buffer.style_scheme = Gtk.SourceStyleSchemeManager.get_default ().get_scheme ("oblivion");
        if (_file != null) {
            try {
                var info = _file.query_info ("standard::*", FileQueryInfoFlags.NONE, null);
                var mime_type = ContentType.get_mime_type (info.get_attribute_as_string (FileAttribute.STANDARD_CONTENT_TYPE));
                buffer.language = _language_manager.guess_language (_file.get_path (), mime_type);
            } catch (Error ex) {
                warning ("Cannot read %s: %s", _file.get_basename (), ex.message);
            }
        }

        _source_view = new Gtk.SourceView.with_buffer (buffer);
        _source_view.auto_indent = true;
        _source_view.highlight_current_line = true;
        _source_view.insert_spaces_instead_of_tabs = true;
        _source_view.monospace = true;
        _source_view.show_line_numbers = true;
        _source_view.smart_backspace = true;
        _source_view.smart_home_end = Gtk.SourceSmartHomeEndType.BEFORE;
        _source_view.tab_width = 4;
    }
    
    private string read_file (File file) {
        try {
            string contents;
            if (FileUtils.get_contents (file.get_path (), out contents)) {
                return contents;
            }
        } catch (FileError ex) {
            warning ("Cannot read %s: %s", file.get_basename (), ex.message);
        }
        return "";
    }

    public void save () {
        if (_file != null) {
            try {
                FileUtils.set_contents (_file.get_path (), _source_view.buffer.text);
                _source_view.buffer.set_modified (false);
                this.label = _file_name;
            } catch (FileError ex) {
                warning ("Cannot write %s: %s", _file.get_basename (), ex.message);
            }
        }
    }
}

