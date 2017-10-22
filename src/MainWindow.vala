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
    public MainWindow (Gtk.Application app) {
        Object (
            application: app,
            title: "Code");
        
        var paned = new Gtk.Paned (Gtk.Orientation.HORIZONTAL);
        paned.set_size_request (800, 600);
        add (paned);
        
        var tree_store = new Gtk.TreeStore (1, typeof (string));
        Gtk.TreeIter iter;
        Gtk.TreeIter folder_iter;
        tree_store.append (out iter, null);
        tree_store.set (iter, 0, "Folder 1");
        tree_store.append (out folder_iter, iter);
        tree_store.set (folder_iter, 0, "File 1");
        tree_store.append (out iter, null);
        tree_store.set (iter, 0, "File 2");
        
        var tree = new Gtk.TreeView.with_model (tree_store);
        tree.can_focus = false;
        tree.headers_visible = false;
        var selection = tree.get_selection ();
        tree.set_size_request (200, -1);
        paned.pack1 (tree, true, true);
        
        var cell = new Gtk.CellRendererText ();
        tree.insert_column_with_attributes (-1, "Name", cell, "text", 0);
        
        var buffer = new Gtk.SourceBuffer (null);
        buffer.style_scheme = Gtk.SourceStyleSchemeManager.get_default ().get_scheme ("oblivion");
        
        var sourceView = new Gtk.SourceView.with_buffer (buffer);
        sourceView.set_size_request (600, -1);
        paned.pack2 (sourceView, true, true);
        sourceView.auto_indent = true;
        sourceView.highlight_current_line = true;
        sourceView.insert_spaces_instead_of_tabs = true;
        sourceView.monospace = true;
        sourceView.show_line_numbers = true;
        sourceView.smart_backspace = true;
        sourceView.smart_home_end = Gtk.SourceSmartHomeEndType.BEFORE;
        sourceView.tab_width = 4;

        selection.changed.connect (() => {
        });
        
        show_all ();
    }
}

