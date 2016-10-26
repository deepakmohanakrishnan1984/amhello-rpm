.PHONY: all devtree sources rpm lint clean
#-------------------------
# Global options
#-------------------------
TOP_DIR ?= ${HOME}/rpmbuild
TOP_DIR_OPT := --define '_topdir $(TOP_DIR)'

rpmcmd = $(shell ${RPMENV} rpm ${TOP_DIR_OPT} $(1))
# By default, build the rpm
all: rpm

#-------------------------
# RPM Build Tree
#-------------------------
RPMDIR = $(call rpmcmd,-E '%{_rpmdir}')
SOURCEDIR = $(call rpmcmd,-E '%{_sourcedir}')
SPECDIR = $(call rpmcmd,-E '%{_specdir}')
BUILDDIR = $(call rpmcmd,-E '%{_builddir}')
SRPMDIR = $(call rpmcmd,-E '%{_srcrpmdir}')

BUILD_TREE = $(RPMDIR) $(SOURCEDIR) $(SPECDIR) $(BUILDDIR) $(SRPMDIR)

# Ensures all build directories exist
devtree: $(BUILD_TREE)

# Creates build directories
$(BUILD_TREE):
	@mkdir -vp $@

#--------------------------
# Source files
#--------------------------

# The name of the RPM spec file
SPEC_SOURCE ?= $(shell ls *.spec | head -1)
# The destination of the RPM spec file in the build tree
SPEC = $(SPECDIR)/$(SPEC_SOURCE)

# Copy the spec file to the tree
$(SPEC): $(SPEC_SOURCE) $(SPECDIR)
	@cp -v $< $(SPECDIR)

# We read the RPM spec to discover what files are needed in SOURCES,
# both Source and Patch files.
#
# We have three possibilities here:
# 1) The source is local, we simply copy to the SOURCES directory.
# 2) The source is remote, and is present in the local directory tree,
#    in which case we treat it like #1.
# 3) The source is remote, and must be fetched.
#
# The strategy is:
# 1) Find the local file, establish a rule that copies it to the SOURCES.
# 2+3) Expect the remote file to be fetched to dist/. Establish rules
#      that copy the fetched version into SOURCES, and fetch the file
#      if not present.

# The names/URLs of "Source" files in the spec file
SOURCE_FILES := $(shell awk '/^(Source|Patch)/ { print $$NF }' $(SPEC_SOURCE))
SOURCE_LOCAL = $(filter-out http% ftp:%,$(SOURCE_FILES))
SOURCE_REMOTE = $(filter http% ftp:%,$(SOURCE_FILES))
ALL_SOURCES = $(patsubst %,$(SOURCEDIR)/%,$(notdir $(SOURCE_LOCAL) $(SOURCE_REMOTE)))

# 1) Template for local files
define LOCAL_FILE_template
$$(SOURCEDIR)/$(notdir $(1)): $(1)
	@cp -v $$< $$@
endef

$(foreach src,$(SOURCE_LOCAL),$(eval $(call LOCAL_FILE_template,$(src))))

# 2+3) Template for remote files
define REMOTE_FILE_template
$$(SOURCEDIR)/$(notdir $(1)): dist/$(notdir $(1))
	@cp -v $$< $$@
dist/$(notdir $(1)):
	@mkdir -p dist
	@curl -o dist/$(notdir $(1)) $(1)
endef

$(foreach src,$(SOURCE_REMOTE),$(eval $(call REMOTE_FILE_template,$(src))))

# Phony target to copy sources
sources: $(SPEC) $(SOURCEDIR) $(ALL_SOURCES)

#--------------------------
# Building RPM file
#--------------------------
RPM_DATA = $(call rpmcmd,--specfile -q $(SPEC_SOURCE))
ARCH = $(lastword $(subst ., ,$(RPM_DATA)))
BINPKGNAMES = $(addsuffix .rpm,$(RPM_DATA))
BINPKGS = $(addprefix $(RPMDIR)/$(ARCH)/,$(BINPKGNAMES))

rpm: $(BINPKGS)

$(BINPKGS): $(BUILD_TREE) $(SPEC) $(ALL_SOURCES)
	@${RPMENV} rpmbuild ${TOP_DIR_OPT} -bb $(SPEC)

#--------------------------
# Linting built RPM
#--------------------------
lint: $(SPEC) $(BINPKGS)
	@${RPMENV} rpmlint -i $+

#--------------------------
# Cleaning up
#--------------------------
ifeq ("${TOP_DIR}","")
$(error TOP_DIR variable is empty! `clean` target disabled)
clean:
	@echo TOP_DIR variable is empty! Cannot find RPM build root.
else
clean:
	@rm -fv $(SPEC)
	@rm -fv $(ALL_SOURCES)
	@rm -rfv $(SOURCEDIR)/*
	@rm -rfv $(BUILDDIR)/*
	@rm -fv $(BINPKGS)
endif
