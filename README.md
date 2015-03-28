# what_cd
What.CD uploader toolkit that makes your uploads squeaky clean.

## Installation
```bash
gem install what_cd
```
Create a default config file
```bash
cp what_cd/etc/.what_cd ~/.what_cd
```

## Usage
```bash
what_cd sanitize [dir]
```
Sanitizing a release will iterate over a number of plugins under lib/what_cd/sanitize_plugins. Each plugin may modify the files themselves, the file names, or the directory name to adhere to What.CD guidelines. They may also throw errors if there is an issue with the upload ie. a mutt rip.

```bash
what_cd metadata [dir]
```
The metadata command will generate metadata about the release information that makes it easy to fill out the upload form.

## License

Please see LICENSE at the top level of the repository.
