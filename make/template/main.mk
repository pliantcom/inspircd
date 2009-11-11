#               InspIRCd Main Makefile
#
#       (C) InspIRCd Development Team, 2002-2009
# This file is automagically generated by configure, from
# make/templates/main.mk. Any changes make to the generated
#     files will go away whenever it is regenerated!
#
# Please do not edit unless you know what you're doing. This
# needs to work in both GNU and BSD make; it is mangled for
# them by configure.
#

CC = @CC@
SYSTEM = @SYSTEM@
BUILDPATH = @BUILD_DIR@
SOCKETENGINE = @SOCKETENGINE@
CXXFLAGS = -O1 -pipe -fPIC -DPIC
LDLIBS = -pthread -lstdc++
LDFLAGS = 
SHARED = -shared -rdynamic
CORELDFLAGS = -rdynamic -L. $(LDFLAGS)
PICLDFLAGS = -fPIC -shared -rdynamic $(LDFLAGS)
BASE = "@BASE_DIR@"
CONPATH = "@CONFIG_DIR@"
MODPATH = "@MODULE_DIR@"
BINPATH = "@BINARY_DIR@"
LAUNCHDPATH = "/System/Library/LaunchDaemons"
INSTMODE = 0755

@IFEQ $(CC) icc
  CXXFLAGS += -Wshadow
@ELSE
  CXXFLAGS += -pedantic -Woverloaded-virtual -Wshadow -Wformat=2 -Wmissing-format-attribute -Wall
@ENDIF


@IFEQ $(SYSTEM) linux
  LDLIBS += -ldl
@ELSIFEQ $(SYSTEM) solaris
  LDLIBS += -lsocket -lnsl -lrt -lresolv
@ELSIFEQ $(SYSTEM) sunos
  LDLIBS += -lsocket -lnsl -lrt -lresolv
@ELSIFEQ $(SYSTEM) darwin
  CXXFLAGS += -DDARWIN -frtti
  LDLIBS += -ldl
  SHARED = -bundle -twolevel_namespace -undefined dynamic_lookup
  CORELDFLAGS = -dynamic -bind_at_load -L.
@ELSIFEQ $(SYSTEM) interix
  CXXFLAGS += -D_ALL_SOURCE -I/usr/local/include
@ENDIF 

@IFDEF D
    CXXFLAGS += -g3 -Werror
    HEADER = debug-header
@ELSE
    CXXFLAGS += -g1
    HEADER = std-header
@ENDIF
FOOTER = finishmessage

CXXFLAGS += -Iinclude

@GNU_ONLY MAKEFLAGS += --no-print-directory

@GNU_ONLY SOURCEPATH = $(shell /bin/pwd)
@BSD_ONLY SOURCEPATH != /bin/pwd

@IFDEF V
    RUNCC = $(CC)
    VERBOSE = -v
@ELSE
    @GNU_ONLY MAKEFLAGS += --silent
    @BSD_ONLY MAKE += -s
    RUNCC = perl $(SOURCEPATH)/make/run-cc.pl $(CC)
@ENDIF

@IFDEF PURE_STATIC
	CXXFLAGS += -DPURE_STATIC
@ENDIF

@DO_EXPORT RUNCC CXXFLAGS CC LDLIBS PICLDFLAGS VERBOSE SOCKETENGINE CORELDFLAGS PURE_STATIC
@DO_EXPORT BASE CONPATH MODPATH BINPATH SOURCEPATH BUILDPATH

# Default target
TARGET = all

