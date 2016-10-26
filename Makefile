.PHONY: all
all: rpm.mk

ATLAS_TARGET_DIR = https://atlas.sys.comcast.net/cap/cap/x86_64/6/global/

atlas: lint rpm
	@echo "Uploading $(BINPKGNAMES) to atlas if not already there"
	@test ! -z ${SVN_USER} || (echo "SVN_USER variable not set"; exit 1)
	@test ! -z ${SVN_PASSWORD} || (echo "SVN_PASSWORD variable not set"; exit 1)
	@(svn --non-interactive --username ${SVN_USER} --password ${SVN_PASSWORD} ls ${ATLAS_TARGET_DIR} | \
		grep -q $(BINPKGNAMES)) || \
		svn --non-interactive --username ${SVN_USER} --password ${SVN_PASSWORD} import $(BINPKGS) $(ATLAS_TARGET_DIR)$(BINPKGNAMES) -m "Import $(BINPKGNAMES)"


TOP_COMMIT_ID := $(shell git rev-parse --short HEAD)
TOP_COMMIT_TS := $(strip $(shell git show --format="%ct" | head -1))
TOP_COMMIT_DAY := $(shell date -d @$(TOP_COMMIT_TS) +"%a %b %d %Y")

RELEASE := $(TOP_COMMIT_TS).$(TOP_COMMIT_ID)
RPMENV := RELEASE="${RELEASE}" TOP_COMMIT_DAY="${TOP_COMMIT_DAY}"

include rpm.mk
