using Gtk;

public class TabBar : Box {
	public signal void page_closed(DocumentTab tab, int page_num);
	public signal void page_switched(DocumentTab tab);

	private int tab_extra_num = 0;
	public int tab_num = 0;
	private Stack stack;

	private Box extra_box;
	private EventBox extra_menu;
	private Popover extra_popup;
	private Label extra_label;

	private List<DocumentTab> _extra_tabs;
	public List<DocumentTab> extra_tabs {
		get { return _extra_tabs; }
	}

	private List<DocumentTab> _tabs;
	public List<DocumentTab> tabs {
		get { return _tabs; }
	}

	public TabBar() {
		Object();
		orientation = Orientation.HORIZONTAL;
		spacing = 0;
		create_widgets();
	}

	private void create_widgets() {
		_tabs = new List<DocumentTab>();
		_extra_tabs = new List<DocumentTab>();
		
		extra_box = new Box(Orientation.VERTICAL,0);
		var extra_menu_img = new Image.from_icon_name(
			"view-list-symbolic",IconSize.MENU);

		extra_label = new Label("");
		extra_label.use_markup = true;
		
		extra_menu = new EventBox();
		extra_menu.set_above_child(true);

		var box = new Box(Orientation.HORIZONTAL, 3);
		box.pack_start(extra_menu_img, true, true, 0);
		box.pack_start(extra_label, true, true, 0);
		extra_menu.child = box;

		extra_menu.button_press_event.connect((event) => {
			if (extra_popup.get_visible())
				extra_popup.hide();
			else
				extra_popup.show_all();

			return true;
		});

		extra_popup = new Popover(extra_menu);		
		pack_end(extra_menu,false,true,3);
		extra_popup.width_request = 320;
		extra_popup.add(extra_box);
		
		show_all();
		extra_menu.hide();
	}

	public void set_stack(Stack stack) {
		this.stack = stack;
	}

	public void add_page(DocumentTab tab, bool new_page) {
		if (tab_num < 5) {
			if (tab_extra_num == 0) extra_menu.hide();
			pack_start(tab,true,true,5);
			_tabs.append(tab);
			tab_num++;
		} else {
			extra_menu.show();
			extra_box.pack_start(tab,false,true,7);
			_extra_tabs.append(tab);
			tab_extra_num++;
			
			extra_menu.set_tooltip_text(
				_("Hidden tabs: %d").printf(tab_extra_num));
				
			int label_timeout = 0;
			GLib.Timeout.add(250, () => {
				switch (label_timeout) {
					case 0:
						extra_label.label = "<b>+1 </b>";
						break;
					case 1:
						extra_label.label = "<b>%d </b>".printf(tab_extra_num);
						return false;
				}
			
				label_timeout++;
				return true;
			});
		}
		
		tab.close_clicked.connect(close_page);
		tab.tab_clicked.connect(switch_page);

		if (new_page) switch_page(tab, new_page);
	}

	public void switch_page(DocumentTab tab, bool new_page) {
		if ((_extra_tabs.index(tab) != -1) && !new_page)
			extra_popup.show_all();
		else
			extra_popup.hide();
			
		stack.set_visible_child(tab.tab_widget);
		refresh_marked();
		tab.mark_title();

		page_switched(tab);
	}

	public DocumentTab? get_current_page(Widget? current_doc) {
		DocumentTab? current_tab = null;
		if (current_doc != null) {
			for (int i = 0; i < _tabs.length(); i++) {
				if (_tabs.nth_data(i).tab_widget == current_doc)
					current_tab = _tabs.nth_data(i);
			}

			if (current_tab == null) {
				for (int i = 0; i < _extra_tabs.length(); i++) {
					if (_extra_tabs.nth_data(i).tab_widget == current_doc)
						current_tab = _extra_tabs.nth_data(i);
				}
			}
		}

		return current_tab;
	}

	public void switch_page_next(DocumentTab current_tab, bool new_page) {
		if (_tabs.index(current_tab) != -1) {
			if (current_tab == _tabs.last().data) {
				if (tab_extra_num > 0)
					switch_page(_extra_tabs.first().data, new_page);
				else
					switch_page(_tabs.first().data, new_page);
			} else {
				var tab = _tabs.nth_data(_tabs.index(current_tab) + 1);
				switch_page(tab, new_page);
			}
		} else if (_extra_tabs.index(current_tab) != -1) {
			if (current_tab == _extra_tabs.last().data)
				switch_page(_tabs.first().data, new_page);
			else {
				var tab = _extra_tabs.nth_data(
					_extra_tabs.index(current_tab) + 1);
				switch_page(tab, new_page);
			}
		}
	}

	public void switch_page_prev(DocumentTab current_tab, bool new_page) {
		if (_tabs.index(current_tab) != -1) {
			if (current_tab == _tabs.first().data) {
				if (tab_extra_num > 0)
					switch_page(_extra_tabs.last().data, new_page);
				else
					switch_page(_tabs.last().data, new_page);
			} else {
				var tab = _tabs.nth_data(_tabs.index(current_tab) - 1);
				switch_page(tab, new_page);
			}
		} else if (_extra_tabs.index(current_tab) != -1) {
			if (current_tab == _extra_tabs.first().data)
				switch_page(_tabs.last().data, new_page);
			else {
				var tab = _extra_tabs.nth_data(
					_extra_tabs.index(current_tab) - 1);
				switch_page(tab, new_page);
			}
		}
	}

	public void close_page(DocumentTab? tab) {
		int page_num = -1;
		if (tab != null) {
			page_num = get_page_num(tab);
			if (_tabs.index(tab) != -1) {
				_tabs.remove(tab);
				tab_num--;

				if (tab_extra_num > 0) {
					var aux_tab = _extra_tabs.first().data;
					extra_box.remove(aux_tab);
					add_page(aux_tab,false);

					_extra_tabs.remove(aux_tab);
					tab_extra_num--;	
				}
			} else if (_extra_tabs.index(tab) != -1) {
				_extra_tabs.remove(tab);
				tab_extra_num--;
				
				extra_menu.set_tooltip_text(
					_("Hidden tabs: %d").printf(tab_extra_num));
			
				int label_timeout = 0;
				GLib.Timeout.add(250, () => {
					switch (label_timeout) {
						case 0:
							extra_label.label = "<b>-1 </b>";
							break;
						case 1:
							extra_label.label = "<b>%d </b>".printf(tab_extra_num);
							return false;
					}
				
					label_timeout++;
					return true;
				});
			}
		}

		if ((tab_extra_num == 0) && (tab_num <= 5))
			extra_menu.hide();
		page_closed(tab,page_num);
	}

	private void refresh_marked() {
		_tabs.foreach((entry) => {
			(entry as DocumentTab).refresh_title();
		});

		_extra_tabs.foreach((entry) => {
			(entry as DocumentTab).refresh_title();
		});
	}

	public int get_page_num(DocumentTab tab) {
		if (_extra_tabs.index(tab) != -1)
			return (_extra_tabs.index(tab) + (int)_tabs.length());
		return _tabs.index(tab);
	}
}
