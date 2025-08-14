# Lab 3. Incorporate Smart Tests into your CI workflow

In this section, you will use a toy Java project in this repository and its delivery workflow based on GitHub Action as an example, to gain better understanding of how to use Smart Tests in your CI workflow.

# Before you start
1. This workshop will be run entirely inside GitHub’s web interface — no local CLI is needed
2. You will receive a link from the instructor, which opens a Pull Request in GitHub - all file edits and workflow checks during this lab will be done here
3. Open the PR and start your workshop

Note: The PR you will be working in a forked repository from `launchableinc/hands-on-lab`

# Step 1: Integrating with Launchable
In the Pull Request page, navigate to the **Files changed** tab. This file, `pre-merge.yml`, is the one you will be making edits to. To edit the file, click on the **Edit file** button by accessing it from the three-dot menu.

<img width="378" height="251" alt="Screenshot 2025-08-14 at 6 13 30 PM" src="https://github.com/user-attachments/assets/277a22fd-df16-4786-aa91-895342a02210" />

## Add the Launchable CLI to workflow
Update the file as follows:
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

## Add Launchable verify step to workflow
Next, to help you make sure that you have everything set up correctly, we have the `launchable verify` command, so we'll add it to the workflow as well.

Update the file as follows:
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

## Commit changes
Now, we will push changes made by you in the `pre-merge.yml`by clicking on **Commit changes**.

<img width="407" height="151" alt="image" src="https://github.com/user-attachments/assets/f4307775-14be-4847-a087-bb53329440db" />

Add a commit message like, `Installing Launchable CLI`. Commit directly to your existing branch `workshop-<your-name>`

## Verify installation through logs
To verify if the installation was successful, you can check the result in logs. Navigate to the **Checks** tab as shown below.

<img width="569" height="50" alt="Screenshot 2025-08-14 at 2 58 41 PM" src="https://github.com/user-attachments/assets/51665a30-f037-4bea-a324-e0f75438d4aa" />

Here, you will find the workflow which was triggered by your changes. Open and expand the **Launchable verify** step to view the logs. If the setup was successful, you will see:
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

# Step 2: Recording build information
We will add Launchable commands to the `pre-merge.yml` file to record build related information. Head back to the **Files changed** tab and click on **Edit file** again.

## Enable full Git history

Update the file as follows:
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

## Record build with Launchable CLI
Next, execute the `launchable record build` command.

Update the file after the `launchable verify` step as follows:
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

## Commit changes
Commit changes directly to your branch by clicking on **Commit changes**. Add a commit message like, `Added record build commands`. Commit directly to your existing branch `workshop-<your-name>`

## Verify logs
To verify the successful addition of this step, navigate to **Checks** tab again. Open and expand the **Launchable record build** step to view the logs. If the setup was successful, you will see:
```
Launchable recorded 1 commit from repository /home/runner/work/hands-on/hands-on
Launchable recorded build 3096604891 to workspace organization/workspace with commits from 1 repository:
| Name   | Path   | HEAD Commit                              |
|--------|--------|------------------------------------------|
| .      | .      | 5ea0a739271071dfbdacd330b0cc28c307151a04 |
```

# Step 3: Running test session by predicting a subset
Here, we will get a subset of tests to run from Launchable and execute a test session. Head back to the **Files changed** tab and click on **Edit file** again.

## Add Launchable subset command
We will first obtain the subset of tests that should be run for this build. then pass it to the test runner, which is Maven in this case.

Notice the `--observation` flag. This is [the training wheel mode](https://www.launchableinc.com/docs/features/predictive-test-selection/observing-subset-behavior/). With this flag, Smart Test
will go through all the motions, except for actually returning all the tests. We'll use this mode
to observe the behavior/performance of the test selection, hence the name.

Update the file as follows:
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

## Commit changes
Commit changes directly to your branch by clicking on **Commit changes**. Add a commit message like, `Added subset command`. Commit directly to your existing branch `workshop-<your-name>`

## Verify logs
To verify the successful addition of this step, navigate to **Checks** tab again. Open and expand the **Launchable subset** step to view the logs. If the setup was successful, you will see:
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

## Add command to run Maven tests with subset
Now, we need to pass the subset to the test runner. Head back to the **Files changed** tab and click on **Edit file**.

Update the file after the `launchable subset` command as follows:
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

## Commit changes
Commit changes directly to your branch by clicking on **Commit changes**. Add a commit message like, `Updated test run command`. Commit directly to your existing branch `workshop-<your-name>`

# Step 4: Record test results
After tests are run, you need to report the test results to Launchable. This is done by the **launchable record tests** command.

Note: If the test fail, GitHub Actions will stop the job and the test results will not be reported to Launchable. Therefore, you need to set `if: always()` so that test results are always reported.

## Record tests to Launchable

Update the file after the `test` step, as follows:
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

## Commit changes
Commit changes directly to your branch by clicking on **Commit changes**. Add a commit message like, `Added record tests command`. Commit directly to your existing branch `workshop-<your-name>`

# Step 5: Verify results
You have now successfully installed Launchable, recorded build info, requested a subset and run tests with that subset through your GitHub Actions workflow. To verify if everything is setup correctly, navigate to **Checks** tab. Open and expand the **Launchable record tests** step to view the logs. If the setup was successful, you will see something similar:

<img width="1111" height="214" alt="Screenshot 2025-08-14 at 7 30 43 PM" src="https://github.com/user-attachments/assets/9773f0d4-ff00-4904-b115-ea1074c5ce14" />

Click on the URL provided here to view the test results in Launchable. Example:

<img width="982" height="397" alt="image" src="https://github.com/user-attachments/assets/139d4b37-c457-4f2b-a4d6-8d836ed7c656" />

# Step 6: Go live
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

Commit changes directly to your branch by clicking on **Commit changes**.
