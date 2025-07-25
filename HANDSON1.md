# Lab 1. Environment setup

In this section, you will set up the environment for the hands-on. Specifically, you will do the following:

1. Issue an API Key
1. Install Launchable Command

Let's get started.

# Prepare the Project You Want to Integrate Smart Test

First, get the project you usually work on and want to make testing faster for.
If you haven’t cloned it yet, use `git clone`. If it’s already cloned, navigate to its directory.

# Prepare Your Smart Test API Token

You need an API token to use Smart Test.
Go to your workspace’s Settings > API Token and generate a new token.

**Node:** If you haven’t created a workspace yet, please refer to `SIGN_UP.md` to set one up.

<img src="https://github.com/user-attachments/assets/1f17be96-acf9-4825-8f9f-06790a14dc1c" width="50%">

<br>

Click the **Create a new API key**

<img src="https://user-images.githubusercontent.com/536667/191438711-b15eb234-e3d5-4ba2-b2fb-11d0ebd92d18.png" width="50%">

Click **Copy** key and copy API key.

<img src="https://github.com/user-attachments/assets/5025328b-fc20-4eb1-b7f2-346aab60e013" width="50%">

# Install Launchable Command

Smart Test communicates by using the launchable command-line tool.

You can install it with pip:

```
pip install --user --upgrade launchable~=1.0
```

Alternatively, you can use the provided Docker image:

```
docker pull cloudbees/launchable:v1.106.2
```

Let’s check that it’s installed correctly:

```
$ launchable --help

or

$ docker run --rm cloudbees/launchable:v1.106.2 --help
```


# Let's Try a Launchable Command

Now, let’s test the connection using the launchable command.

```
$ LAUNCHABLE_TOKEN=<LAUNCHABLE TOKEN> launchable verify

or

$ docker run -e LAUNCHABLE_TOKEN=<LAUNCHABLE_TOKEN> --rm cloudbees/launchable:v1.106.2 verify
```

If you see a message like this, you’re all set:

```
Organization: 'organization'
Workspace: 'workspace'
Proxy: None
Platform: 'Linux-6.10.14-linuxkit-aarch64-with-glibc2.36'
Python version: '3.11.13'
Java command: 'java'
launchable version: '1.106.2'
Your CLI configuration is successfully verified 🎉
```

___

If you see the help message, the installation was successful.
You can now move on to the next step (HANDSON2.md).



