using Gtk;

public class MainWindow : ApplicationWindow {
	private HeaderBar headerbar;
	private TabBar tab_bar;
	private Stack documents;
	private Separator separator;
	
	private List<string> opened_files;
	private int counter = 0;
	
	private File[] _arg_files = null;
	public File[] arg_files {
		set {
			_arg_files = value;

			if (_arg_files != null) {
				foreach (var file in _arg_files) 
					add_new_tab_from_file(file.get_path());
			}
		}
	}
	
	public MainWindow(Gtk.Application app) {
		Object(application: app);
		opened_files = new List<string>();
		
		window_position = WindowPosition.CENTER_ALWAYS;
		set_default_size(700,600);
		border_width = 0;
		
		create_widgets();
	}
	
	private void create_widgets() {
		headerbar = new HeaderBar();
		headerbar.set_show_close_button(true);
			
		this.set_titlebar(headerbar);
		headerbar.set_title("Markdown Reader");
		headerbar.show();
	
		var prev_tab_button = new Button.from_icon_name(
			"go-previous-symbolic",IconSize.MENU);
		prev_tab_button.set_tooltip_text(("Previous tab") + " (Ctrl+PageUp)");
		prev_tab_button.show();
		
		var next_tab_button = new Button.from_icon_name(
			"go-next-symbolic",IconSize.MENU);
		next_tab_button.set_tooltip_text(("Next tab") + " (Ctrl+PageDown)");
		next_tab_button.show();
		
		var open_button = new Button.from_icon_name(
			"document-open-symbolic",IconSize.MENU);
		open_button.set_tooltip_text(("Open file") + " (Ctrl+O)");
		open_button.show();
		
		var refresh_button = new Button.from_icon_name(
			"view-refresh-symbolic",IconSize.MENU);
		refresh_button.set_tooltip_text(("Refresh document") + " (Ctrl+R)");
		refresh_button.show();
		
		prev_tab_button.clicked.connect(prev_tab_cb);
		next_tab_button.clicked.connect(next_tab_cb);
		open_button.clicked.connect(open_file_cb);
		refresh_button.clicked.connect(page_refresh_cb);
		
		var accels = new AccelGroup();
		this.add_accel_group(accels);
		open_button.add_accelerator("activate",accels,Gdk.Key.O,
			Gdk.ModifierType.CONTROL_MASK,AccelFlags.VISIBLE);
		prev_tab_button.add_accelerator("activate",accels,Gdk.Key.Page_Up,
			Gdk.ModifierType.CONTROL_MASK,AccelFlags.VISIBLE);
		next_tab_button.add_accelerator("activate",accels,Gdk.Key.Page_Down,
			Gdk.ModifierType.CONTROL_MASK,AccelFlags.VISIBLE);
		refresh_button.add_accelerator("activate",accels,Gdk.Key.R,
			Gdk.ModifierType.CONTROL_MASK,AccelFlags.VISIBLE);
			
		headerbar.pack_start(prev_tab_button);
		headerbar.pack_start(next_tab_button);
		headerbar.pack_start(open_button);
		headerbar.pack_end(refresh_button);
		
		documents = new Stack();
		documents.set_transition_type(StackTransitionType.OVER_LEFT_RIGHT);
		documents.set_transition_duration(250);
		documents.show();
			
		tab_bar = new TabBar();
		tab_bar.set_stack(documents);
		tab_bar.page_closed.connect(on_page_close);
	
		separator = new Separator(Orientation.HORIZONTAL);
		
		var content = new Box(Orientation.VERTICAL,0);
		content.pack_start(tab_bar,false,true,7);
		content.pack_start(separator,false,true,0);
		content.pack_start(documents,true,true,0);
		content.show();
		
		welcome_msg();
		add(content);
	}
	
