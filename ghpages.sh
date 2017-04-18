#!/bin/bash -x

git remote | grep docs || git remote add docs https://github.com/spring-cloud/spring-cloud-static

if ! (git fetch docs && git checkout --track docs/gh-pages || git checkout gh-pages); then
    echo "No gh-pages, error"
    exit 1
fi

if ! [ -d target/generated-docs ]; then
    echo "No gh-pages sources in target/generated-docs, so not syncing"
    exit 0
fi

# Stash any outstanding changes
###################################################################
git diff-index --quiet HEAD
dirty=$?
if [ "$dirty" != "0" ]; then git stash; fi

# Switch to gh-pages branch to sync it with master
###################################################################
git checkout gh-pages

for f in target/generated-docs/*; do
    file=${f#target/generated-docs/*}
    if ! git ls-files -i -o --exclude-standard --directory | grep -q ^$file$; then
        # Not ignored...
        cp -rf $f .
        git add -A $file
    fi
done

git commit -a -m "Sync docs from master to gh-pages"

# Uncomment the following push if you want to auto push to
# the gh-pages branch whenever you commit to master locally.
# This is a little extreme. Use with care!
###################################################################
git push docs gh-pages || exit 1

# Finally, switch back to the master branch and exit block
git checkout master
if [ "$dirty" != "0" ]; then git stash pop; fi

exit 0
