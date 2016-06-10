dirname=$(dirname $0)
cd $dirname
node ../doxx.js "$(pwd)/config/doxx.js"