	private void welcome_msg() {
		var l1 = new Label("<big><b>" + ("Welcome!") + "</b></big>");
		var l2 = new Label(("Markdown Reader allows you to easily read")); 
		var l3 = new Label(("the content of your markdown and html files."));
		l1.use_markup = true;
		
		var l4 = new Label(("Click the"));
		var l5 = new Label(("button to open a file..."));
		var open = new Image.from_icon_name("document-open-symbolic",
											IconSize.MENU);
		var hbox = new Box(Orientation.HORIZONTAL,0);
		hbox.pack_start(l4,false,false,0);
		hbox.pack_start(open,false,false,5);
		hbox.pack_start(l5,false,false,0);
		hbox.halign = Align.CENTER;
		
		var box = new Box(Orientation.VERTICAL,0);
		box.pack_start(l1,false,true,10);
		box.pack_start(l2,false,true,0);
		box.pack_start(l3,false,true,0);
		box.pack_start(hbox,false,true,15);
		box.show_all();
		
		documents.add_named(box,"welcome"); 
	}
	
	private void open_file_cb() {
		var file_chooser = new FileChooserDialog(("Open File"), this,
			FileChooserAction.OPEN,
			("Cancel"), ResponseType.CANCEL,
			("Open"), ResponseType.ACCEPT
		);

		file_chooser.set_current_folder(Environment.get_home_dir());
		file_chooser.select_multiple = true;
		if (file_chooser.run() == ResponseType.ACCEPT) {
			var file_names = file_chooser.get_filenames();
			file_chooser.destroy();
			
			file_names.foreach((entry) => {
				add_new_tab_from_file((string) entry);
			});
		}
		
		if (file_chooser != null) 
			file_chooser.destroy();
	}
	
	private void add_new_tab_from_file(string file_name) {
		if (file_is_opened(file_name)) return;
		
		if (!file_name.contains(".html") && !file_name.contains(".md")) {
			var dialog = new Dialog.with_buttons(("Error"),this,
				DialogFlags.MODAL,("Accept"),ResponseType.ACCEPT,null);
				
			var ns_filetype = new Label(("This file type is not supported!"));
			ns_filetype.show();
			
			var content = dialog.get_content_area() as Box;
			content.pack_start(ns_filetype,true,true,10);
			dialog.border_width = 10;
			
			dialog.run();
			dialog.destroy();
			return;
		}
		
		tab_bar.show();
		separator.show();
		var tab_title = "tab - %d".printf(counter++);
		
		var tab = new DocumentTab(Path.get_basename(file_name),file_name);
		// tab.view_drag_n_drop.connect(add_new_tab_from_file);
		
		documents.add_named(tab.tab_widget,tab_title);
		tab_bar.add_page(tab,true);
		
		var current_page = tab_bar.get_current_page(
			documents.visible_child);
		int page_num = tab_bar.get_page_num(current_page);

		opened_files.insert(file_name,page_num);
	}
	
	private bool file_is_opened(string needle) {
		for (int i = 0; i < opened_files.length(); i++) {
			if (needle == opened_files.nth_data(i)) return true;
		}
		
		return false;
	}

	private void on_page_close(DocumentTab? tab, int page_num) {
		opened_files.remove(opened_files.nth_data(page_num));
		
		tab_bar.switch_page_next(tab);
		tab.tab_widget.destroy();
		tab.destroy();

		if (tab_bar.tab_num == 0)
			separator.hide();
		else
			tab_bar.get_current_page(documents.visible_child).mark_title();
	}
	
	private void page_refresh_cb() {
		var current_page = tab_bar.get_current_page(
			documents.visible_child);
		if (current_page != null) 
			current_page.load_file();
	}

	private void next_tab_cb() {
		var current_page = tab_bar.get_current_page(documents.visible_child);
		if (current_page != null) 
			tab_bar.switch_page_next(current_page);
	}

	private void prev_tab_cb() {
		var current_page = tab_bar.get_current_page(documents.visible_child);
		if (current_page != null) 
			tab_bar.switch_page_prev(current_page);
	}
}
