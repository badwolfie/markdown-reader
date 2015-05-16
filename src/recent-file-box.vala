using Gtk;

public class RecentFileBox : EventBox {
	public signal void recent_file_clicked(string filename);

	private string filename;
	private Label file_label;
	private Frame file_frame;
	private Image file_img;
	private Box file_box;
	
	public RecentFileBox(string filename) {
		Object();
		this.filename = filename;
		create_widgets();
	}
	
	private void create_widgets() {
		string file_icon = "text-x-generic";
		if (filename.contains(".html")) file_icon = "text-html";
		
		file_img = new Image.from_icon_name(file_icon, IconSize.DIALOG);
		file_label = new Label(Path.get_basename(filename));
		file_label.ellipsize = Pango.EllipsizeMode.END;
		file_label.width_chars = 20;
		
		file_box = new Box(Orientation.VERTICAL, 10);
		file_frame = new Frame(null);
		
		file_box.pack_start(file_img,false,true,5);
		file_box.pack_start(file_label,false,true,5);
		file_box.border_width = 10;
		file_frame.add(file_box);
		
		button_press_event.connect(clicked_action);
		set_above_child(true);
		child = file_frame;
		show_all();
	}
	
	private bool clicked_action(Gdk.EventButton evt) {
		recent_file_clicked(filename);
		return true;
	}
}
