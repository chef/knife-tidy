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

  * `--only-org ORG`:
    Only apply to objects in the named organization (default: all orgs)

  * `--repo-path /path/to/chef-repo`:
    The Chef Repo to report on or change (such as one created from a
    [knife-ec-backup](https://github.com/chef/knife-ec-backup)  (Optional)
    If this option is not specified, then `chef_server_url` is used from Chef::Config pointing to Chef Server.

## knife tidy `report` (options)

  * `--cookbooks-only`:
    Only report on cookbooks issues and/or usage.
    If --repo-path is not specified, a cookbook usage report from Chef Server is generated.

  * `--user-groups-only`:
    Only report on user and group membership issues.
    Applies only if --repo-path is specified

## knife tidy `apply` (options)

  * `--dry-run`:
    Report on all fixes that would be applied.

  * `--restore-default-acls`
    Restore defaults as specified by [knife-acl](https://github.com/chef/knife-acl#default-permissions-for-containers)
