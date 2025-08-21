CHANGELOG_VERSION=$(git describe --exact-match --tags HEAD)
echo $CHANGELOG_VERSION
# sed -i "s/VERSION/$CHANGELOG_VERSION/g" CHANGELOG.md
