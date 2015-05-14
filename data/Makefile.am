desktopdir = $(datadir)/applications
desktop_in_files = markdown-reader.desktop.in
desktop_DATA = $(desktop_in_files:.desktop.in=.desktop)
@INTLTOOL_DESKTOP_RULE@

EXTRA_DIST = \
	menu.ui \
	simple-text.gresource.xml \
	$(desktop_in_files) \
	$(gsettings_SCHEMAS)

CLEANFILES = \
	$(desktop_DATA)
