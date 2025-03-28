PACKAGE_NAME = debmake-doc
LOCALE = en

SRC_INFO_PLIST_IN = $(SOURCE_DIR)/Info.plist.in
SRC_ICON_FILE = $(SOURCE_DIR)/icon.png

# TODO latest version should not have to be manually determined
VERSION = 1.22
MANUAL_URL = https://salsa.debian.org/debian/debmake-doc/-/archive/debian/$(VERSION)-1/debmake-doc-debian-$(VERSION)-1.tar.gz
MANUAL_SRC = tmp/$(PACKAGE_NAME)-debian-$(VERSION)-1
MANUAL_FILE = $(MANUAL_SRC)/basedir/html

$(MANUAL_SRC): tmp
	curl -o $@.tar.gz $(MANUAL_URL)
	tar -x -z -f $@.tar.gz -C tmp

$(MANUAL_FILE): $(MANUAL_SRC)
	cd $(MANUAL_SRC) && make html css LANGALL=$(LOCALE)

$(DOCUMENTS_DIR): $(RESOURCES_DIR) $(MANUAL_FILE)
	mkdir -p $@
	cp -r $(MANUAL_FILE)/* $@

.INTERMEDIATE: $(SRC_INFO_PLIST_FILE)
$(SRC_INFO_PLIST_FILE): $(SRC_INFO_PLIST_IN) $(CONTENTS_DIR)
	head -n -2 $(SRC_INFO_PLIST_IN) > $@
	echo "	<key>dashIndexFilePath</key>" >> $@
	echo "	<string>index.$(LOCALE).html</string>" >> $@
	echo "</dict>" >> $@
	echo "</plist>" >> $@

#$(INDEX_FILE): $(wildcard $(SOURCE_DIR)/src/*.sh) $(DOCUMENTS_DIR)
#	rm -f $@
#	$(SOURCE_DIR)/src/index.sh $@ $(DOCUMENTS_DIR)/*.html

$(INDEX_FILE): $(wildcard $(SOURCE_DIR)/src/*.py) $(DOCUMENTS_DIR)
	rm -f $@
	$(SOURCE_DIR)/src/index.py $@ $(DOCUMENTS_DIR)/*.html
