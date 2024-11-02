# Common development tasks

## Updating / adding copyright notices to source files

The project uses a script to update the copyright notice in all source files. The script is located in the `scripts` directory and is called `update_copyright_headers.py`.

To update the copyright notice in all source files, run the script from the root of the project:

```bash
python scripts/update_copyright_headers.py
```

The script will add the copyright notice to all source files that do not already contain it. For files that already contain the notice, the script will update the year range to include the current year. Running this script at the start of a new year will update all files to include the new year, ensuring that the copyright notice is up to date. If a copyright notice is present and up to date, the script will not modify the file.

The copyright notice is defined in the `scripts/copyright_header.txt` file. You can modify this file to change the text of the notice (for new files).

Files that need to be explictly excluded by the script can be added to the `scripts/exclude_files.txt` file. This is useful for files that should not have the copyright notice updated, e.g. because they come from a third-party source.

The script accepts several command-line arguments to control its behavior, use the `--help` flag to see the available options:

```bash
python scripts/update_copyright_headers.py --help
```
