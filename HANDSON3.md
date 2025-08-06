# Lab 3. Incorporate Smart Test into your CI pipeline

In this section, you will use a toy Java project in this repository and its delivery pipeline based on GitHub Action as an example, to gain better understanding of how to use Smart Test in your CI pipeline.

# Fork this repository
Click the **Use this template** button to create your own copy of this repository, so that you can make changes in it.

<img src="https://user-images.githubusercontent.com/536667/191436235-e1347cf9-dcb2-41e8-89b6-df3bf2accf5d.png" width="50%">

After entering the required information, click **Crete repository from template**.

<img src="https://user-images.githubusercontent.com/536667/191436235-e1347cf9-dcb2-41e8-89b6-df3bf2accf5d.png" width="50%">


## Clone the forked repository to your local computer

Let's clone a forked repository

```sh
git clone  https://github.com/YOUR-USERNAME/REPOSITORY-NAME smarttests-workshop
cd smarttests-workshop
```

## Make Smart Test API token available to GitHub Actions
In previous labs, you were passing `LAUNCHABLE_TOKEN` as an environment variable to the `launchable` command. In order to do this in the CI pipeline, this token must be configured with th CI system as a secret.

Open the settings page of the GitHub repository that you created earlier and set the API key as a repository secret `LAUNCHABLE_TOKEN` under **Secrets and variables > Actions**.

![Screenshot from 2025-05-27 08-53-29](https://github.com/user-attachments/assets/956bbc03-599c-4551-8348-51497d0750d6)

![Screenshot from 2025-05-27 09-01-30](https://github.com/user-attachments/assets/924881cf-c69a-464e-97da-92ba4e43cb0d)

## Install the Launchable command in CI pipeline
First step of the integration is to make the `launchable` command available in the CI pipeline. 

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
<details>
<summary>Raw text for copying</summary>

```
- uses: actions/setup-python@v5
  with:
    python-version: '3.13'
- name: Install Launchable command
  run: pip install --user --upgrade launchable~=1.0
```

</details>
<br>

Next, Let's expose the API token you set as an environment variable.

To help you make sure that you have everything set up correctly, we have the `launchable verify` command, so we'll add it to the pipeline as well.


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

<details>
<summary>Raw texts for copying</summary>

```
env:
  LAUNCHABLE_TOKEN: ${{ secrets.LAUNCHABLE_TOKEN }}
```

```
- name: Launchable verify
  run: launchable verify
```

</details>
<br>

Let's push these changes and check the result.

```sh
git add .github/workflows/pre-merge.yml
git commit -m 'first set up'
git push
```

You will see verification logs on GitHub Actions if the setup is successful:

```
Organization: '<YOUR ORGANIZATION NAME>'
Workspace: '<YOUR WORKSPACE NAME>'
Proxy: None
Platform: 'Linux-6.8.0-1017-azure-x86_64-with-glibc2.39'
Python version: '3.12.8'
Java command: 'java'
launchable version: '1.110.0'
Your CLI configuration is successfully verified 🎉
```

## Record the build information

Now, let's record the build information. We've already looked at what this does in Lab 2.

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

<details>
<summary>Raw text for copying</summary>

```
with:
  fetch-depth: 0
```

</details>
<br>

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

<details>
<summary>Raw text for copying</summary>

```
- name: Launchable record build
  run: launchable record build --name ${{ github.run_id }}
```

</details>
<br>

If the setup is successful, you will see logs similar to the following:

```
Launchable recorded 1 commit from repository /home/runner/work/hands-on/hands-on
Launchable recorded build 3096604891 to workspace organization/workspace with commits from 1 repository:
| Name   | Path   | HEAD Commit                              |
|--------|--------|------------------------------------------|
| .      | .      | 5ea0a739271071dfbdacd330b0cc28c307151a04 |
```

## Start a test session and obtain a subset
Next, we'll mark that we are starting a test session. We've also looked at this in Lab 2.
We'll then obtain the subset of tests that should be run for this build, and pass it to the test runner,
which is Maven in this case.

Notice the `--observation` flag. This is [the training wheel mode](https://www.launchableinc.com/docs/features/predictive-test-selection/observing-subset-behavior/). With this flag, Smart Test
will go through all the motions, except for actually returning all the tests. We'll use this mode
to observe the behavior/performance of the test selection, hence the name.

Update `.github/workflows/pre-merge.yml` as follows:
```diff
      - name: Compile
        run: mvn compile
+     - name: Launchable subset
+       run: |
+         launchable record session --build ${{ github.run_id }} > session.txt
+         launchable subset --session $(cat session.txt) --observation maven src/test/java > launchable-subset.txt
      - name: Test
        run: mvn test
```
<details>
<summary>Raw text for copying</summary>

```
- name: Launchable subset
  run: |
    launchable record session --build ${{ github.run_id }} > session.txt
    launchable subset --session $(cat session.txt) --observation maven src/test/java > launchable-subset.txt
```

</details>
<br>

When you, you should see something like this. Details might vary:

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

Next, pass this subset to the test runner.

```diff

      - name: Test
-       run: mvn test
+       run: mvn test -Dsurefire.includesFile=launchable-subset.txt
```
<details>
<summary>Raw text for copying</summary>

```
run: mvn test -Dsurefire.includesFile=launchable-subset.txt
```

</details>
<br>

## Record test results
After tests are run, you need to report the test results to Launchable. This is done by the **launchable record tests** command.

If the test fail, GitHub Actions will stop the job and the test results will not be reported to Launchable. Therefore, you need to set `if: always()` so that test results are always reported.

Update `.github/workflows/pre-merge.yml` as follows:
```diff
      - name: Test
        run: mvn test -Dsurefire.includesFile=launchable-subset.txt
+     - name: Launchable record tests
+       if: always()
+       run: launchable record tests --session $(cat session.txt) maven ./**/target/surefire-reports
```
<details>
<summary>Raw text for copying</summary>

```
- name: Launchable record tests
  if: always()
  run: launchable record tests --session $(cat session.txt) maven ./**/target/surefire-reports
```

</details>
<br>

## Check the results
If everything is set up correctly, you can view the test results on Launchable as shown below: (A URL to this page is in the GitHub Actions log)

<img src="https://github.com/user-attachments/assets/f83dd1e6-bf9e-4091-964c-da665ffd764d" width="50%">

You should also see the report from the subset observation:

![image](https://user-images.githubusercontent.com/536667/195477376-500d318a-b67a-4202-8c90-81ca6048dcc4.png)

## Go live
If this was a real project, we'd keep the `--observation` flag until we accumulate enough data, then
evaluate its performance & roll out. In this workshop, we can skip this step and go live right away.

```diff
      - name: Launchable subset
        run: |
          launchable record session --build ${{ github.run_id }} > session.txt
-         launchable subset --session $(cat session.txt) --observation maven src/test/java > launchable-subset.txt
+         launchable subset --session $(cat session.txt) maven src/test/java > launchable-subset.txt
      - name: Test
        run: mvn test
```
