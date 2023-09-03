const std = @import("std");
const gtk = @cImport(@cInclude("gtk/gtk.h"));

fn print_hello(_: *gtk.GtkWidget, _: gtk.gpointer) void {
    gtk.g_print("Hello World\n");
}

fn quit_cb(window: *gtk.GtkWindow) void {
    gtk.gtk_window_close(window);
}

fn activate(app: *gtk.GtkApplication, _: *gtk.gpointer) void {
    const src = @embedFile("data/builder.ui");
    const builder = gtk.gtk_builder_new_from_string(src, -1);
    const window: *gtk.GtkWindow = @ptrCast(gtk.gtk_builder_get_object(builder, "window"));
    gtk.gtk_window_set_application(window, @ptrCast(app));
    var button: *gtk.GtkButton = @ptrCast(gtk.gtk_builder_get_object(builder, "button1"));
    // can't use g_signal_connect (C macro)
    _ = gtk.g_signal_connect_data(@ptrCast(button), "clicked", @ptrCast(&print_hello), null, null, 0);
    button = @ptrCast(gtk.gtk_builder_get_object(builder, "button2"));
    _ = gtk.g_signal_connect_data(@ptrCast(button), "clicked", @ptrCast(&print_hello), null, null, 0);
    button = @ptrCast(gtk.gtk_builder_get_object(builder, "quit"));
    _ = gtk.g_signal_connect_data(@ptrCast(button), "clicked", @ptrCast(&quit_cb), window, null, gtk.G_CONNECT_SWAPPED);
    gtk.gtk_widget_show(@ptrCast(window));
}
pub fn main() !void {
    const app: *gtk.GtkApplication = gtk.gtk_application_new("org.gtk.example", gtk.G_APPLICATION_DEFAULT_FLAGS);
    defer gtk.g_object_unref(app);
    _ = gtk.g_signal_connect_data(app, "activate", @ptrCast(&activate), null, null, 0);
    const status = gtk.g_application_run(@ptrCast(app), 0, null);
    std.process.exit(if (status > 0) 1 else 0);
}
