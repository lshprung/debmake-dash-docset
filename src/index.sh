#!/usr/bin/env sh

#DEBUG="yes"

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
		sed 's/&amp/&/g' | \
		# Remove trailing newline
		sed 's/\"/\"\"/g'

	#pup -p -f "$1" 'h1[class="title"]' | 
	#	tr -d \\n | \
	#	sed 's/\"/\"\"/g'

	if [ -n "$DEBUG" ]; then
		echo "          vanilla PAGE_NAME is $(grep -Eo "$PATTERN" "$FILE")" >> /dev/stderr
		echo "01 transformation PAGE_NAME is $(grep -Eo "$PATTERN" "$FILE" | sed 's/<[^>]*>//')" >> /dev/stderr
		echo "02 transformation PAGE_NAME is $(grep -Eo "$PATTERN" "$FILE" | sed 's/<[^>]*>//' | sed 's/[ ]*$//g')" > /dev/stderr
		echo "03 transformation PAGE_NAME is $(grep -Eo "$PATTERN" "$FILE" | sed 's/<[^>]*>//' | sed 's/[ ]*$//g' | sed 's/&amp/&/g')" >> /dev/stderr
		echo "            final PAGE_NAME is $(grep -Eo "$PATTERN" "$FILE" | sed 's/<[^>]*>//' | sed 's/[ ]*$//g' | sed 's/&amp/&/g' | sed 's/\"/\"\"/g')" >> /dev/stderr
	fi
}

insert_pages() {
	# Get titles and insert into table for each html file
	while [ -n "$1" ]; do
		unset PAGE_NAME
		PAGE_NAME="$(get_title "$1")"
		echo "$PAGE_NAME" | while read -r line; do
			if [ -n "$line" ]; then
				unset TITLE
				TITLE="$(echo "$line" | sed 's/<[^>]*>//g' | sed -E 's/^Chapter |Appendix //' | sed -E 's/^[A-Z0-9][0-9]?\.[^ ]* //' | sed 's/Table of Contents.*//')"
				unset LINK
				LINK="$(basename "$1")#$(echo "$line" | sed 's/.*id=\"\"//' | sed 's/\"\"\/>.*//')"
				if [ -n "$DEBUG" ]; then
					echo "          vanilla TITLE is $(echo "$line")" >> /dev/stderr
					echo "01 transformation TITLE is $(echo "$line" | sed 's/<[^>]*>//g' )" >> /dev/stderr
					echo "02 transformation TITLE is $(echo "$line" | sed 's/<[^>]*>//g' | sed -E 's/^Chapter |Appendix //')" >> /dev/stderr
					echo "03 transformation TITLE is $(echo "$line" | sed 's/<[^>]*>//g' | sed -E 's/^Chapter |Appendix //' | sed -E 's/^[A-Z0-9][0-9]?\.[^ ]* //')" >> /dev/stderr
					echo "            final TITLE is $(echo "$line" | sed 's/<[^>]*>//g' | sed -E 's/^Chapter |Appendix //' | sed -E 's/^[A-Z0-9][0-9]?\.[^ ]* //' | sed 's/Table of Contents.*//')" >> /dev/stderr
					echo "          vanilla LINK is $(basename "$1")" >> /dev/stderr
					echo "01 transformation LINK is $(basename "$1")#$(echo "$line")" >> /dev/stderr
					echo "02 transformation LINK is $(basename "$1")#$(echo "$line" | sed 's/.*id=\"\"//')" >> /dev/stderr
					echo "03 transformation LINK is $(basename "$1")#$(echo "$line" | sed 's/.*id=\"\"//' | sed 's/\"\"\/>.*//')" >> /dev/stderr
					echo "            final LINK is $LINK" >> /dev/stderr
					echo >> /dev/stderr
				fi

				insert "$DB_PATH" "$TITLE" "Guide" "$LINK"
			fi
		done
		shift
	done
}

create_table "$DB_PATH"
insert_pages "$@"
