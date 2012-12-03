# $URL$
# $Id$

#######################################################################
# Default compilation parameters. Normally don't edit these           #
#######################################################################

srcdir      ?= .

DEFINES     := -DHAVE_CONFIG_H
LDFLAGS     :=
INCLUDES    := -I. -I$(srcdir)
LIBS        :=
OBJS        :=
DEPDIR      := .deps

MODULES     :=
MODULE_DIRS :=

STANDALONE  :=
# This one will go away once all tools are converted
NO_MAIN     := -DEXPORT_MAIN


# Load the make rules generated by configure
-include config.mk

ifeq "$(HAVE_GCC)" "1"
	CXXFLAGS:= -Wall $(CXXFLAGS)
	# Turn off some annoying and not-so-useful warnings
	CXXFLAGS+= -Wno-long-long -Wno-multichar -Wno-unknown-pragmas -Wno-reorder
	# Enable even more warnings...
	CXXFLAGS+= -Wpointer-arith -Wcast-qual
	CXXFLAGS+= -Wshadow -Wnon-virtual-dtor -Wwrite-strings

	# Currently we disable this gcc flag, since it will also warn in cases,
	# where using GCC_PRINTF (means: __attribute__((format(printf, x, y))))
	# is not possible, thus it would fail compiliation with -Werror without
	# being helpful.
	#CXXFLAGS+= -Wmissing-format-attribute

ifneq "$(HAVE_CLANG)" "1"
	# enable checking of pointers returned by "new", but only when we do not
	# build with clang
	CXXFLAGS+= -fcheck-new
endif
endif

ifeq "$(HAVE_CLANG)" "1"
	CXXFLAGS+= -Wno-conversion -Wno-shorten-64-to-32 -Wno-sign-compare -Wno-four-char-constants
endif

#######################################################################
# Default commands - put the necessary replacements in config.mk      #
#######################################################################

CAT     ?= cat
CP      ?= cp
ECHO    ?= printf
INSTALL ?= install
MKDIR   ?= mkdir -p
RM      ?= rm -f
RM_REC  ?= $(RM) -r
ZIP     ?= zip -q

#######################################################################

include $(srcdir)/Makefile.common

# check if configure has been run or has been changed since last run
config.h config.mk: $(srcdir)/configure
ifeq "$(findstring config.mk,$(MAKEFILE_LIST))" "config.mk"
	@echo "Running $(srcdir)/configure with the last specified parameters"
	@sleep 2
	LDFLAGS="$(SAVED_LDFLAGS)" CXX="$(SAVED_CXX)" \
			CXXFLAGS="$(SAVED_CXXFLAGS)" CPPFLAGS="$(SAVED_CPPFLAGS)" \
			ASFLAGS="$(SAVED_ASFLAGS)" WINDRESFLAGS="$(SAVED_WINDRESFLAGS)" \
			$(srcdir)/configure $(SAVED_CONFIGFLAGS)
else
	$(error You need to run $(srcdir)/configure before you can run make. Check $(srcdir)/configure --help for a list of parameters)
endif

#
# Windows specific
#

scummvmtoolswinres.o: $(srcdir)/gui/media/scummvmtools.ico $(srcdir)/dists/scummvmtools.rc
	$(QUIET_WINDRES)$(WINDRES) -DHAVE_CONFIG_H $(WINDRESFLAGS) $(DEFINES) -I. -I$(srcdir) $(srcdir)/dists/scummvmtools.rc scummvmtoolswinres.o

