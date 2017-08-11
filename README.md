# knife tidy

# Summary

This Chef Knife plugin has two primary purposes:
 * Report on the state of Chef Server objects that can be tidied up (Future: clean up objects)
 * Clean up data integrity issues from a object backup created by [knife-ec-backup](https://github.com/chef/knife-ec-backup)

# Requirements

A current Chef Client. Can easily be installed via [Chef DK](https://github.com/chef/chef-dk#installation)

# Installation

Via Gem
```bash
gem install knife-tidy
```

Via Source
```bash
git clone https://github.com/jeremymv2/knife-tidy.git
cd knife-tidy
gem build knife-tidy.gemspec && gem install knife-tidy-*.gem --no-ri --no-rdoc
```

## Common Options

The following options are supported across all subcommands:

  * `--orgs ORG1,ORG2`:
    Only apply to objects in the named organizations (default: all orgs)

# knife tidy server report (options)

## Options

  * `--node-threshold NUM_DAYS`
    Maximum number of days since last checkin before node is considered stale (default: 30)

## Notes
  Generates json reports as such:

File Name | Contents
--- | ---
org_threshold_numdays_stale_nodes.json | Nodes in that org that have not checked in for the number of days specified.
org_cookbook_count.json | Number of cookbook versions for each cookbook that that org.
org_unused_cookbooks.json | List of cookbooks and versions that do not appear to be in-use for that org. This is determined by checking the versioned run list of each of the nodes in the org.

# knife tidy backup clean (options)

## Options

  * `--repo-path /path/to/chef-repo`:
    The Chef Repo to tidy up (such as one created from a [knife-ec-backup](https://github.com/chef/knife-ec-backup)

  * `--gsub-file path/to/gsub/file`:
    The path to the file used for substitutions. If non-existant, a boiler plate one will be created.

## Notes

  * Items addressed and remaining [To Do](TODO_LIST.md)

  Global file substitutions can be performed when `--gsub-file` option is used. Several known issues are corrected
  and others can be added with search/replace pairings:

  * DONE: global glob'd file gsub definitions

```json
{
  "chef-sugar":{
    "organizations/*/cookbooks/chef-sugar*/metadata.rb":[
      {
        "pattern":"require +File.expand_path('../lib/chef/sugar/version', __FILE__)",
        "replace":"# require          File.expand_path('../lib/chef/sugar/version', __FILE__)"
      },
      {
        "pattern":"version *Chef::Sugar::VERSION",
        "replace":"# version          !COOKBOOK_VERSION!"
      }
    ]
  }
}
```

  * DONE: metadata validation with `Chef::CookbookLoader`
  * DONE: metadata.rb and metadata.json inconsistencies correction
  * DONE: metadata self-dependency correction
  * TODO: ambiguous actors (acl actor exists as client and user)
  * TODO: user email validation
  * TODO: users/clients referenced as actors in acls that do not exist in users/clients
  * TODO: nonexistent groups referenced in acls

## Summary and Credits

  * Server Report was ported from Nolan Davidson's [chef-cleanup](https://github.com/nsdavidson/chef-cleanup)
