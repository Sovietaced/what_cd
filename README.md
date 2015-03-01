# what_cd
What.CD uploader toolkit that makes your uploads squaky clean.

## Installation
```bash
gem install what_cd
```
Create a default config file
```bash
cp what_cd/etc/.what_cd ~/.what_cd
```

## Usage
To sanitize a release. Sanitizing a release will iterate over a number of plugins under lib/what_cd/sanitize_plugins. Each plugin may modify the files themselves, the file names, or the directory name to adhere to What.CD guidelines. They may also throw errors if there is an issue with the upload ie. mutt rup.
```bash
what_cd sanitize [dir]
```

## License

Please see LICENSE at the top level of the repository.
