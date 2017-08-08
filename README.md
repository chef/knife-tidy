# knife tidy

# Description

This tool is intended to be used to report on the state of Chef Server objects that can be tidied up.
It can also help by applying some general good ol' fashioned tidiness if desired.

# Requirements

Chef Client - any modern version.  Can easily be installed via [Chef DK](https://github.com/chef/chef-dk#installation)

# Installation

Via Gem
```bash
gem install knife-tidy
```

## Common Options

The following options are supported across all subcommands:

  * `--orgs ORG1,ORG2`:
    Only apply to objects in the named organizations (default: all orgs)

## knife tidy `server report` (options)

### Options

  * `--node-threshold NUM_DAYS`
    Maximum number of days since last checkin before node is considered stale (default: 30)

### `server report` Description

## knife tidy `backup report` (options)

### Options

  * `--repo-path /path/to/chef-repo`:
    The Chef Repo to report on or change (such as one created from a
    [knife-ec-backup](https://github.com/chef/knife-ec-backup)

### `backup report` Description

## knife tidy `backup clean` (options)

  * `--cookbooks-only`:
    Only report on cookbooks issues and/or usage.
    If --repo-path is not specified, a cookbook usage report from Chef Server is generated.

  * `--user-groups-only`:
    Only report on user and group membership issues.
    Applies only if --repo-path is specified
