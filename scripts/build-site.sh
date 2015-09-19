
set -e

echo -e "\n[BUILDING SITE] creating temp repository..."
rm -rf tmp
git clone . tmp
cd tmp
git checkout master

echo -e "\n[BUILDING SITE] installing tools..."
npm install codo

echo -e "\n[BUILDING SITE] generating code documentation..."
rm -rf docs
node_modules/codo/bin/codo

echo -e "\n[BUILDING SITE] deleting everything but site and docs..."
shopt -s extglob
rm -r !(site|docs)

echo -e "\n[BUILDING SITE] preparing for commit..."
cp -r site/* .
rm -rf site

echo -e "\n[BUILDING SITE] committing..."
git checkout gh-pages
git add .
git commit -m "update generated documentation"

echo -e "\n[BUILDING SITE] pushing..."
git push origin gh-pages

cd ..
echo -e "\n[BUILDING SITE] cleaning up..."
rm -rf tmp

echo -e "\n[BUILDING SITE] Done."
