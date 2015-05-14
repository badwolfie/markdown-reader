# configure.ac

AC_INIT([markdown-reader],[0.9.7])
AC_CONFIG_SRCDIR([src/markdown-reader.vala])
AC_CONFIG_HEADERS([config.h])

# AM_INIT_AUTOMAKE([no-dist-gzip dist-bzip2])
AM_INIT_AUTOMAKE([1.11 no-dist-gzip dist-xz foreign])
GNOME_MAINTAINER_MODE_DEFINES

# Enable silent rules is available
m4_ifdef([AM_SILENT_RULES], [AM_SILENT_RULES([yes])])

AM_MAINTAINER_MODE

AC_PATH_PROG(GLIB_COMPILE_RESOURCES, glib-compile-resources)

AC_PROG_CC
AM_PROG_CC_C_O
AM_PROG_VALAC([0.24])
AC_PROG_INSTALL
IT_PROG_INTLTOOL([0.50.1])

pkg_modules="gtk+-3.0 >= 3.10.0 webkit2gtk-4.0 >= 2.8.2 gee-0.8 >= 0.18.0"
markdown_reader_PACKAGES="--pkg gtk+-3.0 --pkg webkit2gtk-4.0 --pkg gee-0.8 --pkg posix --target-glib 2.32"
PKG_CHECK_MODULES(markdown_reader, [$pkg_modules])
AC_SUBST(markdown_reader_CFLAGS)
AC_SUBST(markdown_reader_LIBS)
AC_SUBST(markdown_reader_PACKAGES)

GETTEXT_PACKAGE=markdown-reader
AC_SUBST(GETTEXT_PACKAGE)
AC_DEFINE_UNQUOTED([GETTEXT_PACKAGE], ["$GETTEXT_PACKAGE"], [GETTEXT_PACKAGE])
AM_GNU_GETTEXT_VERSION([1.11])
AM_GLIB_GNU_GETTEXT

AC_CONFIG_FILES([
	Makefile
	po/Makefile.in
	data/Makefile
	src/Makefile
	vapi/Makefile
])
AC_OUTPUT
