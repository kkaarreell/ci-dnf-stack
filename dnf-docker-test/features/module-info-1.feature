Feature: Module profile info

  @setup
  Scenario: Testing repository Setup
      Given I run steps from file "modularity-repo-1.setup"
       When I enable repository "modularityABDE"
        And I successfully run "dnf -y module enable ModuleA:f26"
        And I successfully run "dnf makecache"

  Scenario: I can get info for an enabled module profile
       When I successfully run "dnf module info ModuleA"
       Then the command stdout should match line by line regexp
            """
            ?Last metadata expiration check

            Name        : ModuleA
            Stream      : f26
            Version     : 2
            Profiles    : client default devel minimal server
            Repo        : modularityABDE
            Summary     : Module ModuleA summary
            Description : Module ModuleA description
            Artifacts   : TestA-0:1-2.modA.noarch
                        : TestB-0:1-1.modA.noarch
                        : TestC-0:1-2.modA.noarch
                        : TestD-0:1-1.modA.noarch
            """

  Scenario: I cannot get info for a disabled module profile unless I specify a stream
       When I run "dnf module info ModuleB"
       Then the command exit code is 1
        And the command stderr should match regexp "No stream specified"

  Scenario: I can get info for a disabled module profile when specifying stream
       When I successfully run "dnf module info ModuleB:f26"
       Then the command stdout should match line by line regexp
            """
            ?Last metadata expiration check

            Name        : ModuleB
            Stream      : f26
            Version     : 2
            Profiles    : default
            Repo        : modularityABDE
            Summary     : Module ModuleB summary
            Description : Module ModuleB description
            Artifacts   : TestG-0:1-2.modB.noarch
                        : TestI-0:1-1.modB.noarch
            """
