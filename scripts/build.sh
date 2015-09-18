set -e

echo -e "\n[BUILDING] creating temp repository..."
rm -rf tmp
git clone . tmp
cd tmp

echo -e "\n[BUILDING] compiling coffeescript..."
coffee -c .

echo -e "\n[BUILDING] packaging XPI..."
jpm xpi

echo -e "\n[BUILDING] cleaning up..."
cp *.xpi ..
cd ..
rm -rf tmp

echo -e "\n[BUILDING] Done."
