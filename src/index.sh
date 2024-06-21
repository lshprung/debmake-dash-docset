#!/usr/bin/env sh

# shellcheck source=../../../scripts/create_table.sh
. "$(dirname "$0")"/../../../scripts/create_table.sh
# shellcheck source=../../../scripts/insert.sh
. "$(dirname "$0")"/../../../scripts/insert.sh

DB_PATH="$1"
shift

get_title() {
	FILE="$1"

	PATTERN="<.*class=\"title\">.*"

	#Find pattern in file
	grep -Eo "$PATTERN" "$FILE" | 
		#Remove tag
		sed 's/<[^>]*>//' | \
		#Remove trailing space
		sed 's/[ ]*$//g' | \
		#Replace '&amp' with '&'
		sed 's/&amp/&/g'
}

insert_pages() {
	# Get titles and insert into table for each html file
	while [ -n "$1" ]; do
		unset PAGE_NAME
		PAGE_NAME="$(get_title "$1")"
		echo "$PAGE_NAME" | while read -r line; do
			if [ -n "$line" ]; then
				unset TITLE
				TITLE="$(echo "$line" | sed 's/<[^>]*>//g' | sed -E 's/^Chapter |Appendix //' | sed 's/^[A-Z0-9]\.[^ ]* //')"
				unset LINK
				LINK="$(basename "$1")#$(echo "$line" | sed 's/^.\{7\}//' | sed 's/\"\/>.*//')"
				insert "$DB_PATH" "$TITLE" "Guide" "$LINK"
			fi
		done
		shift
	done
}

create_table "$DB_PATH"
insert_pages "$@"
