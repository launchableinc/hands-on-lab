# Hands-on 2. Introduce the Launchable Command

In this section, edit`.github/workflows/pre-merge.md` and set up the [Launchable command](https://www.launchableinc.com/docs/resources/cli-reference/).

You'll do

1. Install the Launchable command
1. Set up `launchable record build`
1. Set up `launchable record tests`
1. Set up `launchable record subset` (Predictive Test Selection)

Before you begin, create a new branch named `PR1`.

```sh
$ git switch -c PR1
$ git commit --allow-empty -m "introduce the Launchable command"
$ git push origin PR1
```

 Then, create a pull request from the `PR1` branch to `main` branch.

## Install the Launchable Command

Let's install the Launchable command. The command is written in Python and requires Java for some commands. However, since this hands-on project already uses Java and it is set up it, you don't need to install Java this time.

Update your `.github/workflows/pre-merge.yml` as follows:
```diff
        with:
          java-version: 21
          distribution: "adopt"
+     - uses: actions/setup-python@v5
+       with:
+         python-version: '3.13'
+     - name: Install Launchable command
+       run: pip install --user --upgrade launchable~=1.0
      - name: Compile
        run: mvn compile
          with:
           java-version: 21
           distribution: "adopt"
```

If set up correctly, after pushing this change the Launchable command will be installed.

Next, Let's access Launchable using your API Key. Set the API key to as an environment variable.

Update `.github/workflows/pre-merge.yml` by adding:
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

You will see verification logs on GitHub Actions if the setup is successful:

```
Organization: '<YOUR ORGANIZATION NAME>'
Workspace: '<YOUR WORKSPACE NAME>'
Proxy: None
Platform: 'Linux-6.8.0-1017-azure-x86_64-with-glibc2.39'
Python version: '3.12.8'
Java command: 'java'
launchable version: '1.97.0'
Your CLI configuration is successfully verified 🎉
```

## launchable record build

Now, let's record the build information.

Launchable uses commit history to train models, so you need to use a full clone.

Update `.github/workflows/pre-merge.yml` as follows:
```diff
steps:
       - uses: actions/checkout@v5
+        with:
+          fetch-depth: 0
       - uses: actions/setup-java@v4
         with:
           java-version: 11
```

Next, execute the **launchable record build** command.

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

You can view logs similar to the following if the setup is successful:

```
Launchable recorded 1 commit from repository /home/runner/work/hands-on/hands-on
Launchable recorded build 3096604891 to workspace organization/workspace with commits from 1 repository:
| Name   | Path   | HEAD Commit                              |
|--------|--------|------------------------------------------|
| .      | .      | 5ea0a739271071dfbdacd330b0cc28c307151a04 |
```

## launchable record tests

Next, try to report test results using by the **record test** command.
If the test fail, GitHub Actions will stop the job and the test results will not be reported to Launchable. Therefore, you need to set `if: always()` so that  test results are always reported.

Update `.github/workflows/pre-merge.yml` as follows:
```diff
      - name: Compile
        run: mvn compile
      - name: Test
        run: mvn test
+     - name: Launchable record tests
+       if: always()
+       run: launchable record tests maven ./**/target/surefire-reports
```

If everything is set up correctly, you can view the test results on Launchable as shown below:

<img src="https://github.com/user-attachments/assets/f83dd1e6-bf9e-4091-964c-da665ffd764d" width="50%">


## `launchable record subset` (Predictive Test Selection)

This is a final section of #2,
Let's setup the **launchable subset** command with the [observation mode](https://docs.launchableinc.com/features/predictive-test-selection/observing-subset-behavior) option.

Update `.github/workflows/pre-merge.yml` as follows:
```diff
      - name: Launchable verify
        run: launchable verify
      - name: launchable record build
        run: launchable record build --name ${{ github.run_id }}
+     - name: launchable subset
+       run: |
+         launchable subset --observation --target 50% maven src/test/java > launchable-subset.txt
+         cat launchable-subset.txt
      - name: Test
        run: mvn test
```

You can view the subset result log in the GitHub Actions log. For example:

```
|           |   Candidates |   Estimated duration (%) |   Estimated duration (min) |
|-----------|--------------|--------------------------|----------------------------|
| Subset    |            2 |                  36.4706 |                  0.0516667 |
| Remainder |            2 |                  63.5294 |                  0.09      |
|           |              |                          |                            |
| Total     |            4 |                 100      |                  0.141667  |

Run `launchable inspect subset --subset-id XXX` to view full subset details
example.MulTest
example.DivTest
example.AddTest
example.SubTest
```

FInally, use this subset result for testing.

```diff
      - name: Launchable verify
        run: launchable verify
      - name: launchable record build
        run: launchable record build --name ${{ github.run_id }}
      - name: launchable subset
        run: |
          launchable subset --observation --target 50% maven src/test/java > launchable-subset.txt
          cat launchable-subset.txt
      - name: Test
+       run: mvn test -Dsurefire.includesFile=launchable-subset.txt
      - name: Launchable record tests
         run: launchable record tests maven ./**/target/surefire-reports
```

After the job succeeded, you can check the subset impact on web application. From the sidebar, go to  **Predictive Test Selection > Observe**:

<img src="https://user-images.githubusercontent.com/536667/195478410-6402773f-d232-46af-8543-24a7f6b67b4f.png">

<br>

![image](https://user-images.githubusercontent.com/536667/195477376-500d318a-b67a-4202-8c90-81ca6048dcc4.png)

If you have could confirmed the subset impact, merge this branch to main. You can check the subset impact at observation page of the web application

___

Prev: [Hands-on 1](HANDSON1.md)
Next: [Hands-on 3](HANDSON3.md)

