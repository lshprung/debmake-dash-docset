DOCSET_NAME = debmake
PACKAGE_NAME = debmake-doc

ifndef $(LOCALE)
	LOCALE=en
endif

DOCSET_DIR    = $(DOCSET_NAME).docset
CONTENTS_DIR  = $(DOCSET_DIR)/Contents
RESOURCES_DIR = $(CONTENTS_DIR)/Resources
DOCUMENTS_DIR = $(RESOURCES_DIR)/Documents

INFO_PLIST_FILE = $(CONTENTS_DIR)/Info.plist
INDEX_FILE      = $(RESOURCES_DIR)/docSet.dsidx
ICON_FILE       = $(DOCSET_DIR)/icon.png
ARCHIVE_FILE    = $(DOCSET_NAME).tgz

MANUAL_SOURCE = /usr/share/doc/$(PACKAGE_NAME)/html

DOCSET = $(INFO_PLIST_FILE) $(INDEX_FILE) $(ICON_FILE)

all: $(DOCSET)

archive: $(ARCHIVE_FILE)

clean:
	rm -rf $(DOCSET_DIR) $(ARCHIVE_FILE)

tmp:
	mkdir -p $@

$(ARCHIVE_FILE): $(DOCSET)
	tar --exclude='.DS_Store' -czf $@ $(DOCSET_DIR)

$(MANUAL_FILE): tmp

$(DOCSET_DIR):
	mkdir -p $@

$(CONTENTS_DIR): $(DOCSET_DIR)
	mkdir -p $@

$(RESOURCES_DIR): $(CONTENTS_DIR)
	mkdir -p $@

$(DOCUMENTS_DIR): $(RESOURCES_DIR) $(MANUAL_FILE)
ifeq (,$(wildcard $(MANUAL_SOURCE)))
	$(error Missing debmake-doc package)
endif
	mkdir -p $@
	cp -r $(MANUAL_SOURCE)/*.$(LOCALE).* $@
	cp -r $(MANUAL_SOURCE)/*css $@
	cp -r $(MANUAL_SOURCE)/images $@

$(INFO_PLIST_FILE): src/Info.plist $(CONTENTS_DIR)
	cp src/Info.plist $@

$(INDEX_FILE): src/index.sh $(DOCUMENTS_DIR)
	rm -f $@
	src/index.sh $@ $(DOCUMENTS_DIR)/*.html

$(ICON_FILE): src/icon.png $(DOCSET_DIR)
	cp src/icon.png $@
