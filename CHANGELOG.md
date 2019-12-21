<!-- usage documentation: http://expeditor-docs.es.chef.io/configuration/changelog/ -->
# Change Log
<!-- latest_release 2.0.9 -->
## [v2.0.9](https://github.com/chef/knife-tidy/tree/v2.0.9) (2019-12-21)

#### Merged Pull Requests
- Substitute require for require_relative [#111](https://github.com/chef/knife-tidy/pull/111) ([tas50](https://github.com/tas50))
<!-- latest_release -->

<!-- release_rollup since=2.0.6 -->
### Changes not yet released to rubygems.org

#### Merged Pull Requests
- Substitute require for require_relative [#111](https://github.com/chef/knife-tidy/pull/111) ([tas50](https://github.com/tas50)) <!-- 2.0.9 -->
- Fix some test failures [#113](https://github.com/chef/knife-tidy/pull/113) ([tas50](https://github.com/tas50)) <!-- 2.0.8 -->
- Migrate testing to Buildkite [#112](https://github.com/chef/knife-tidy/pull/112) ([tas50](https://github.com/tas50)) <!-- 2.0.7 -->
<!-- release_rollup -->

<!-- latest_stable_release -->
## [v2.0.6](https://github.com/chef/knife-tidy/tree/v2.0.6) (2019-12-04)

#### Merged Pull Requests
- adding some clarifications and spelling corrections to the README [#102](https://github.com/chef/knife-tidy/pull/102) ([jeremymv2](https://github.com/jeremymv2))
- Update README for OSS Best Practices [#104](https://github.com/chef/knife-tidy/pull/104) ([dheerajd-msys](https://github.com/dheerajd-msys))
- Fix cookbook_version_from_path failing when the org is named &quot;cookbooks&quot; [#106](https://github.com/chef/knife-tidy/pull/106) ([tas50](https://github.com/tas50))
- Improve error message about search index being out of date [#89](https://github.com/chef/knife-tidy/pull/89) ([jblaine](https://github.com/jblaine))
- Chefstyle fixes [#110](https://github.com/chef/knife-tidy/pull/110) ([tas50](https://github.com/tas50))
<!-- latest_stable_release -->

## [v2.0.1](https://github.com/chef/knife-tidy/tree/v2.0.1) (2019-02-07)

#### Merged Pull Requests
- adding missing assignment operator [#101](https://github.com/chef/knife-tidy/pull/101) ([jeremymv2](https://github.com/jeremymv2))
- Require Ruby 2.3+ and resolve all chefstyle warnings [#99](https://github.com/chef/knife-tidy/pull/99) ([tas50](https://github.com/tas50))

## [v2.0.0](https://github.com/chef/knife-tidy/tree/v2.0.0) (2019-01-16)

#### Merged Pull Requests
- Wire up Expeditor [#94](https://github.com/chef/knife-tidy/pull/94) ([tas50](https://github.com/tas50))
- Add gem and travis badges to the readme [#95](https://github.com/chef/knife-tidy/pull/95) ([tas50](https://github.com/tas50))
- Add contributing doc [#96](https://github.com/chef/knife-tidy/pull/96) ([tas50](https://github.com/tas50))
- Add Ruby 2.6 testing and use our standard gemfile groups [#98](https://github.com/chef/knife-tidy/pull/98) ([tas50](https://github.com/tas50))
- Require Ruby 2.3+ and resolve all chefstyle warnings [#99](https://github.com/chef/knife-tidy/pull/99) ([tas50](https://github.com/tas50))

## [1.2.0](https://github.com/chef-customers/knife-tidy/tree/1.2.0) (2018-05-17)
[Full Changelog](https://github.com/chef-customers/knife-tidy/compare/1.1.0...1.2.0)

**Closed issues:**

- notifications fail for chef orgs containing an underscore [\#77](https://github.com/chef-customers/knife-tidy/issues/77)
- Add option to attach raw JSON report files to the email notification [\#75](https://github.com/chef-customers/knife-tidy/issues/75)

**Merged pull requests:**

- bump to 1.2.0 [\#85](https://github.com/chef-customers/knife-tidy/pull/85) ([jeremymv2](https://github.com/jeremymv2))
- fix empty clients group [\#84](https://github.com/chef-customers/knife-tidy/pull/84) ([jeremymv2](https://github.com/jeremymv2))

## [1.1.0](https://github.com/chef-customers/knife-tidy/tree/1.1.0) (2018-01-11)
[Full Changelog](https://github.com/chef-customers/knife-tidy/compare/1.0.1...1.1.0)

**Closed issues:**

- the backup-path should default to current working directory [\#79](https://github.com/chef-customers/knife-tidy/issues/79)

**Merged pull requests:**

- Jjh/fix notification reports [\#80](https://github.com/chef-customers/knife-tidy/pull/80) ([itmustbejj](https://github.com/itmustbejj))

## [1.0.1](https://github.com/chef-customers/knife-tidy/tree/1.0.1) (2017-12-12)
[Full Changelog](https://github.com/chef-customers/knife-tidy/compare/1.0.0...1.0.1)

**Closed issues:**

- Clean up references to tidy methods [\#68](https://github.com/chef-customers/knife-tidy/issues/68)
- A stale search index can generate inaccurate tidy reports [\#62](https://github.com/chef-customers/knife-tidy/issues/62)

**Merged pull requests:**

- Fix validate\_user\_acls and default\_user\_acl methods [\#73](https://github.com/chef-customers/knife-tidy/pull/73) ([itmustbejj](https://github.com/itmustbejj))

## [1.0.0](https://github.com/chef-customers/knife-tidy/tree/1.0.0) (2017-12-04)
[Full Changelog](https://github.com/chef-customers/knife-tidy/compare/0.7.0...1.0.0)

**Merged pull requests:**

- Enabled cookbook deletion [\#71](https://github.com/chef-customers/knife-tidy/pull/71) ([itmustbejj](https://github.com/itmustbejj))
- Add option for backup path to server clean [\#70](https://github.com/chef-customers/knife-tidy/pull/70) ([TheLunaticScripter](https://github.com/TheLunaticScripter))
- Warn the user if there are nodes created in the last hour that haven'… [\#67](https://github.com/chef-customers/knife-tidy/pull/67) ([itmustbejj](https://github.com/itmustbejj))
- Add guard to skip generating org reports if the search index is not u… [\#66](https://github.com/chef-customers/knife-tidy/pull/66) ([itmustbejj](https://github.com/itmustbejj))
- Enable server clean command and clarify confirmation dialogue [\#31](https://github.com/chef-customers/knife-tidy/pull/31) ([jonlives](https://github.com/jonlives))

## [0.7.0](https://github.com/chef-customers/knife-tidy/tree/0.7.0) (2017-11-29)
[Full Changelog](https://github.com/chef-customers/knife-tidy/compare/0.6.1...0.7.0)

**Closed issues:**

- Users/clients from backups older than CS 12.5 may be missing read acls on clients [\#63](https://github.com/chef-customers/knife-tidy/issues/63)
- notify subcommand ignores --orgs option [\#59](https://github.com/chef-customers/knife-tidy/issues/59)

**Merged pull requests:**

- release 0.7.0 [\#65](https://github.com/chef-customers/knife-tidy/pull/65) ([jeremymv2](https://github.com/jeremymv2))
- Add admins/users groups to the read acl for clients from \< CS 12.5 [\#64](https://github.com/chef-customers/knife-tidy/pull/64) ([itmustbejj](https://github.com/itmustbejj))
- Restore acls for ::server-admins and org read access groups if they a… [\#61](https://github.com/chef-customers/knife-tidy/pull/61) ([itmustbejj](https://github.com/itmustbejj))
- Filter email notifications on org\_list config option. [\#60](https://github.com/chef-customers/knife-tidy/pull/60) ([itmustbejj](https://github.com/itmustbejj))
- Set default encoding to utf-8 to properly handle non-ascii in backups. [\#58](https://github.com/chef-customers/knife-tidy/pull/58) ([itmustbejj](https://github.com/itmustbejj))
- Add check for pre-12.3 nodes to report generation… [\#57](https://github.com/chef-customers/knife-tidy/pull/57) ([jonlives](https://github.com/jonlives))
- bump path to 0.6.1 [\#55](https://github.com/chef-customers/knife-tidy/pull/55) ([jeremymv2](https://github.com/jeremymv2))

## [0.6.1](https://github.com/chef-customers/knife-tidy/tree/0.6.1) (2017-10-26)
[Full Changelog](https://github.com/chef-customers/knife-tidy/compare/0.6.0...0.6.1)

**Closed issues:**

- knife tidy server clean - org names with \_ [\#53](https://github.com/chef-customers/knife-tidy/issues/53)

**Merged pull requests:**

- fixing orgs with underscores [\#54](https://github.com/chef-customers/knife-tidy/pull/54) ([jeremymv2](https://github.com/jeremymv2))
- Jeremymv2/release 0 6 0 [\#52](https://github.com/chef-customers/knife-tidy/pull/52) ([jeremymv2](https://github.com/jeremymv2))

## [0.6.0](https://github.com/chef-customers/knife-tidy/tree/0.6.0) (2017-10-23)
[Full Changelog](https://github.com/chef-customers/knife-tidy/compare/0.5.2...0.6.0)

**Merged pull requests:**

- fix travis [\#51](https://github.com/chef-customers/knife-tidy/pull/51) ([jeremymv2](https://github.com/jeremymv2))
- Add knife tidy notify command [\#50](https://github.com/chef-customers/knife-tidy/pull/50) ([jonlives](https://github.com/jonlives))
- bump to 0.5.2 [\#49](https://github.com/chef-customers/knife-tidy/pull/49) ([jeremymv2](https://github.com/jeremymv2))

## [0.5.2](https://github.com/chef-customers/knife-tidy/tree/0.5.2) (2017-10-20)
[Full Changelog](https://github.com/chef-customers/knife-tidy/compare/0.5.1...0.5.2)

**Merged pull requests:**

- fixing regex for whitespace [\#48](https://github.com/chef-customers/knife-tidy/pull/48) ([jeremymv2](https://github.com/jeremymv2))
- bump patch to 0.5.1 [\#47](https://github.com/chef-customers/knife-tidy/pull/47) ([jeremymv2](https://github.com/jeremymv2))

## [0.5.1](https://github.com/chef-customers/knife-tidy/tree/0.5.1) (2017-10-19)
[Full Changelog](https://github.com/chef-customers/knife-tidy/compare/0.5.0...0.5.1)

**Merged pull requests:**

- Add node\_count to stale node json output. [\#46](https://github.com/chef-customers/knife-tidy/pull/46) ([MarkGibbons](https://github.com/MarkGibbons))
- bump to 0.5.0 [\#45](https://github.com/chef-customers/knife-tidy/pull/45) ([jeremymv2](https://github.com/jeremymv2))

## [0.5.0](https://github.com/chef-customers/knife-tidy/tree/0.5.0) (2017-10-06)
[Full Changelog](https://github.com/chef-customers/knife-tidy/compare/0.4.1...0.5.0)

**Closed issues:**

- Supermarket.chef.io [\#37](https://github.com/chef-customers/knife-tidy/issues/37)

**Merged pull requests:**

- enabling deletion of stale nodes [\#44](https://github.com/chef-customers/knife-tidy/pull/44) ([jeremymv2](https://github.com/jeremymv2))
- better warning message before confirmation [\#43](https://github.com/chef-customers/knife-tidy/pull/43) ([jeremymv2](https://github.com/jeremymv2))
- Jeremymv2/chef sugar fix default [\#42](https://github.com/chef-customers/knife-tidy/pull/42) ([jeremymv2](https://github.com/jeremymv2))
- deleting nodes also deletes client [\#41](https://github.com/chef-customers/knife-tidy/pull/41) ([jeremymv2](https://github.com/jeremymv2))
- Change nodes\_list method to get all nodes [\#40](https://github.com/chef-customers/knife-tidy/pull/40) ([nsdavidson](https://github.com/nsdavidson))
- bump version to 0.4.1 [\#39](https://github.com/chef-customers/knife-tidy/pull/39) ([jeremymv2](https://github.com/jeremymv2))

## [0.4.1](https://github.com/chef-customers/knife-tidy/tree/0.4.1) (2017-09-27)
[Full Changelog](https://github.com/chef-customers/knife-tidy/compare/0.4.0...0.4.1)

**Merged pull requests:**

- fixing corrupt invitations and invalid platform names with commas in … [\#38](https://github.com/chef-customers/knife-tidy/pull/38) ([jeremymv2](https://github.com/jeremymv2))
- bump to 0.4.0 [\#36](https://github.com/chef-customers/knife-tidy/pull/36) ([jeremymv2](https://github.com/jeremymv2))

## [0.4.0](https://github.com/chef-customers/knife-tidy/tree/0.4.0) (2017-09-26)
[Full Changelog](https://github.com/chef-customers/knife-tidy/compare/0.3.6...0.4.0)

**Merged pull requests:**

- fix NilClass on env\_run\_lists [\#35](https://github.com/chef-customers/knife-tidy/pull/35) ([jeremymv2](https://github.com/jeremymv2))
- fix merge conflict from rebase [\#34](https://github.com/chef-customers/knife-tidy/pull/34) ([jeremymv2](https://github.com/jeremymv2))
- Simple feature to clean up EC11 org objects which don't load into CS12 [\#33](https://github.com/chef-customers/knife-tidy/pull/33) ([irvingpop](https://github.com/irvingpop))
- role run\_list clean up and metadata name regex simplification [\#32](https://github.com/chef-customers/knife-tidy/pull/32) ([jeremymv2](https://github.com/jeremymv2))
- bump to 0.3.6 [\#30](https://github.com/chef-customers/knife-tidy/pull/30) ([jeremymv2](https://github.com/jeremymv2))

## [0.3.6](https://github.com/chef-customers/knife-tidy/tree/0.3.6) (2017-09-25)
[Full Changelog](https://github.com/chef-customers/knife-tidy/compare/0.3.5...0.3.6)

**Merged pull requests:**

- first check if the\_user.has\_key?\('email'\) [\#29](https://github.com/chef-customers/knife-tidy/pull/29) ([jeremymv2](https://github.com/jeremymv2))
- bump to 0.3.5 [\#28](https://github.com/chef-customers/knife-tidy/pull/28) ([jeremymv2](https://github.com/jeremymv2))

## [0.3.5](https://github.com/chef-customers/knife-tidy/tree/0.3.5) (2017-09-20)
[Full Changelog](https://github.com/chef-customers/knife-tidy/compare/0.3.4...0.3.5)

**Merged pull requests:**

- Catch pins with no cookbooks [\#27](https://github.com/chef-customers/knife-tidy/pull/27) ([nsdavidson](https://github.com/nsdavidson))

## [0.3.4](https://github.com/chef-customers/knife-tidy/tree/0.3.4) (2017-09-16)
[Full Changelog](https://github.com/chef-customers/knife-tidy/compare/0.3.3...0.3.4)

**Merged pull requests:**

- check if metadata.has\_key?\('platforms'\) [\#26](https://github.com/chef-customers/knife-tidy/pull/26) ([jeremymv2](https://github.com/jeremymv2))

## [0.3.3](https://github.com/chef-customers/knife-tidy/tree/0.3.3) (2017-09-15)
[Full Changelog](https://github.com/chef-customers/knife-tidy/compare/0.3.2...0.3.3)

**Merged pull requests:**

- boiler plate gsub file now works [\#25](https://github.com/chef-customers/knife-tidy/pull/25) ([jeremymv2](https://github.com/jeremymv2))
- fixing null values and emtpy arrays in metadata.json [\#24](https://github.com/chef-customers/knife-tidy/pull/24) ([jeremymv2](https://github.com/jeremymv2))
- Jeremyv2/action needed notification [\#23](https://github.com/chef-customers/knife-tidy/pull/23) ([jeremymv2](https://github.com/jeremymv2))

## [0.3.2](https://github.com/chef-customers/knife-tidy/tree/0.3.2) (2017-09-14)
[Full Changelog](https://github.com/chef-customers/knife-tidy/compare/0.3.1...0.3.2)

**Merged pull requests:**

- fixed name mismatch in metadata.json [\#22](https://github.com/chef-customers/knife-tidy/pull/22) ([jeremymv2](https://github.com/jeremymv2))

## [0.3.1](https://github.com/chef-customers/knife-tidy/tree/0.3.1) (2017-09-14)
[Full Changelog](https://github.com/chef-customers/knife-tidy/compare/0.3.0...0.3.1)

**Merged pull requests:**

- generate a metadata.rb if needed [\#21](https://github.com/chef-customers/knife-tidy/pull/21) ([jeremymv2](https://github.com/jeremymv2))
- newline for action needed messages [\#20](https://github.com/chef-customers/knife-tidy/pull/20) ([jeremymv2](https://github.com/jeremymv2))

## [0.3.0](https://github.com/chef-customers/knife-tidy/tree/0.3.0) (2017-09-14)
[Full Changelog](https://github.com/chef-customers/knife-tidy/compare/0.2.4...0.3.0)

**Closed issues:**

- FATAL: Cannot find subcommand for: 'tidy backup clean' [\#12](https://github.com/chef-customers/knife-tidy/issues/12)

**Merged pull requests:**

- bump to 0.3.0 [\#19](https://github.com/chef-customers/knife-tidy/pull/19) ([jeremymv2](https://github.com/jeremymv2))
- added dry-run to server clean [\#18](https://github.com/chef-customers/knife-tidy/pull/18) ([jeremymv2](https://github.com/jeremymv2))

## [0.2.4](https://github.com/chef-customers/knife-tidy/tree/0.2.4) (2017-09-12)
[Full Changelog](https://github.com/chef-customers/knife-tidy/compare/0.2.3...0.2.4)

**Merged pull requests:**

- disable server clean [\#17](https://github.com/chef-customers/knife-tidy/pull/17) ([jeremymv2](https://github.com/jeremymv2))
- bump patch to 0.2.4 [\#16](https://github.com/chef-customers/knife-tidy/pull/16) ([jeremymv2](https://github.com/jeremymv2))
- correct any cookbook metadata name issues [\#15](https://github.com/chef-customers/knife-tidy/pull/15) ([jeremymv2](https://github.com/jeremymv2))

## [0.2.3](https://github.com/chef-customers/knife-tidy/tree/0.2.3) (2017-09-11)
[Full Changelog](https://github.com/chef-customers/knife-tidy/compare/0.2.2...0.2.3)

**Merged pull requests:**

- setting required ruby to \>= 2.0.0 [\#14](https://github.com/chef-customers/knife-tidy/pull/14) ([jeremymv2](https://github.com/jeremymv2))

## [0.2.2](https://github.com/chef-customers/knife-tidy/tree/0.2.2) (2017-09-11)
[Full Changelog](https://github.com/chef-customers/knife-tidy/compare/0.2.1...0.2.2)

**Merged pull requests:**

- Jeremymv2/fix to i [\#13](https://github.com/chef-customers/knife-tidy/pull/13) ([jeremymv2](https://github.com/jeremymv2))
- release 0.2.1 [\#11](https://github.com/chef-customers/knife-tidy/pull/11) ([jeremymv2](https://github.com/jeremymv2))

## [0.2.1](https://github.com/chef-customers/knife-tidy/tree/0.2.1) (2017-09-01)
[Full Changelog](https://github.com/chef-customers/knife-tidy/compare/0.2.0...0.2.1)

**Merged pull requests:**

- first round of tests [\#10](https://github.com/chef-customers/knife-tidy/pull/10) ([jeremymv2](https://github.com/jeremymv2))
- Add environment checking for unused cookbook list [\#9](https://github.com/chef-customers/knife-tidy/pull/9) ([nsdavidson](https://github.com/nsdavidson))
- disable [\#8](https://github.com/chef-customers/knife-tidy/pull/8) ([jeremymv2](https://github.com/jeremymv2))
- server object deletion [\#7](https://github.com/chef-customers/knife-tidy/pull/7) ([jeremymv2](https://github.com/jeremymv2))
- bump version to 0.2.0 [\#6](https://github.com/chef-customers/knife-tidy/pull/6) ([jeremymv2](https://github.com/jeremymv2))

## [0.2.0](https://github.com/chef-customers/knife-tidy/tree/0.2.0) (2017-08-16)
[Full Changelog](https://github.com/chef-customers/knife-tidy/compare/0.1.1...0.2.0)

**Merged pull requests:**

- moved all common functions to tidy\_common.rb [\#5](https://github.com/chef-customers/knife-tidy/pull/5) ([jeremymv2](https://github.com/jeremymv2))
- Jeremymv2/acl items [\#4](https://github.com/chef-customers/knife-tidy/pull/4) ([jeremymv2](https://github.com/jeremymv2))
- updated changelog [\#3](https://github.com/chef-customers/knife-tidy/pull/3) ([jeremymv2](https://github.com/jeremymv2))
- bump version to 0.1.1 [\#2](https://github.com/chef-customers/knife-tidy/pull/2) ([jeremymv2](https://github.com/jeremymv2))



\* *This Change Log was automatically generated by [github_changelog_generator](https://github.com/skywinder/Github-Changelog-Generator)*