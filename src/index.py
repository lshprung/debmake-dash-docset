#!/usr/bin/env python3

from bs4 import BeautifulSoup
import logging
import os
from pprint import pformat
import re
import sys

sys.path.append(os.path.join(os.path.dirname(__file__), "..", "..", "..", "scripts"))
from create_table import create_table
from insert import insert

class Index:
    def __init__(self, db_path):
        self.db_path = db_path

    # Find all relevant titles from a page
    def get_title(self, html_path):
        soup = BeautifulSoup(open(html_path), 'html.parser')
        matches = soup.find_all(class_="title")
        logging.debug("Got matches " + pformat(matches))
        return matches

    def insert_page(self, html_path):
        page_names = self.get_title(html_path)
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

            link = os.path.basename(html_path) + "#" + page_name.a['id']
            
            logging.debug("link is " + link)

            insert(self.db_path, title, "Guide", link)

if __name__ == '__main__':
    db_path = sys.argv[1]

    main = Index(db_path)
    create_table(db_path)
    
    for html_path in sys.argv[2:]:
        main.insert_page(html_path)