# Special target to create a win32 tools snapshot binary
WIN32PATH=c:/scummvm
win32dist:   all
	mkdir -p $(WIN32PATH)
	mkdir -p $(WIN32PATH)/graphics
	mkdir -p $(WIN32PATH)/tools
	mkdir -p $(WIN32PATH)/tools/media
	cp gui/media/detaillogo.jpg $(WIN32PATH)/tools/media/
	cp gui/media/logo.jpg $(WIN32PATH)/tools/media/
	cp gui/media/tile.gif $(WIN32PATH)/tools/media/
	$(STRIP) construct_mohawk$(EXEEXT) -o $(WIN32PATH)/tools/construct_mohawk$(EXEEXT)
	$(STRIP) create_sjisfnt$(EXEEXT) -o $(WIN32PATH)/tools/create_sjisfnt$(EXEEXT)
	$(STRIP) decine$(EXEEXT) -o $(WIN32PATH)/tools/decine$(EXEEXT)
	$(STRIP) degob$(EXEEXT) -o $(WIN32PATH)/tools/degob$(EXEEXT)
	$(STRIP) dekyra$(EXEEXT) -o $(WIN32PATH)/tools/dekyra$(EXEEXT)
	$(STRIP) deriven$(EXEEXT) -o $(WIN32PATH)/tools/deriven$(EXEEXT)
	$(STRIP) descumm$(EXEEXT) -o $(WIN32PATH)/tools/descumm$(EXEEXT)
	$(STRIP) desword2$(EXEEXT) -o $(WIN32PATH)/tools/desword2$(EXEEXT)
	$(STRIP) extract_mohawk$(EXEEXT) -o $(WIN32PATH)/tools/extract_mohawk$(EXEEXT)
	$(STRIP) gob_loadcalc$(EXEEXT) -o $(WIN32PATH)/tools/gob_loadcalc$(EXEEXT)
	$(STRIP) scummvm-tools$(EXEEXT) -o $(WIN32PATH)/tools/scummvm-tools$(EXEEXT)
	$(STRIP) scummvm-tools-cli$(EXEEXT) -o $(WIN32PATH)/tools/scummvm-tools-cli$(EXEEXT)
	cp *.bat $(WIN32PATH)/tools
	cp COPYING $(WIN32PATH)/tools/COPYING.txt
	cp README $(WIN32PATH)/tools/README.txt
	cp NEWS $(WIN32PATH)/tools/NEWS.txt
	cp dists/win32/graphics/left.bmp $(WIN32PATH)/graphics
	cp dists/win32/graphics/scummvm-install.ico $(WIN32PATH)/graphics
	cp dists/win32/ScummVM?Tools.iss $(WIN32PATH)
	unix2dos $(WIN32PATH)/tools/*.txt

# Special target to create a win32 NSIS installer
WIN32BUILD=build
win32setup: all
	mkdir -p $(srcdir)/$(WIN32BUILD)
	cp $(srcdir)/COPYING          $(srcdir)/$(WIN32BUILD)
	cp $(srcdir)/NEWS             $(srcdir)/$(WIN32BUILD)
	cp $(srcdir)/README           $(srcdir)/$(WIN32BUILD)
	unix2dos $(srcdir)/$(WIN32BUILD)/*.*
	$(STRIP) construct_mohawk$(EXEEXT)   -o $(srcdir)/$(WIN32BUILD)/construct_mohawk$(EXEEXT)
	$(STRIP) create_sjisfnt$(EXEEXT)     -o $(srcdir)/$(WIN32BUILD)/create_sjisfnt$(EXEEXT)
	$(STRIP) decine$(EXEEXT)             -o $(srcdir)/$(WIN32BUILD)/decine$(EXEEXT)
	$(STRIP) degob$(EXEEXT)              -o $(srcdir)/$(WIN32BUILD)/degob$(EXEEXT)
	$(STRIP) dekyra$(EXEEXT)             -o $(srcdir)/$(WIN32BUILD)/dekyra$(EXEEXT)
	$(STRIP) deriven$(EXEEXT)            -o $(srcdir)/$(WIN32BUILD)/deriven$(EXEEXT)
	$(STRIP) descumm$(EXEEXT)            -o $(srcdir)/$(WIN32BUILD)/descumm$(EXEEXT)
	$(STRIP) desword2$(EXEEXT)           -o $(srcdir)/$(WIN32BUILD)/desword2$(EXEEXT)
	$(STRIP) extract_mohawk$(EXEEXT)     -o $(srcdir)/$(WIN32BUILD)/extract_mohawk$(EXEEXT)
	$(STRIP) gob_loadcalc$(EXEEXT)       -o $(srcdir)/$(WIN32BUILD)/gob_loadcalc$(EXEEXT)
	$(STRIP) scummvm-tools$(EXEEXT)      -o $(srcdir)/$(WIN32BUILD)/scummvm-tools$(EXEEXT)
	$(STRIP) scummvm-tools-cli$(EXEEXT)  -o $(srcdir)/$(WIN32BUILD)/scummvm-tools-cli$(EXEEXT)
	makensis -V2 -Dtop_srcdir="../.." -Dtext_dir="../../$(WIN32BUILD)" -Dbuild_dir="../../$(WIN32BUILD)" $(srcdir)/dists/win32/scummvm-tools.nsi

#
# AmigaOS specific
#

# Special target to create an AmigaOS snapshot installation
aos4dist: all
	mkdir -p $(AOS4PATH)
	mkdir -p $(AOS4PATH)/graphics
	mkdir -p $(AOS4PATH)/tools
	mkdir -p $(AOS4PATH)/tools/media
	cp $(srcdir)/gui/media/detaillogo.jpg $(AOS4PATH)/tools/media/
	cp $(srcdir)/gui/media/logo.jpg $(AOS4PATH)/tools/media/
	cp $(srcdir)/gui/media/tile.gif $(AOS4PATH)/tools/media/
	$(STRIP) construct_mohawk$(EXEEXT) -o $(AOS4PATH)/tools/construct_mohawk$(EXEEXT)
	$(STRIP) create_sjisfnt$(EXEEXT) -o $(AOS4PATH)/tools/create_sjisfnt$(EXEEXT)
	$(STRIP) decine$(EXEEXT) -o $(AOS4PATH)/tools/decine$(EXEEXT)
	$(STRIP) degob$(EXEEXT) -o $(AOS4PATH)/tools/degob$(EXEEXT)
	$(STRIP) dekyra$(EXEEXT) -o $(AOS4PATH)/tools/dekyra$(EXEEXT)
	$(STRIP) deriven$(EXEEXT) -o $(AOS4PATH)/tools/deriven$(EXEEXT)
	$(STRIP) descumm$(EXEEXT) -o $(AOS4PATH)/tools/descumm$(EXEEXT)
	$(STRIP) desword2$(EXEEXT) -o $(AOS4PATH)/tools/desword2$(EXEEXT)
	$(STRIP) extract_mohawk$(EXEEXT) -o $(AOS4PATH)/tools/extract_mohawk$(EXEEXT)
	$(STRIP) gob_loadcalc$(EXEEXT) -o $(AOS4PATH)/tools/gob_loadcalc$(EXEEXT)
	$(STRIP) scummvm-tools$(EXEEXT) -o $(AOS4PATH)/tools/scummvm-tools$(EXEEXT)
	$(STRIP) scummvm-tools-cli$(EXEEXT) -o $(AOS4PATH)/tools/scummvm-tools-cli$(EXEEXT)
	#cp ${srcdir}/icons/scummvm.info $(AOS4PATH)/$(EXECUTABLE).info
	cp $(srcdir)/COPYING $(AOS4PATH)/tools/COPYING.txt
	cp $(srcdir)/README $(AOS4PATH)/tools/README.txt
	cp $(srcdir)/NEWS $(AOS4PATH)/tools/NEWS.txt
