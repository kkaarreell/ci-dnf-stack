@fixture.httpd
Feature: Tests for reposync command


Background:
  Given I enable plugin "reposync"


Scenario: Base functionality of reposync
  Given I use the http repository based on "dnf-ci-thirdparty-updates"
   When I execute dnf with args "reposync --download-path={context.dnf.tempdir}"
   Then the exit code is 0
    And stdout contains ": SuperRipper-1\.2-1\."
    And stdout contains ": SuperRipper-1\.3-1\."
    And the files "{context.dnf.tempdir}/http-dnf-ci-thirdparty-updates/x86_64/CQRlib-extension-1.6-2.x86_64.rpm" and "{context.dnf.fixturesdir}/repos/dnf-ci-thirdparty-updates/x86_64/CQRlib-extension-1.6-2.x86_64.rpm" do not differ


Scenario: Reposync with --newest-only option
  Given I use the http repository based on "dnf-ci-thirdparty-updates"
   When I execute dnf with args "reposync --download-path={context.dnf.tempdir} --newest-only"
   Then the exit code is 0
    And stdout contains ": SuperRipper-1\.3-1\."
    And stdout does not contain ": SuperRipper-1\.2-1\."


@bz1653126 @bz1676726
Scenario: Reposync with --downloadcomps option
  Given I use the http repository based on "dnf-ci-thirdparty-updates"
   When I execute dnf with args "reposync --download-path={context.dnf.tempdir} --downloadcomps"
   Then the exit code is 0
    And stdout contains "comps.xml for repository http-dnf-ci-thirdparty-updates saved"
    And the files "{context.dnf.tempdir}/http-dnf-ci-thirdparty-updates/comps.xml" and "{context.dnf.fixturesdir}/repos/dnf-ci-thirdparty-updates/repodata/comps.xml" do not differ
   When I execute bash with args "createrepo_c --no-database --simple-md-filenames --groupfile comps.xml ." in directory "{context.dnf.tempdir}/http-dnf-ci-thirdparty-updates"
   Then the exit code is 0
  Given I create and substitute file "/etc/yum.repos.d/test.repo" with
  """
  [testrepo]
  name=testrepo
  baseurl={context.dnf.tempdir}/http-dnf-ci-thirdparty-updates
  enabled=1
  gpgcheck=0
  """
    And I do not set reposdir
    And I disable the repository "http-dnf-ci-thirdparty-updates"
    And I use the repository "testrepo"
   When I execute dnf with args "group list"
   Then the exit code is 0
    And stdout matches line by line
   """
   ?Last metadata expiration check
   ?testrepo
   Available Groups:
   DNF-CI-Testgroup
   """


@bz1676726
Scenario: Reposync with --downloadcomps option (comps.xml in repo does not exist)
  Given I use the http repository based on "dnf-ci-rich"
   When I execute dnf with args "reposync --download-path={context.dnf.tempdir} --downloadcomps"
   Then the exit code is 0
    And stdout does not contain "comps.xml for repository http-dnf-ci-rich saved"


@bz1676726
Scenario: Reposync with --downloadcomps and --metadata-path options
  Given I use the http repository based on "dnf-ci-thirdparty-updates"
   When I execute dnf with args "reposync --download-path={context.dnf.tempdir} --metadata-path={context.dnf.tempdir}/downloadedmetadata --downloadcomps"
   Then the exit code is 0
    And stdout contains "comps.xml for repository http-dnf-ci-thirdparty-updates saved"
    And the files "{context.dnf.tempdir}/downloadedmetadata/http-dnf-ci-thirdparty-updates/comps.xml" and "{context.dnf.fixturesdir}/repos/dnf-ci-thirdparty-updates/repodata/comps.xml" do not differ


Scenario: Reposync with --download-metadata option
  Given I use the http repository based on "dnf-ci-thirdparty-updates"
   When I execute dnf with args "reposync --download-path={context.dnf.tempdir} --download-metadata"
   Then the exit code is 0
  Given I create and substitute file "/etc/yum.repos.d/test.repo" with
  """
  [testrepo]
  name=testrepo
  baseurl={context.dnf.tempdir}/http-dnf-ci-thirdparty-updates
  enabled=1
  gpgcheck=0
  """
    And I do not set reposdir
    And I disable the repository "http-dnf-ci-thirdparty-updates"
    And I use the repository "testrepo"
   When I execute dnf with args "group list"
   Then the exit code is 0
    And stdout contains lines
   """
   Available Groups:
   DNF-CI-Testgroup
   """


@bz1714788
Scenario: Reposync downloads packages from all streams of modular repository
  Given I use the http repository based on "dnf-ci-fedora-modular"
   When I execute dnf with args "reposync --download-path={context.dnf.tempdir}"
   Then the exit code is 0
    And file "//{context.dnf.tempdir}/http-dnf-ci-fedora-modular/x86_64/nodejs-8.11.4-1.module_2030+42747d40.x86_64.rpm" exists
    And file "//{context.dnf.tempdir}/http-dnf-ci-fedora-modular/x86_64/nodejs-10.11.0-1.module_2200+adbac02b.x86_64.rpm" exists
    And file "//{context.dnf.tempdir}/http-dnf-ci-fedora-modular/x86_64/nodejs-11.0.0-1.module_2311+8d497411.x86_64.rpm" exists


@bz1714788
Scenario: Reposync downloads packages from all streams of modular repository even if the module is disabled
  Given I use the http repository based on "dnf-ci-fedora-modular"
   When I execute dnf with args "module disable nodejs"
   Then the exit code is 0
   When I execute dnf with args "reposync --download-path={context.dnf.tempdir}"
   Then the exit code is 0
    And file "//{context.dnf.tempdir}/http-dnf-ci-fedora-modular/x86_64/nodejs-8.11.4-1.module_2030+42747d40.x86_64.rpm" exists
    And file "//{context.dnf.tempdir}/http-dnf-ci-fedora-modular/x86_64/nodejs-10.11.0-1.module_2200+adbac02b.x86_64.rpm" exists
    And file "//{context.dnf.tempdir}/http-dnf-ci-fedora-modular/x86_64/nodejs-11.0.0-1.module_2311+8d497411.x86_64.rpm" exists
