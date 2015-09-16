npm install

# delete 2 unnecessary node requirements from lib – they fail in a non-node environment like the SDK
sed -i -e "1,2d" node_modules/html-to-text/lib/html-to-text.js

# delete special handling for non-node environments – intended for web sites
sed -i -e "39,46d" node_modules/html-to-text/node_modules/htmlparser/lib/htmlparser.js
