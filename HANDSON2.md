# Hands-on 2. Introduce Launchable command

In this section, edit`.github/workflows/pre-merge.md` and setup [Launchable command](https://github.com/launchableinc/cli).
You'll do

1. Install Launchable command
1. `launchable record build`
1. `launchable record tests`
1. `launchable record subset` (Predictive Test Selection)

Before starting it, make a new branch `PR1`.

```
$ git switch -c PR1
$ git push origin PR1
```

 And create a PR from `PR1` branch to `main` branch.

## Install Launchable command

TODO(Konboi): explain launchable command overview

Let's install the Launchable command. The Launchable command is made of Python and requires Java in some commands. But this demo project is using Java and already set up it, so don't need to install Java this time.


`.github/workflows/pre-merge.yml`
```diff
with:
           java-version: 11
           distribution: "adopt"
+      - uses: actions/setup-python@v3
+        with:
+          python-version: '3.10'
+      - name: Install Launchable command
+        run: pip install --user --upgrade launchable~=1.0
       - name: Compile
         run: mvn compile
   worker-node-1:
```

If set up correctly, after pushing this change the Launchable command will be installed.

Next, Let's access Launchable use by API Key. Set API Key to ENV.

`.github/workflows/pre-merge.yml`
```diff
   pull_request:
   workflow_dispatch:

+env:
+  LAUNCHABLE_TOKEN: ${{ secrets.LAUNCHABLE_TOKEN }}
+
 jobs:
   build:
     runs-on: ubuntu-latest

...

          python-version: '3.10'
       - name: Install Launchable command
         run: pip install --user --upgrade launchable~=1.0
+      - name: Launchable verify
+        run: launchable verify
       - name: Compile
         run: mvn compile
       - name: Test
```

Will see verify logs on GitHub Actions if you succeeded.

```
Run launchable verify
Organization: 'konboi-demo-org'
Workspace: 'demo'
Proxy: None
Platform: 'Linux-5.15.0-1019-azure-x86_64-with-glibc2.31'
Python version: '3.10.6'
Java command: 'java'
launchable version: '1.47.2'
Your CLI configuration is successfully verified 🎉
```

## launchable record build

Let's try to record test results.

Launchable uses commit history to train models so need to full clone.

`.github/workflows/pre-merge.yml`
```diff
steps:
       - uses: actions/checkout@v3
+        with:
+          fetch-depth: 0
       - uses: actions/setup-java@v3
         with:
           java-version: 11
```

Execute `launchable record build` command

`.github/workflows/pre-merge.yml`
```diff
run: pip install --user --upgrade launchable~=1.0
       - name: Launchable verify
         run: launchable verify
+      - name: Launchable record build
+        run: launchable record build --name ${{ github.run_id }}
       - name: Compile
         run: mvn compile
   worker-node-1:
```

You can see log if you completed to setup

```
Launchable recorded 1 commit from repository /home/runner/work/hands-on/hands-on
Launchable recorded build 3096604891 to workspace organization/workspace with commits from 1 repository:
| Name   | Path   | HEAD Commit                              |
|--------|--------|------------------------------------------|
| .      | .      | 5ea0a739271071dfbdacd330b0cc28c307151a04 |
```

## launchable record tests

Next, try to record test results.

When report test results to Launchable, Launchable command require [test session](). But in this project, the test will be run at the worker node.
So need to issue a test session at the primary node and pass it to the worker node.

In this case, use Github Actions specific feature outputs to pass test session value from primary node to worker node.


`.github/workflows/pre-merge.yml`
```diff
 jobs:
   primary-node:
     runs-on: ubuntu-latest
+    outputs:
+      test_session: ${{ steps.issue_test_session.outputs.test_session}}
     steps:
       - uses: actions/checkout@v3
         with:
...

         run: launchable verify
       - name: Launchable record build
         run: launchable record build --name ${{ github.run_id }}
+      - name: Launchable record session
+        id: issue_test_session
+        run: |
+          launchable record session --build ${{ github.run_id }} > test_session.txt
+          test_session=$(cat test_session.txt)
+          echo $test_session
+          echo "::set-output name=test_session::$test_session"
       - name: Compile
         run: mvn compile
```

If successful, you can check `builds/<BUILD NAME>/test_sessions/<TEST SESSION ID>` on Github Actions console log.

If you could check the log, edit to report test results to Launchable.

`.github/workflows/pre-merge.yml`
```diff
         with:
           java-version: 11
           distribution: "adopt"
+      - uses: actions/setup-python@v3
+        with:
+          python-version: '3.10'
+      - name: Install Launchable command
+        run: pip install --user --upgrade launchable~=1.0
       - name: Test
         run: mvn test

...

         with:
           java-version: 11
           distribution: "adopt"
+      - name: Restore test session
+        run: echo -n '${{needs.primary-node.outputs.test_session}}' > test_session.txt
       - name: Test
         run: mvn test
+      - name: Launchable record tests
+        if: always()
+        run: launchable record tests --session $(cat test_session.txt) maven ./**/target/surefire-reports
```

TODO:Konboi to explain why add `if always()`

![image](https://user-images.githubusercontent.com/536667/192182845-9602cf0f-8626-420c-8a17-75555d457448.png)
![image](https://user-images.githubusercontent.com/536667/192182874-864aab9b-6571-4b40-aa4a-1cb687aaa8e0.png)


## `launchable record subset` (Predictive Test Selection)

This is a last section of #2, let's setup `launchable subset` with [observation mode]().

`.github/workflows/pre-merge.yml`
```diff
# primary-node config
       - name: Launchable record session
         id: issue_test_session
         run: |
-          launchable record session --build ${{ github.run_id }} > test_session.txt
+          launchable record session --build ${{ github.run_id }} --observation > test_session.txt
           test_session=$(cat test_session.txt)
           echo $test_session
           echo "::set-output name=test_session::$test_session"
```

```diff
# worker-node config
         run: pip install --user --upgrade launchable~=1.0
       - name: Restore test session
         run: echo -n '${{needs.primary-node.outputs.test_session}}' > test_session.txt
+      - name: Launchable subset
+        run: |
+          mvn test-compile
+          launchable subset --session $( cat test_session.txt ) --target 50% maven --test-compile-created-file target/maven-status/maven-compiler-plugin/testCompile/default-testCompile/createdFiles.lst > launchable-subset.txt
+          cat launchable-subset.txt
       - name: Test
         run: mvn test
       - name: Launchable record tests
```

you can see the subset result log on the GitHub Actions log.

e.g)
```
|           |   Candidates |   Estimated duration (%) |   Estimated duration (min) |
|-----------|--------------|--------------------------|----------------------------|
| Subset    |            2 |                  49.9956 |                   0.6664   |
| Remainder |            2 |                  50.0044 |                   0.666517 |
|           |              |                          |                            |
| Total     |            4 |                 100      |                   1.33292  |

Run `launchable inspect subset --subset-id XXX` to view full subset details
example.MulTest
example.AddTest
example.DivTest
example.SubTest
```

FInally, use this subset result for testing.

```diff
           launchable subset --session $( cat test_session.txt ) --target 50% maven --test-compile-created-file target/maven-status/maven-compiler-plugin/testCompile/default-testCompile/createdFiles.lst > launchable-subset.txt
           cat launchable-subset.txt
       - name: Test
-        run: mvn test
+        run: mvn test -Dsurefire.includesFile=launchable-subset.txt
       - name: Launchable record tests
         run: launchable record tests --session $( cat test_session.txt ) maven ./**/target/surefire-reports
```

TODO(Konboi): explain observation page and add screen shots

If you succeeded the test, merge this branch to main. And you can check the subset impact at observation page on the WebApp.

___

Prev: [Hands-on 1](HANDSON1.md)
Next: [Hands-on 3](HANDSON3.md)

