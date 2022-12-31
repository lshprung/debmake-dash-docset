DOCSET_NAME = debmake
PACKAGE_NAME = debmake-doc
LOCALE = en

DOCSET_DIR    = $(DOCSET_NAME).docset
CONTENTS_DIR  = $(DOCSET_DIR)/Contents
RESOURCES_DIR = $(CONTENTS_DIR)/Resources
DOCUMENTS_DIR = $(RESOURCES_DIR)/Documents

INFO_PLIST_FILE = $(CONTENTS_DIR)/Info.plist
INDEX_FILE      = $(RESOURCES_DIR)/docSet.dsidx
ICON_FILE       = $(DOCSET_DIR)/icon.png
ARCHIVE_FILE    = $(DOCSET_NAME).tgz

# TODO latest version should not have to be manually determined
VERSION = 1.17
MANUAL_URL = https://salsa.debian.org/debian/debmake-doc/-/archive/upstream/$(VERSION)/debmake-doc-upstream-$(VERSION).tar.gz
MANUAL_SRC = tmp/$(PACKAGE_NAME)-upstream-$(VERSION)
MANUAL_FILE = $(MANUAL_SRC)/basedir/html

DOCSET = $(INFO_PLIST_FILE) $(INDEX_FILE) $(ICON_FILE)

all: $(DOCSET)

archive: $(ARCHIVE_FILE)

clean:
	rm -rf $(DOCSET_DIR) $(ARCHIVE_FILE)
ifneq (,$(wildcard $(MANUAL_SRC)))
	cd $(MANUAL_SRC) && make clean
endif
	

tmp:
	mkdir -p $@

$(ARCHIVE_FILE): $(DOCSET)
	tar --exclude='.DS_Store' -czf $@ $(DOCSET_DIR)

$(MANUAL_SRC): tmp
	curl -o $@.tar.gz $(MANUAL_URL)
	tar -x -z -f $@.tar.gz -C tmp

$(MANUAL_FILE): $(MANUAL_SRC)
	cd $(MANUAL_SRC) && make html css LANGALL=$(LOCALE)

$(DOCSET_DIR):
	mkdir -p $@

$(CONTENTS_DIR): $(DOCSET_DIR)
	mkdir -p $@

$(RESOURCES_DIR): $(CONTENTS_DIR)
	mkdir -p $@

$(DOCUMENTS_DIR): $(RESOURCES_DIR) $(MANUAL_FILE)
	mkdir -p $@
	cp -r $(MANUAL_FILE)/* $@

$(INFO_PLIST_FILE): src/Info.plist $(CONTENTS_DIR)
	head -n -2 src/Info.plist > $@
	echo "	<key>dashIndexFilePath</key>" >> $@
	echo "	<string>index.$(LOCALE).html</string>" >> $@
	echo "</dict>" >> $@
	echo "</plist>" >> $@

$(INDEX_FILE): src/index.sh $(DOCUMENTS_DIR)
	rm -f $@
	src/index.sh $@ $(DOCUMENTS_DIR)/*.html

$(ICON_FILE): src/icon.png $(DOCSET_DIR)
	cp src/icon.png $@
