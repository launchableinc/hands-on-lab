# Lab 2. Try predictive test selection

In this section, you will test drive Predictive Test Selection (PTS) on your own computer,
and you will gain a better understanding of how it fits in your delivery pipeline.

# Capture software under test

In order to select the right tests for your software, Smart Test needs to know what software you are testing. We call this a **build**.

A build is a specific version of your software that you are testing. It can consists of multiple Git repositories, and in each repository, it points to a specific commit. A build is identified by its name.

>  **build** represents the software. Each time you send test results to Smart Test, you record them against a specific build so that Smart Test knows that you ran X tests against Y software with Z results.

refs: [Documentation](https://www.launchableinc.com/docs/concepts/build/)

Therefore, before you run your tests, you record a build using `launchable record build`.

Move to the locally checked out copy of your software, check out its main branch,
and run the following command to record a build:
```
$ LAUNCHABLE_TOKEN=<LAUNCHABLE TOKEN> launchable record build --name hands-on

or

$ docker run -e LAUNCHABLE_TOKEN=$LAUNCHABLE_TOKEN -v $(pwd):/workdir -w /workdir --rm cloudbees/launchable:v1.106.2 record build --name hands-on
```

(If your software consists of multiple repositories, then ...)

If you see a message like this, it was successful:

```
Launchable transferred 2 more commits from repository <YOUR PATH>
Launchable recorded build hands-on to workspace <YOUR ORG/WORKSPACE> with commits from 1 repository:

| Name   | Path   | HEAD Commit                              |
|--------|--------|------------------------------------------|
| .      | .      | 3f21bfb3d56148c9dcf9f7e811e146bbc3cbf797 |

Visit https://app.launchableinc.com/organizations/<ORG>/workspaces/<WORKSPACE>/data/builds/<BUILD ID> to view this build and its test sessions
```

What just happened? Smart Test recorded the current HEAD of your local repository as the build,
using the name given.

Since this was the first time you recorded a build, Smart Test needed to transfer relatively
large amount of data to its server, including recent commit history, file contents, etc. It
also has to do a lot of number crunching to prepare for the predictive test selection.

But subsequent calls to `launchable record build` will be much faster, because Smart Test will only transfer the new commits that you have added since the last build.

# Try predictive test selection

Now, let’s make a change in your software and see what tests Smart Test will pick up.
First, make a small change to a file in your software repository:

```
vim <UPDATE YOUR APP or TEST CODE>
git add <UPDATE YOUR APP or TEST CODE>
git commit -m 'test launchable'
```

Next, record a new build for this change, just like before:

```
$ LAUNCHABLE_TOKEN=<LAUNCHABLE TOKEN> launchable record build --name pts

or

$ docker run -e LAUNCHABLE_TOKEN=$LAUNCHABLE_TOKEN -v $(pwd):/workdir -w /workdir --rm cloudbees/launchable:v1.106.2 record build --name pts
```

Now, you declare the start of a new test session; A test session is an act of running tests against a specific build. Test selection and recording of test results are done against a test session.

 refs: [Documentation](https://www.launchableinc.com/docs/concepts/test-session/)

 ```
 $ LAUNCHABLE_TOKEN=<LAUNCHABLE TOKEN> launchable record session --build pts > session.txt

 or

 $ docker run -e LAUNCHABLE_TOKEN=$LAUNCHABLE_TOKEN -v $(pwd):/workdir -w /workdir --rm cloudbees/launchable:v1.106.2 record session --build pts > session.txt
 ```

When you record a new test session, Smart Test will return a session ID, which is stored in `session.txt` file.

Now, let's have Smart Test select the best set of tests to run for this test session.

 ```
 $ LAUNCHABLE_TOKEN=<LAUNCHABLE_TOKEN> launchable subset --session $(cat session.txt) file > subset.txt

 or

$ docker run -e LAUNCHABLE_TOKEN=$LAUNCHABLE_TOKEN -v $(pwd):/workdir -w /workdir --rm cloudbees/launchable:v1.106.2 subset --session $(cat session.txt) file > session.txt
```

Since you haven't run any tests yet, Smart Test will select files in your repository
that looks like tests, and order them in the order it thinks is most relevant to
the change you just made:

```
cat subset.txt
```

What do you think?
Are the files related to the changes you just made included in the selection?

Once you start recording test results, Smart Test will use the results to improve its selection.
