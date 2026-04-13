# dev configuration

## setup a software

```bash
thing=bash # or any other tool in `setup/`
bash ./setup.sh $thing
```

### ...but i'm on Windows!

well, i'm guessing that you cloned this repo using `git`... `git` for Windows adds Mingw `bash`
during installation.

if you don't have git bash installed, or you're on unix and don't have bash, you can run
the corresponding script in `bootstrap/`
