
set -e

echo -e "\n[BUILDING SITE] creating temp repository..."
rm -rf tmp
git clone . tmp
cd tmp
git checkout master

echo -e "\n[BUILDING SITE] installing tools..."
npm install codo
gem install jekyll

echo -e "\n[BUILDING SITE] generating code documentation..."
node_modules/codo/bin/codo

cd site
echo -e "\n[BUILDING SITE] building site..."
jekyll build

echo -e "\n[BUILDING SITE] copying docs to site..."
cd ..
mkdir -p site/_site/docs/codo
cp -r doc site/_site/docs/codo
rm -rf doc

git checkout gh-pages

echo -e "\n[BUILDING SITE] deleting everything but site..."
shopt -s extglob
rm -r !(site)

echo -e "\n[BUILDING SITE] preparing for commit..."
cp -r site/_site/* .
rm -rf site
git add .

echo -e "\n[BUILDING SITE] committing..."
git commit -m "update generated documentation"

echo -e "\n[BUILDING SITE] pushing..."
git push origin gh-pages

cd ..
echo -e "\n[BUILDING SITE] cleaning up..."
rm -rf tmp

echo -e "\n[BUILDING SITE] Done."
