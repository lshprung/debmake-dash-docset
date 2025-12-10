#!/usr/bin/env python3

import argparse
from bs4 import BeautifulSoup, Tag
from importlib import resources
import logging
import os
from pathlib import Path
import plistlib
from pprint import pformat
import re
import shutil
import typing

from dash_docset_builder import (
        DB,
        DocsetSkeleton, 
        get_argparse_template, 
)

class Index:
    def __init__(self, db: DB) -> None:
        self.db: DB = db

    # Find all relevant titles from a page
    def get_title(self, html_path: Path) -> list[Tag]:
        soup: BeautifulSoup = BeautifulSoup(open(html_path), 'html.parser')
        matches: list[Tag] = soup.find_all(class_="title")
        logging.debug("Got matches " + pformat(matches))
        return matches

    def insert_page(self, html_path: Path) -> None:
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

            link = html_path.name + "#" + str(page_name.a['id'])
            
            logging.debug("link is " + link)

            self.db.insert(title, "Guide", link)

def main() -> None:
    parser: argparse.ArgumentParser = get_argparse_template()
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
                            default="en",
                            help="Specify locale to limit to")
    args: argparse.Namespace = parser.parse_args()

    if not args.MANUAL_SOURCE.exists():
        print(f"Error: invalid MANUAL_SOURCE '{str(args.MANUAL_SOURCE)}'")
        exit(1)

    docset_skeleton: DocsetSkeleton = DocsetSkeleton(
            "debmake", args.builddir
    )
    # docset_skeleton will exit if it encounters issues, so no need to handle 
    # it here

    db: DB = DB(docset_skeleton.index_file)
    index: Index = Index(db)
    
    # copy files from manual source to builddir
    _ = shutil.copytree(
            args.MANUAL_SOURCE, 
            docset_skeleton.documents_dir, 
            dirs_exist_ok=True
        )

    # remove files not matching the specified locale
    for f in docset_skeleton.documents_dir.iterdir():
        if str(f).endswith(".html"):
            if not str(f).endswith(f"{args.locale}.html"):
                os.remove(f)
    
    for html_path in docset_skeleton.documents_dir.rglob("*.html"):
        index.insert_page(html_path)

    # generate plist
    plist: dict[str, typing.Any] = {
            "CFBundleIdentifier": "debmake",
            "CFBundleName": "debmake",
            "DocSetPlatformFamily": "debmake",
            "isDashDocset": True,
            "dashIndexFilePath": f"index.{args.locale}.html"
    }
    with open(docset_skeleton.info_plist_file, mode='wb') as f:
        plistlib.dump(plist, f)

    # add icon
    with resources.path(
            "debmake_dash_docset_generator", 
            Path("resources", "icon.png")
    ) as fspath:
        _ = shutil.copy2(fspath, docset_skeleton.icon_file)

if __name__ == '__main__':
    main()
