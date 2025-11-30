#!/usr/bin/env python3

import argparse
from bs4 import BeautifulSoup, Tag
from importlib import resources
import logging
import os
from pathlib import Path
from pprint import pformat
import re
import shutil

from dash_docset_builder import (
        build_docset_skeleton, 
        get_argparse_template, 
        create_table, 
        insert
)

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
    parser: argparse.ArgumentParser = get_argparse_template()
    # add option to specify locale
    # TODO
    _ = parser.add_argument("-l", "--locale",
                            choices=[
                                "de", 
                                "en", 
                                "ja", 
                                "pt", 
                                "ru", 
                                "zh-cn", 
                                "zh-tw"
                            ],
                            help="Specify locale to limit to")
    args: argparse.Namespace = parser.parse_args()

    if not args.MANUAL_SOURCE.exists():
        print(f"Error: invalid MANUAL_SOURCE '{str(args.MANUAL_SOURCE)}'")
        exit(1)

    docset_skeleton: dict[str, Path] | None = build_docset_skeleton(
            "debmake", args.builddir
    )
    if docset_skeleton is None:
        exit(1)

    main: Index = Index(str(docset_skeleton["index_file"]))

    create_table(str(docset_skeleton["index_file"]))
    
    # copy files from manual source to builddir
    _ = shutil.copytree(
            args.MANUAL_SOURCE, 
            docset_skeleton["documents_dir"], 
            dirs_exist_ok=True
        )
    
    #for html_path in docset_skeleton["documents_dir"].rglob("*.html"):
    #    main.insert_page(str(html_path))

    # add plist and icon
    with resources.path(
            "debmake_dash_docset_generator", 
            Path("resources", "icon.png")
    ) as fspath:
        _ = shutil.copy2(fspath, docset_skeleton["icon_file"])

if __name__ == '__main__':
    main()
