using Gtk;

public class MarkdownReader : Gtk.Application {
	private const string APP_NAME = "Markdown Reader";
	private const string APP_VERSION = "1.1.0";

	private string home_dir = Environment.get_home_dir();
	private MainWindow window;

	private const OptionEntry[] option_entries = {
		{ "version", 'v', 0, 
		  OptionArg.NONE, null, 
		  ("Show release version"), null },
		{ null }
	};
	
	private const GLib.ActionEntry[] app_entries = {
		{ "about", about_cb, null, null, null },
        { "quit", quit_cb, null, null, null },
	};
	
	public MarkdownReader() {
		Object(application_id: "badwolfie.markdown-reader.app",
			   flags: ApplicationFlags.HANDLES_OPEN);
		add_main_option_entries(option_entries);
	}
	
	protected override void startup() {
		base.startup();
		
		var conf_dir = File.new_for_path(home_dir + "/.markdown-reader");
		var tmp_dir = File.new_for_path(home_dir + "/.markdown-reader/tmp");
		var recents = File.new_for_path(home_dir + "/.markdown-reader/recents");

		try {
			if (!conf_dir.query_exists()) conf_dir.make_directory();
			if (!tmp_dir.query_exists()) tmp_dir.make_directory();
			if (!recents.query_exists()) 
				recents.create(FileCreateFlags.PRIVATE);
		} catch (Error e) {
			error("Error loading menu UI: %s",e.message);
		}
		
		add_action_entries(app_entries,this);
		window = new MainWindow(this);
		
		var builder = new Gtk.Builder();
		try {
			builder.add_from_resource(
				"/com/github/badwolfie/markdown-reader/menu.ui");
		} catch (Error e) {
			error("Error loading menu UI: %s",e.message);
		}
		
		var menu = builder.get_object("appmenu") as MenuModel;
		set_app_menu(menu);
	}
	
	protected override void activate() {
		base.activate();
		window.arg_files = null;	
		window.present();
	}
	
	protected override void open(File[] files, string hint) {
		base.open(files, hint);
		
		window.arg_files = files;
		window.present();
	}
	
	protected override void shutdown() {
		base.shutdown();
		Posix.system(
			"rm -f " + home_dir + "/.markdown-reader/tmp/*");
	}

	protected override int handle_local_options(VariantDict options) {
		if (options.contains("version")) {
			stderr.printf("%1$s %2$s\n", APP_NAME, APP_VERSION);
			return Posix.EXIT_SUCCESS;
		}

		return -1;
	}
	
	private void about_cb() {
		const string[] authors = { 
			"Ian Hernández <ihernandezs@openmailbox.org>" 
		};

		// const string[] contributors = {};
		
		// var translator_credits = _("translator-credits");

		string license = 
"""Markdown Reader is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 2 of the License, or
(at your option) any later version.

Markdown Reader is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with Markdown Reader. If not, see <http://www.gnu.org/licenses/>.""";

		var about_dialog = new AboutDialog();
		about_dialog.set_transient_for(window);

        about_dialog.program_name = (APP_NAME);
		about_dialog.title = ("About") + " Markdown Reader";
		about_dialog.copyright = ("Copyright \xc2\xa9 2015 Ian Hernández");
		about_dialog.comments = 
			("A document reader for markdown and html files");
		about_dialog.website = ("https://github.com/BadWolfie/markdown-reader");
		about_dialog.website_label = ("Web page");
		about_dialog.license = license;
		about_dialog.logo_icon_name = ("gnome-documents");
		about_dialog.authors = authors;
		// about_dialog.translator_credits = translator_credits;
		about_dialog.version = (APP_VERSION);

		// about_dialog.add_credit_section(_("Contributors"),contributors);

		about_dialog.run();
		about_dialog.destroy();
	}
	
	private void quit_cb() {
		window.destroy();
	}
	
	public static int main(string[] args) {
		/* Intl.setlocale(LocaleCategory.ALL, "");
        Intl.bindtextdomain(Config.GETTEXT_PACKAGE, Config.LOCALEDIR);
        Intl.bind_textdomain_codeset(Config.GETTEXT_PACKAGE, "UTF-8");
        Intl.textdomain(Config.GETTEXT_PACKAGE); */
        
        Gtk.Window.set_default_icon_name("gnome-documents");
        var app = new MarkdownReader();
        
        return app.run(args);
	}
}
