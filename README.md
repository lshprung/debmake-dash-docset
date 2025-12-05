Dash docset generator for 
[debmake-doc](https://salsa.debian.org/debian/debmake-doc)

### Instructions

- Download and build 
[upstream source](https://salsa.debian.org/debian/debmake-doc)

- `debmake-dash-docset-generator MANUAL_SOURCE`

`MANUAL_SOURCE` will be the path to the built upstream source, which should be
something like `debmake-doc/basedir/html`

- For a full set of options: `debmake-dash-docset-generator -h`

<!--
---

Supported values for LOCALE:

- `de`    - German          
- `en`    - English         
- `jp`    - Japanese        
- `ru`    - Russian         
- `zh-cn` - Chinese (China) 
- `zh-tw` - Chinese (Taiwan)
-->
