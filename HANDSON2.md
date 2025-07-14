# Hands-on 2. Introduce the Launchable Command

In this section, you will try to use Predictive Test Selection (PTS) via Launchable command.

Then, you will:

1. Try to send data to Launchable via `launchable record build` command
1. Try to use PTS via `launchable subset` command

# Try to send data to Launchable

Let’s try sending data to Launchable.
you’ll start with the `launchable record build` command.

>  **build** represents that software. Each time you send test results to Launchable, you record them against a specific build so that Launchable knows that you ran X tests against Y software with Z results.

refs: [Documentation](https://www.launchableinc.com/docs/concepts/build/)

Therefore, before you run your tests, you can create a build using `launchable record build`.

Let’s try running it:


```
$ LAUNCHABLE_TOKEN=<LAUNCHABLE TOKEN> launchable record build --name hands-on

or

$ docker run -e LAUNCHABLE_TOKEN=$LAUNCHABLE_TOKEN -v $(pwd):/workdir -w /workdir --rm cloudbees/launchable:v1.106.2 record build --name hands-on
```

If you see a message like this, it was successful:

```
Launchable transferred 2 more commits from repository <YOUR PATH>
Launchable recorded build hands-on to workspace <YOUR ORG/WORKSPACE> with commits from 1 repository:

| Name   | Path   | HEAD Commit                              |
|--------|--------|------------------------------------------|
| .      | .      | 3f21bfb3d56148c9dcf9f7e811e146bbc3cbf797 |

Visit https://app.launchableinc.com/organizations/<ORG>/workspaces/<WORKSPACE>/data/builds/<BUILD ID> to view this build and its test sessions
```

# Try to Use PTS

Now, let’s try running a subset.
First, make a small change to a file:

```
vim <UPDATE YOUR APP or TEST CODE>
git add <UPDATE YOUR APP or TEST CODE>
git commit -m 'test launchable'
```

That’s it for preparation.

Next, create a build just like you did before:

```
$ LAUNCHABLE_TOKEN=<LAUNCHABLE TOKEN> launchable record build --name pts

or

$ docker run -e LAUNCHABLE_TOKEN=$LAUNCHABLE_TOKEN -v $(pwd):/workdir -w /workdir --rm cloudbees/launchable:v1.106.2 record build --name pts
```

Then, create a test session:
 refs: [Documentation](https://www.launchableinc.com/docs/concepts/test-session/)

 ```
 $ LAUNCHABLE_TOKEN=<LAUNCHABLE TOKEN> launchable record session --build pts > session.txt

 or

 $ docker run -e LAUNCHABLE_TOKEN=$LAUNCHABLE_TOKEN -v $(pwd):/workdir -w /workdir --rm cloudbees/launchable:v1.106.2 record session --build pts > session.txt
 ```

 Now, run the actual subset command:

 ```
 $ LAUNCHABLE_TOKEN=<LAUNCHABLE_TOKEN> launchable subset --target 20% --session $(cat session.txt) file > subset.txt

 or

$ docker run -e LAUNCHABLE_TOKEN=$LAUNCHABLE_TOKEN -v $(pwd):/workdir -w /workdir --rm cloudbees/launchable:v1.106.2 subset --target 20% --session $(cat session.txt) file > session.txt
```

Check the subset results:

```
cat subset.txt
```

What do you think?
Are the files related to the changes you just made included in the selection?