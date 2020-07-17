# v8lib 

docker build of v8 monolithic libary for use by just runtime build

## Building & Pushing
```bash
make v8lib ## make a pot of coffee while you wait for this to build
make dist
git commit -a -m 'v8.4'
git tag 8.4
git push origin master
git push --tags
```