@IFDEF M
    HEADER = mod-header
    FOOTER = mod-footer
    @BSD_ONLY TARGET = modules/${M:S/.so$//}.so
    @GNU_ONLY TARGET = modules/$(M:.so=).so
@ENDIF

@IFDEF T
    HEADER =
    FOOTER = target
    TARGET = $(T)
@ENDIF

all: $(FOOTER)

target: $(HEADER)
	$(MAKEENV) perl make/calcdep.pl
	$(MAKEENV) $(MAKE) -C $(BUILDPATH) -f real.mk $(TARGET)

debug:
	@${MAKE} D=1 all

debug-header:
	@echo "*************************************"
	@echo "*    BUILDING WITH DEBUG SYMBOLS    *"
	@echo "*                                   *"
	@echo "*   This will take a *long* time.   *"
	@echo "*  Please be aware that this build  *"
	@echo "*  will consume a very large amount *"
	@echo "*  of disk space (~350MB), and may  *"
	@echo "*  run slower. Use the debug build  *"
	@echo "*  for module development or if you *"
	@echo "*    are experiencing problems.     *"
	@echo "*                                   *"
	@echo "*************************************"

mod-header:
	@echo 'Building single module:'

mod-footer: target
	@echo 'To install, copy $(BUILDPATH)/$(TARGET) to $(MODPATH)'
	@echo 'Or, run "make install"'

std-header:
	@echo "*************************************"
	@echo "*       BUILDING INSPIRCD           *"
	@echo "*                                   *"
	@echo "*   This will take a *long* time.   *"
	@echo "*     Why not read our wiki at      *"
	@echo "*     http://wiki.inspircd.org      *"
	@echo "*  while you wait for make to run?  *"
	@echo "*************************************"

finishmessage: target
	@echo ""
	@echo "*************************************"
	@echo "*        BUILD COMPLETE!            *"
	@echo "*                                   *"
	@echo "*   To install InspIRCd, type:      *"
	@echo "*         make install              *"
	@echo "*************************************"

install: target@EXTRA_DIR@
	@-install -d -m $(INSTMODE) $(BASE)
	@-install -d -m $(INSTMODE) $(BASE)/data
	@-install -d -m $(INSTMODE) $(BASE)/logs
	@-install -d -m $(INSTMODE) $(BINPATH)
	@-install -d -m $(INSTMODE) $(CONPATH)
	@-install -d -m $(INSTMODE) $(MODPATH)
	-install -m $(INSTMODE) $(BUILDPATH)/modules/*.so $(MODPATH)
	-install -m $(INSTMODE) $(BUILDPATH)/bin/inspircd $(BINPATH)
	-install -m $(INSTMODE) @STARTSCRIPT@ $(@DESTINATION@) 2>/dev/null
	@$(MAKEENV) make/install-extras.pl install
	@echo ""
	@echo "*************************************"
	@echo "*        INSTALL COMPLETE!          *"
	@echo "*                                   *"
	@echo "* It is safe to ignore any messages *"
	@echo "* related to copying of conf files. *"
	@echo "*                                   *"
	@echo "* REMEMBER TO EDIT YOUR CONFIG FILE *"
	@echo "*************************************"

@GNU_ONLY RCS_FILES = $(wildcard .git/index .svn/entries .config.cache)
@GNU_ONLY GNUmakefile: make/template/main.mk configure $(RCS_FILES)
@GNU_ONLY 	./configure -update

clean:
	@echo Cleaning...
	@-rm -f src/inspircd src/modes/modeclasses.a include/inspircd_se_config.h
	@-rm -f src/*.so src/modules/*.so src/commands/*.so
	@-rm -f src/*.o src/*/*.o src/modules/*/*.o
	@-rm -f src/.*.d src/*/.*.d src/modules/*/.*.d
	@-rm -f $(BUILDPATH)/bin/inspircd $(BUILDPATH)/include $(BUILDPATH)/real.mk
	@-rm -rf $(BUILDPATH)/obj $(BUILDPATH)/modules
	@-rmdir $(BUILDPATH)/bin 2>/dev/null
	@-rmdir $(BUILDPATH) 2>/dev/null
	@echo Completed.

deinstall:
	-rm $(BINPATH)/inspircd
	-rm $(MODPATH)/*.so
	@make/install-extras.pl deinstall

squeakyclean: distclean

launchd_dir:
	@-install -d -m $(INSTMODE) ${LAUNCHDPATH}

configureclean:
	rm -f .config.cache
	rm -f src/modules/Makefile
	rm -f src/commands/Makefile
	rm -f src/Makefile
	-rm -f Makefile
	rm -f BSDmakefile
	rm -f GNUmakefile
	rm -f include/inspircd_config.h
	rm -f include/inspircd_version.h

distclean: clean configureclean

help:
	@echo 'InspIRCd Makefile'
	@echo ''
	@echo 'Use: ${MAKE} [flags] [targets]'
	@echo ''
	@echo 'Flags:'
	@echo ' V=1       Show the full command being executed instead of "BUILD: dns.cpp"'
	@echo ' D=1       Enable debug build, for module development or crash tracing'
	@echo ' -j <N>    Run a parallel build using N jobs'
	@echo ''
	@echo 'User targets:'
	@echo ' all       Complete build of InspIRCd, without installing'
	@echo ' install   Build and install InspIRCd to the directory chosen in ./configure'
	@echo '           Currently installs to ${BASE}'
	@echo ' debug     Compile a debug build. Equivalent to "make D=1 all"'
	@echo ''
	@echo ' M=m_foo   Builds a single module (cmd_foo also works here)'
	@echo ' T=target  Builds a user-specified target, such as "inspircd" or "modules"'
	@echo '           Other targets are specified by their path in the build directory'
	@echo '           Multiple targets may be separated by a space'
	@echo ''
	@echo ' clean     Cleans object files produced by the compile'
	@echo ' distclean Cleans all files produced by compile and ./configure'
	@echo '           Note: this includes the Makefile'
	@echo ' deinstall Removes the files created by "make install"'
	@echo

.PHONY: all target debug debug-header mod-header mod-footer std-header finishmessage install clean deinstall squeakyclean launchd_dir configureclean help
