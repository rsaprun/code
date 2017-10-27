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

class MainWindow : Gtk.ApplicationWindow {
    private Gtk.Paned paned;
    private Granite.Widgets.DynamicNotebook notebook;
    private File root_directory;

    public MainWindow (Gtk.Application app) {
        Object (
            application: app,
            title: "Code");

        paned = new Gtk.Paned (Gtk.Orientation.HORIZONTAL);
        paned.set_size_request (800, 600);
        add (paned);

        notebook = new Granite.Widgets.DynamicNotebook ();
        notebook.add_button_visible = false;
        notebook.set_size_request (600, -1);
        paned.pack2 (notebook, true, true);

        notebook.tab_removed.connect (() => {
        });
        
        destroy.connect (() => {
            foreach (var tab in notebook.tabs) {
                tab.close ();
            }
        });
    }
    
    public void open_empty () {
        show_all ();
        var scroll = new Gtk.ScrolledWindow (null, null);
        var source_view = add_source_view ("");
        scroll.add (source_view);
        var tab = new Granite.Widgets.Tab ("New File", null, scroll);
        notebook.insert_tab (tab, -1);
    }
    
    public void open_file (File file) {
        add_tab (file);
        show_all ();
    }
    
    public void open_directory (File directory) {
        root_directory = directory;
        
        var store = new Gtk.TreeStore (1, typeof (string));
        fill_tree_store (directory, store, null);
        
        var tree_scroll = new Gtk.ScrolledWindow (null, null);
        tree_scroll.set_size_request (200, -1);
        var tree = new Gtk.TreeView.with_model (store);
        tree.activate_on_single_click = true;
        tree.can_focus = false;
        tree.headers_visible = false;
        tree_scroll.add (tree);
        paned.pack1 (tree_scroll, true, true);
        
        var cell = new Gtk.CellRendererText ();
        tree.insert_column_with_attributes (-1, "Name", cell, "text", 0);
        
        tree.row_activated.connect ((path, column) => {
            Gtk.TreeIter iter, parent_iter;
            store.get_iter (out iter, path);
            Value val;
            store.get_value (iter, 0, out val);
            string file_path = (string)val;
            while (store.iter_parent (out parent_iter, iter)) {
                iter = parent_iter;
                store.get_value (iter, 0, out val);
                file_path = (string)val + "/" + file_path;
            }
            File file = root_directory.resolve_relative_path (file_path);
            if (file.query_file_type (FileQueryInfoFlags.NONE) == FileType.REGULAR) {
                add_tab (file);
            }
        });
        
        show_all ();
    }
    
    private void fill_tree_store (File directory, Gtk.TreeStore store, Gtk.TreeIter? parent_iter) {
        FileEnumerator enumerator = directory.enumerate_children ("standard::*",
            FileQueryInfoFlags.NOFOLLOW_SYMLINKS);
        FileInfo info;
        try {
            while ((info = enumerator.next_file ()) != null) {
                Gtk.TreeIter iter;
                store.append (out iter, parent_iter);
                store.set (iter, 0, info.get_name ());
                if (info.get_file_type () == FileType.DIRECTORY) {
                    File subdir = directory.resolve_relative_path (info.get_name ());
                    fill_tree_store (subdir, store, iter);
                }
            }
        } catch (Error ex) {
            warning ("Cannot list %s: %s", directory.get_basename(), ex.message);
        }
    }
    
    private void add_tab (File file) {
        string contents;
        try {
            if (FileUtils.get_contents (file.get_path (), out contents)) {
                var scroll = new Gtk.ScrolledWindow (null, null);
                var source_view = add_source_view (contents);
                scroll.add (source_view);
                var tab = new Granite.Widgets.Tab (file.get_basename (), null, scroll);
                notebook.insert_tab (tab, -1);
                notebook.current = tab;
            }
        } catch (FileError ex) {
            warning ("Cannot read %s: %s", file.get_basename(), ex.message);
        }
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
}

