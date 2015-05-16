bin_PROGRAMS = markdown-reader

AM_CPPFLAGS = \
	-include config.h \
	$(markdown_reader_CFLAGS) \
	-DLOCALEDIR=\""$(localedir)"\" \
	-DPKGDATADIR.=\""$(pkgdatadir)"\" \
	-DPKGLIBDIR=\""$(pkglibdir)"\"

BUILT_SOURCES = resources.c

resources.c: $(top_srcdir)/data/markdown-reader.gresource.xml $(shell $(GLIB_COMPILE_RESOURCES) --generate-dependencies --sourcedir=$(top_srcdir)/data/ $(top_srcdir)/data/markdown-reader.gresource.xml)
	$(AM_V_GEN) $(GLIB_COMPILE_RESOURCES) --target=$@ --sourcedir=$(top_srcdir)/data/ --generate-source $<

markdown_reader_SOURCES = \
	document-tab.vala \
	main-window.vala \
	markdown-reader.vala \
	recent-file-box.vala \
	tab-bar.vala \
	$(BUILT_SOURCES)

markdown_reader_VALAFLAGS = \
	--vapidir=$(srcdir)/../vapi --pkg config \
	@markdown_reader_PACKAGES@

markdown_reader_LDADD = \
	$(markdown_reader_LIBS)
