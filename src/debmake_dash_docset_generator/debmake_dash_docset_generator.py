#!/usr/bin/env python3

from bs4 import BeautifulSoup, Tag
import logging
import os
from pprint import pformat
import re
import sys

from dash_docset_builder import create_table, insert

class Index:
    def __init__(self, db_path: str) -> None:
        self.db_path: str = db_path

    # Find all relevant titles from a page
    def get_title(self, html_path: str) -> list[Tag]:
        soup: BeautifulSoup = BeautifulSoup(open(html_path), 'html.parser')
        matches: list[Tag] = soup.find_all(class_="title")
        logging.debug("Got matches " + pformat(matches))
        return matches

    def insert_page(self, html_path: str) -> None:
        page_names: list[Tag] = self.get_title(html_path)
        title: str
        for page_name in page_names:
            # Skip titles that aren't links
            if page_name.a is None:
                continue

            title = page_name.get_text()
            logging.debug("first run title is '{}'".format(title))
            title = re.sub(r'^(Chapter|Appendix|Table)', r'', title).lstrip()
            logging.debug("second run title is '{}'".format(title))
            title = re.sub(r'^[A-Z0-9]+(\.[A-Z0-9]+)*\.', r'', title).lstrip()
            logging.debug("third run title is '{}'".format(title))
            title = re.sub(r'Table of Contents.*', r'', title)
            logging.debug("final title is '{}'".format(title))

            link = os.path.basename(html_path) + "#" + str(page_name.a['id'])
            
            logging.debug("link is " + link)

            insert(self.db_path, title, "Guide", link)

# TODO probably use argparse here
def main() -> None:
    db_path: str = sys.argv[1]

    main: Index = Index(db_path)
    create_table(db_path)
    
    for html_path in sys.argv[2:]:
        main.insert_page(html_path)

if __name__ == '__main__':
    main()
