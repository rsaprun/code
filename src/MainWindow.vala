class MainWindow : Gtk.ApplicationWindow {
    private Gtk.SourceView sourceView;

    public MainWindow (Gtk.Application app) {
        Object (
            application: app,
            title: "Code");
        set_size_request (800, 600);
        var buffer = new Gtk.SourceBuffer (null);
        buffer.style_scheme = Gtk.SourceStyleSchemeManager.get_default ().get_scheme ("oblivion");
        sourceView = new Gtk.SourceView.with_buffer (buffer);
        sourceView.auto_indent = true;
        sourceView.highlight_current_line = true;
        sourceView.insert_spaces_instead_of_tabs = true;
        sourceView.monospace = true;
        sourceView.show_line_numbers = true;
        sourceView.smart_backspace = true;
        sourceView.smart_home_end = Gtk.SourceSmartHomeEndType.BEFORE;
        sourceView.tab_width = 4;
        add (sourceView);
        show_all ();
    }
}

