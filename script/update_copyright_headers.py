import argparse
import textwrap
import datetime
import re
import sys
from pathlib import Path
from dataclasses import dataclass


@dataclass
class Copyright:
    """Dataclass to hold the default copyright information."""

    year: str = str(datetime.datetime.now().year)
    project: str = "Robustimizer"
    holder: str = "Omid Nejadseyfi"


def update_file_copyright_header(
    filename: Path, new_copyright_info: Copyright, default_header=None, force=False
):
    """Updates the copyright year in the header or adds a new header if none is found."""

    context_lines = 30
    contents = filename.read_text()
    if has_copyright(contents, new_copyright_info.project):
        new_contents = update_copyright_years(contents, new_copyright_info.year)
    else:
        new_header = prefix_comment_char(default_header.split("\n"))
        new_contents = "\n".join(new_header) + "\n" + contents

    if force or new_contents != contents:
        print(f"Updating file: {filename}")
        update_file(filename, new_contents)
    else:
        print(f"No changes needed in file: {filename}")


def update_file(filename: Path, new_contents: str):
    """Write the new contents to the file."""
    # For now, just overwrite the file. A more robust strategy would be
    # to write to a temporary file and then swap with the original file.
    filename.write_text(new_contents)


def has_copyright(contents, project_name):
    """Checks whether the given contents contain a copyright text in the header."""
    max_len = min(len(contents), 2000)
    return "Copyright" in contents[:max_len] and project_name in contents[:max_len]


def update_copyright_years(contents, new_copyright_year, nr_of_matches=1):
    """Update the years in the given header lines."""
    regexp = re.compile(r"Copyright \(c\) ([0-9,\- ]+)", re.IGNORECASE)

    def _update_copyright_years(match, new_copyright_year):
        years = set(y.strip() for y in re.split(",|-", match.group(1)))
        years.add(str(new_copyright_year))
        years = sorted(years)
        if len(years) > 1:
            years_txt = f"{years[0]}-{years[-1]}"
        else:
            years_txt = years[0]
        return f"Copyright (c) {years_txt} "

    new_contents = regexp.sub(
        lambda m: _update_copyright_years(m, new_copyright_year),
        contents,
        count=nr_of_matches,
    )
    return new_contents


def read_template(template_file=None):
    """Read the template file from "copyrightheader.txt"."""
    if not template_file:
        template_file = Path(__file__).parent / "copyrightheader.txt"
    with open(template_file, "r") as file:
        return file.read()


def generate_copyright_text(template, copyright_info):
    """Format the template with the copyright information."""
    return template.format(
        year=copyright_info.year,
        project=copyright_info.project,
        holder=copyright_info.holder,
    )


def prefix_comment_char(lines: list[str], comment_prefix: str = "%") -> list[str]:
    """Add comment characters to the given lines."""
    return [f"{comment_prefix} {line}" for line in lines]


def is_excluded(file: Path, exclude_files: list[str]) -> bool:
    """Check if the filename is in the list of excluded files."""
    f = file.relative_to(Path(__file__).parent.parent)
    dirname = str(f.parent)
    filename = str(f.name)
    if any(dirname.startswith(exclude) for exclude in exclude_files):
        return True
    return filename in exclude_files


def main():
    description = textwrap.dedent(
        """
        Update the copyright header of source files.

        When a copyright header is _not_ found in a file, it will be added.
        When a copyright header _is_ found in a file, its year will be updated (if needed).

    """
    ).strip()
    dedent = lambda s: textwrap.dedent(s).strip()

    def_cr = Copyright()
    parser = argparse.ArgumentParser(description=description)
    parser.add_argument(
        "--year",
        help=f"The copyright year (to update to). Defaults to the current year ({def_cr.year}).",
    )
    parser.add_argument(
        "--project", help=f"The project name. Defaults to '{def_cr.project}'."
    )
    parser.add_argument(
        "--holder",
        help=f"The copyright holder, if not yet present. Defaults to '{def_cr.holder}'.",
    )
    parser.add_argument(
        "--template",
        help="An alternative template file to use for the copyright header.",
        default=None,
    )
    parser.add_argument(
        "--exclude-file",
        help="A file containing a list of filenames to exclude from updating.",
        default=Path(__file__).parent / "excludes.txt",
    )
    parser.add_argument(
        "--force",
        help="Update the header even if it is already up-to-date.",
        action="store_true",
    )
    parser.add_argument(
        "--dry-run",
        help="Print the files that would be updated, but do not update them.",
        action="store_true",
    )
    parser.add_argument(
        "filenames",
        nargs="*",
        help="The files to update the header in. When not specified, all files in the current directory will be updated (recursively).",
    )
    args = parser.parse_args()

    copyright_info = Copyright(
        year=args.year or def_cr.year,
        project=args.project or def_cr.project,
        holder=args.holder or def_cr.holder,
    )
    default_text = generate_copyright_text(read_template(), copyright_info)

    if not args.filenames:
        # No filenames specified, update all files in the current directory.
        # Exclude files if specified.
        exclude_files = []
        if args.exclude_file:
            with open(args.exclude_file, "r") as file:
                exclude_files = [line.strip() for line in file]
                exclude_files = [f for f in exclude_files if f and not f.startswith("#")]

        print(
            f"Updating all files in the current directory (excluding those mentioned in {args.exclude_file}):"
        )
        args.filenames = [
            f
            for f in Path(".").rglob("*")
            if f.is_file() and f.suffix in [".m"] and not is_excluded(f.absolute(), exclude_files)
        ]

    print(f"Updating {len(args.filenames)} files")
    if args.dry_run:
        print("\n".join(str(f) for f in args.filenames))
        exit(0)

    for filename in args.filenames:
        update_file_copyright_header(filename, copyright_info, default_text, force=args.force)


if __name__ == "__main__":
    main()
