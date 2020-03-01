0.11.0 (2020-01-28)
=======

This release goes together with simplecov 0.18 to bring branch coverage support to you. Please also check the notes of the beta releases.

## Enhancements
* Display total branch coverage percentage in the overview (if branch coverage enabled)

0.11.0.beta2 (2020-01-19)
=======

## Enhancements
* changed display of branch coverage to be `branch_type: hit_count` which should be more expressive and more intuitive
* Cached lookup of whether we're doing branch coverage or not (should be faster)

## Bugfixes
* Fixed sorting of percent column (regression in previous release)

0.11.0.beta1 (2020-01-05)
========

Changes ruby support to 2.4+, adds branch coverage support. Meant to be used with simplecov 0.18

## Breaking Changes
* Drops support for EOL'ed ruby versions, new support is ~> 2.4

## Enhancements
* Support/display of branch coverage from simplecov 0.18.0.beta1, little badges saying `hit_count, positive_or_negative` will appear next to lines if branch coverage is activated. `0, +` means positive branch was never hit, `2, -` means negative branch was hit twice
* Encoding compatibility errors are now caught and printed out

0.10.2 (2017-08-14)
========

## Bugfixes

* Allow usage with frozen-string-literal-enabled. See [#56](https://github.com/colszowka/simplecov-html/pull/56) (thanks @pat)

0.10.1 (2017-05-17)
========

## Bugfixes

* circumvent a regression that happens in the new JRuby 9.1.9.0 release. See [#53](https://github.com/colszowka/simplecov-html/pull/53) thanks @koic
