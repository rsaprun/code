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

    private const ActionEntry[] actions = {
        { "save", on_save },
    };

    public MainWindow (Gtk.Application app) {
        Object (
            application: app,
            title: "Code");
        
        add_action_entries (actions, this);
        app.set_accels_for_action ("win.save", new string[] { "<Control>s" });

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

    private void on_save (SimpleAction action, Variant? parameter) {
        foreach (var tab in notebook.tabs) {
            ((DocumentTab)tab).save ();
        }
    }

    public void open_file (File? file) {
        show_all ();
        add_tab (file);
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
        try {
            FileEnumerator enumerator = directory.enumerate_children ("standard::*",
                FileQueryInfoFlags.NOFOLLOW_SYMLINKS);
            FileInfo info;
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

    private void add_tab (File? file) {
        if (file != null) {
            for (int i = 0; i < notebook.tabs.length (); i++) {
                DocumentTab old_tab = notebook.tabs.nth_data(i) as DocumentTab;
                if (old_tab.file.get_uri () == file.get_uri ()) {
                    notebook.current = old_tab;
                    return;
                }
            }
        }
    
        var new_tab = new DocumentTab (file);
        notebook.insert_tab (new_tab, -1);
        notebook.current = new_tab;
    }
}

