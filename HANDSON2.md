# Hands-on 2. Introduce the Launchable Command

In this section, edit`.github/workflows/pre-merge.md` and set up the [Launchable command](https://www.launchableinc.com/docs/resources/cli-reference/).

In this section, you will:

1. Install the Launchable command
1. Set up `launchable record build`
1. Set up `launchable record tests`

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

<details>
<summary>Raw texts for copying</summary>

```
env:
  LAUNCHABLE_TOKEN: ${{ secrets.LAUNCHABLE_TOKEN }}
```

<br>

```
- name: Launchable verify
  run: launchable verify
```

</details>

<br>

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

## Set up "launchable record build" command

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

You can view logs similar to the following if the setup is successful:

```
Launchable recorded 1 commit from repository /home/runner/work/hands-on/hands-on
Launchable recorded build 3096604891 to workspace organization/workspace with commits from 1 repository:
| Name   | Path   | HEAD Commit                              |
|--------|--------|------------------------------------------|
| .      | .      | 5ea0a739271071dfbdacd330b0cc28c307151a04 |
```

## Set up "launchable record tests" command

This is a final section of #2, Try to report test results using by the **record test** command.
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

<details>
<summary>Raw text for copying</summary>

```
- name: Launchable record tests
  if: always()
  run: launchable record tests maven ./**/target/surefire-reports
```

</details>
<br>

If everything is set up correctly, you can view the test results on Launchable as shown below: (A URL is displayed in the GitHub Actions log)

<img src="https://github.com/user-attachments/assets/f83dd1e6-bf9e-4091-964c-da665ffd764d" width="50%">


If you have could confirmed the test result, **merge** this branch to main.

___

Prev: [Hands-on 1](HANDSON1.md)
Next: [Hands-on 3](HANDSON3.md)


