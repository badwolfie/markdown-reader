using Gtk;
using WebKit;

public class DocumentTab : Box {
	// public signal void view_drag_n_drop(string file_name);

	public signal void close_clicked (DocumentTab tab);
	public signal void tab_clicked (DocumentTab tab, bool new_page);
	public signal void tab_focused (DocumentTab tab);

	private WebView _web_view;
	public WebView web_view {
		get { return _web_view; }
	}

	private EventBox evt_box;
	private Label title_label;
	private EventBox close_button;
	private string filename;

	private ScrolledWindow _tab_widget;
	public ScrolledWindow tab_widget {
		get { return _tab_widget; }
	}

	private string _tab_title;
	public string tab_title {
		get { return _tab_title; }
		set {
			if(_tab_title == value)
				return;
			_tab_title = value;

			refresh_title();
		}
	}

	public DocumentTab(string base_name, string file_path) {
		Object();
		tab_title = base_name;
		filename = file_path;
		width_request = 150;
		create_widgets();
	}

	private void create_widgets() {
		orientation = Orientation.HORIZONTAL;
		spacing = 0;
		
		title_label = new Label(tab_title);
		var close_img = new Image.from_icon_name("window-close-symbolic",
			IconSize.MENU);
		title_label.ellipsize = Pango.EllipsizeMode.END;
		title_label.max_width_chars = 10;
		title_label.width_chars = 10;
		
		close_button = new EventBox();
		close_button.child = close_img;
		close_button.set_above_child(true);
		close_button.button_press_event.connect(button_clicked);
		
		evt_box = new EventBox();
		evt_box.child = title_label;
		evt_box.set_above_child(true);
		evt_box.button_press_event.connect(tab_clicked_action);

		pack_start(evt_box,true,true,0);
		pack_start(close_button,false,true,0);

		_web_view = new WebView();
		// _web_view.drag_n_drop.connect(on_drag_n_drop);
		_web_view.show();

		_tab_widget = new ScrolledWindow(null,null);
		_tab_widget.set_policy(PolicyType.AUTOMATIC,PolicyType.AUTOMATIC);
		_tab_widget.add(_web_view);
		_tab_widget.show();
	
		load_file();
		show_all();
	}

	/* private void on_drag_n_drop(string file_name) {
		view_drag_n_drop(file_name);
	} */
	
	public void load_file() {
		if (filename.contains(".html")) {
			_web_view.load_uri("file://" + filename);
			return;
		}
		
		string prefix = Environment.get_home_dir() + "/.markdown-reader/tmp";
		string html_filename = "%s/%s.html".printf(
			prefix,Path.get_basename(filename));
		
		string html_header = "<!DOCTYPE html><html><head>";
		html_header += "<meta http-equiv=\"Content-Type\"";
		html_header += "content=\"text/html; charset=UTF-8\">";
		html_header += "</head><body>";
		
		Posix.system("echo '" + html_header + "' > \"" + html_filename + "\"");
		Posix.system(
			"markdown_py \"" + filename + "\" >> \"" + html_filename + "\"");
		Posix.system("echo '</body></html>' >> \"" + html_filename + "\"");
		
		_web_view.load_uri("file://" + html_filename);
	}

	public void refresh_title() {
		if(title_label != null) {
			title_label.use_markup = false;
			title_label.label = tab_title;
		}
	}

	private bool button_clicked(Gdk.EventButton evt) {
		this.close_clicked(this);
		return true;
	}

	private bool tab_clicked_action(Gdk.EventButton evt) {
		this.tab_clicked(this, false);
		mark_title();
		return true;
	}

	public void mark_title() {
		title_label.use_markup = true;
		title_label.label = "<b><u>" + tab_title + "</u></b>";
	}
}
