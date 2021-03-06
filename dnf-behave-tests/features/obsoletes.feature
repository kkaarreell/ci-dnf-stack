Feature: Obsoleted packages

# dnf-ci-obsoletes repo contains:
# PackageA in versions 1.0 and 3.0
# PackageA-Obsoleter, which provides PackageA in version 2.0 and obsoletes PackageA < 2.0
# PackageA-Provider which provides PackageA in versin 4.0

Background: Use dnf-ci-obsoletes repository
  Given I use the repository "dnf-ci-obsoletes"


Scenario: Install of obsoleted package, but higher version than obsoleted present
   When I execute dnf with args "install PackageA"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                                   |
        | install       | PackageA-0:3.0-1.x86_64                   |


Scenario: Upgrade of obsoleted package by package of higher version than obsoleted
   When I execute dnf with args "install PackageA-1.0"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                                   |
        | install       | PackageA-0:1.0-1.x86_64                   |
   When I execute dnf with args "upgrade"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                                   |
        | upgrade       | PackageA-0:3.0-1.x86_64                   |


Scenario: Install of obsoleted package
   When I execute dnf with args "install PackageB"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                                   |
        | install       | PackageB-Obsoleter-0:1.0-1.x86_64         |


Scenario: Upgrade of obsoleted package
   When I execute dnf with args "install PackageB-1.0"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                                   |
        | install       | PackageB-0:1.0-1.x86_64                   |
   When I execute dnf with args "upgrade"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                                   |
        | install       | PackageB-Obsoleter-0:1.0-1.x86_64         |
        | remove        | PackageB-0:1.0-1.x86_64                   |


Scenario: Upgrade of obsoleted package if package specified by version with glob (no obsoletes applied)
   When I execute dnf with args "install PackageB-1.0"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                                   |
        | install       | PackageB-0:1.0-1.x86_64                   |
   When I execute dnf with args "upgrade PackageB-2*"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                                   |
        | upgrade       | PackageB-0:2.0-1.x86_64                   |


@xfail @bz1672618
Scenario: Keep reason of obsoleted package
   When I execute dnf with args "install PackageB-1.0"
   Then the exit code is 0
   When I execute dnf with args "mark remove PackageB"
   Then the exit code is 0
    And history userinstalled should
        | Action        | Package                                   |
        | not match     | PackageB-1.0-1                            | 
   When I execute dnf with args "upgrade"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                                   |
        | install       | PackageB-Obsoleter-0:1.0-1.x86_64         |
        | remove        | PackageB-0:1.0-1.x86_64                   |
    And history userinstalled should
        | Action        | Package                                   |
        | not match     | PackageB-Obsoleter-1.0-1                  | 


Scenario: Autoremoval of obsoleted package
   When I execute dnf with args "install PackageB-1.0"
   Then the exit code is 0
   When I execute dnf with args "upgrade"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                                   |
        | install       | PackageB-Obsoleter-0:1.0-1.x86_64         |
        | remove        | PackageB-0:1.0-1.x86_64                   |
   When I execute dnf with args "autoremove"
   Then the exit code is 0
    But Transaction is empty


@xfail
@bz1672947
Scenario: Multilib obsoletes during distro-sync
  Given I use the repository "dnf-ci-fedora"
   When I execute dnf with args "install lz4-0:1.7.5-2.fc26.i686 lz4-0:1.7.5-2.fc26.x86_64"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                       |
        | install       | lz4-0:1.7.5-2.fc26.i686       |
        | install       | lz4-0:1.7.5-2.fc26.x86_64     |
  Given I use the repository "dnf-ci-fedora-updates"
   When I execute dnf with args "distro-sync"
   Then the exit code is 0
   Then stderr does not contain "TransactionItem not found for key: lz4"
    And Transaction is following
        | Action        | Package                               |
        | upgrade       | lz4-0:1.8.2-2.fc29.x86_64             |
        | install       | lz4-libs-0:1.8.2-2.fc29.i686          |
        | install       | lz4-libs-0:1.8.2-2.fc29.x86_64        |
        | remove        | lz4-0:1.7.5-2.fc26.i686               |
