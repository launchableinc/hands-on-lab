# Lab 3. Incorporate Smart Tests into your CI pipeline

In this section, you will use a toy Java project in this repository and its delivery pipeline based on GitHub Action as an example, to gain better understanding of how to use Smart Tests in your CI pipeline.

# Fork this repository
Click the **Fork** button to create your own copy of this repository, so that you can make changes in it.

<img src="https://github.com/user-attachments/assets/03757336-0b5f-48fb-847b-5e8b6924ce10" width="50%">

After entering the required information, click **Crete fork** button.

<img src="https://github.com/user-attachments/assets/bcab29b8-d217-4bd2-b4a6-42780e99b4c3" width="50%">


## Clone the forked repository to your local computer

Let's clone a forked repository

```sh
git clone  https://github.com/YOUR-USERNAME/REPOSITORY-NAME smarttests-workshop
cd smarttests-workshop
git switch -c workshop
```

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

Next, to help you make sure that you have everything set up correctly, we have the `launchable verify` command, so we'll add it to the pipeline as well.


Update `.github/workflows/pre-merge.yml` by adding:
```diff
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
- name: Launchable verify
  run: launchable verify
```

</details>
<br>

Let's push these changes and check the result.

```sh
git add .github/workflows/pre-merge.yml
git commit -m 'initial set up'
git push
```

And, create a Pull Request from your repository to the original (launchableinc/hands-on-lab) repository. After running GitHub Actions, you will see verification logs on GitHub Actions if the setup is successful:

```
Organization: launchable-demo
Workspace: hands-on-lab
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

```
git add .github/workflows/pre-merge.yml
git commit -m 'start sending build data'
git push
```

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
+         launchable record session --build ${{ github.run_id }} --observation --test-suite unit-test > session.txt
+         launchable subset --session $(cat session.txt) --target 50%  maven src/test/java > launchable-subset.txt
+         cat launchable-subset.txt
      - name: Test
        run: mvn test
```
<details>
<summary>Raw text for copying</summary>

```
- name: Launchable subset
  run: |
    launchable record session --build ${{ github.run_id }} --observation --test-suite unit-test > session.txt
    launchable subset --session $(cat session.txt) --target 50% maven src/test/java > launchable-subset.txt
    cat launchable-subet.txt
```

</details>
<br>

```
git add .github/workflows/pre-merge.yml
git commit -m 'start subsetting'
git push
```

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

```
git add .github/workflows/pre-merge.yml
git commit -m 'use the subset result'
git push
```

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

```
git add .github/workflows/pre-merge.yml
git commit -m 'report test results'
git push
```

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

Let's apply this change and check the result.

```
git add .github/workflows/pre-merge.yml
git commit -m 'disable observation mode'
git push
```


