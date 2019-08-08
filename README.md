# knife tidy
[![Gem Version](https://badge.fury.io/rb/knife-tidy.svg)](https://rubygems.org/gems/knife-tidy)
[![Build Status](https://travis-ci.org/chef/knife-tidy.svg?branch=master)](https://travis-ci.org/chef/knife-tidy)

**Umbrella Project**: [Knife](https://github.com/chef/chef-oss-practices/blob/master/projects/knife.md)

**Project State**: [Active](https://github.com/chef/chef-oss-practices/blob/master/repo-management/repo-states.md#active)

**Issues [Response Time Maximum](https://github.com/chef/chef-oss-practices/blob/master/repo-management/repo-states.md)**: 14 days

**Pull Request [Response Time Maximum](https://github.com/chef/chef-oss-practices/blob/master/repo-management/repo-states.md)**: 14 days

# Summary

NOTE: If you're a first-time or inexperienced knife-tidy user, we recommend you read through this blogpost before proceeding with the rest of this documentation: https://blog.chef.io/2017/10/16/migrating-chef-server-knife-ec-backup-knife-tidy/

This Chef Knife plugin provides:
 * Reports on the state of Chef Server objects that can be tidied up
 * Removal of stale nodes (and associated clients and ACLs) identified by the above Reports
 * A [knife-ec-backup](https://github.com/chef/knife-ec-backup) companion tool that will clean up data integrity issues in an object backup

# Requirements

A current Chef Client. Can easily be installed via [Chef DK](https://github.com/chef/chef-dk#installation)

# Installation

Via Rubygems
```bash
gem install knife-tidy
```

Via Source
```bash
git clone https://github.com/chef-customers/knife-tidy.git
cd knife-tidy
gem build knife-tidy.gemspec && gem install knife-tidy-*.gem --no-ri --no-rdoc
```

## Common Options

The following options are supported across all subcommands:

  * `--orgs ORG1,ORG2`:
    Only apply to objects in the named organizations (default: all orgs)

## $ knife tidy server report --help

Cookbooks and nodes account for the largest objects in your Chef Server.
If you want to keep it lean and mean and easy to port the object data, you must
tidy these unused objects up!

## Options

  * `--node-threshold NUM_DAYS`
    Maximum number of days since last checkin before node is considered stale (default: 30)

Example:
```bash
knife tidy server report --orgs brewinc,acmeinc --node-threshold 50
```

## Notes
  `server report` generates json reports as such:

File Name | Contents
--- | ---
org_threshold_numdays_stale_nodes.json | Nodes in that org that have not checked in for the number of days specified.
org_cookbook_count.json | Number of cookbook versions for each cookbook that that org.
org_unused_cookbooks.json | List of cookbooks and versions that do not appear to be in-use for that org. This is determined by checking the versioned run list of each of the nodes in the org.

The intended interpretation of the data in the above files is as such:

1. Determine a threshold of number of days since last check-in that is acceptable to deem a node "unused" and eligible for deletion. Use that number for `--node-threshold NUM_DAYS`
1. Delete those nodes older than threshold _and_ the unused cookbooks from the unused cookbooks list.
1. Re-run the report and this time more cookbooks might show up on the unused list after having cleared out the "stale" nodes.
1. Delete the unused cookbooks from the updated list of unused cookbooks.

Repeat the above periodically.

## $ knife tidy server clean --help
Remove stale nodes that haven't checked-in to the Chef Server as defined by the `--node-threshold NUM_DAYS` option when the reports were generated.. The associated client and ACLs are also removed.

## Options

  * `--backup-path /path/to/an-ec-backup`
    The location to the last backup of the target Chef Server. It is not recommended to run the clean command without first taking a current backup using [knife-ec-backup](https://github.com/chef/knife-ec-backup)

  * `--only-cookbooks`
    Only deletes the unused cookbooks from the target Chef Server. NOTE: Cannot be specified if `--only-nodes` is already specified

  * `--only-nodes`
    Only deletes the stale nodes, associated clients, and ACLs from the target Chef Server. NOTE: Cannot be specified if `--only-cookbooks` is already specified

  * `--dry-run`
    Do not perform any actual deletion, only report on what would have been deleted.

Example:
```bash
knife tidy server clean --orgs brewinc,acmeinc
```

## $ knife tidy backup clean --help

## Options

  * `--backup-path /path/to/an-ec-backup`:
    The Chef Repo to tidy up (such as one created from a [knife-ec-backup](https://github.com/chef/knife-ec-backup)

  * `--gsub-file /path/to/gsub/file`:
    The path to the file used for substitutions. If non-existent, a boiler plate one will be created.

Run the following example before attempting the `knife ec backup restore` operation:
```bash
knife tidy backup clean --gen-gsub
INFO: Creating boiler plate gsub file: 'substitutions.json'
knife tidy backup clean --backup-path backups/ --gsub-file substitutions.json
```

## Notes

  Global file substitutions can be performed when `--gsub-file` option is used. Several known issues are corrected
  and others can be added with search/replace pairings. The following boiler plate file is created for you when `--gen-gsub` is used:

```json
{
  "io-read-version-and-readme.md":{
    "organizations/*/cookbooks/*/metadata.rb":[
      {
        "pattern":"^version +IO.read.* 'VERSION'.*",
        "replace":"version !COOKBOOK_VERSION!"
      },
      {
        "pattern":"^long_description +IO.read.* 'README.md'.*",
        "replace":"#long_description \"A Long Description..\""
      }
    ]
  }
}
```

## $ knife tidy notify

The ```knife tidy notify```command is used to send a summary of the reports generated by ```knife tidy server report``` to your organization admins.

When run from the directory containing your reports, it will iterate through the reports for each organization in turn, and query the Chef server specified in your ```knife.rb``` for all admins of that organization.

It will then generate a summary email from your knife tidy reports, and email it to all admins for that organization.

This command assumes you have access to an SMTP server you can use for sending outgoing emails.

## Options

  * `--smtp_server `:
    The SMTP Server to use (defaults to localhost)
  * `--smtp_port `:
       The SMTP Port to be used (defaults to 25)  
  * `--smtp_username `:
       The SMTP Username to be used
  * `--smtp_password `:
       The SMTP Password to be used
  * `--smtp_from `:
       The From email address to be used when sending email reports
  * `--smtp_enable_tls `:
       Whether or not to enable TLS when sending reports via SMTP (defaults to false)            
  * `--smtp_helo `:
     The SMTP HELO to be used (defaults to localhost)

Run the following example before attempting the `knife ec backup restore` operation:
```bash
$> knife tidy notify --smtp_server smtp.myserver.com --smtp_port 587  --smtp_from myuser@myserver.com --smtp_username myuser --smtp_password mypassword --smtp_use_tls

Reading from /home/myuser/knife_tidy/reports directory
Fetching report data for organisation mytestorg
  Parsing file /home/myuser/knife_tidy/reports/mytestorg_unused_cookbooks.json
  Parsing file /home/myuser/knife_tidy/reports/mytestorg_cookbook_count.json
  Parsing file /home/myuser/knife_tidy/reports/mytestorg_stale_nodes.json
Fetching admins users for organisation mytestorg
Sending email reports for organisation mytestorg
```

## Summary and Credits

  * Server Report was ported from Nolan Davidson's [chef-cleanup](https://github.com/nsdavidson/chef-cleanup)
