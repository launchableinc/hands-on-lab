# Hands-on 1. Setup repository

In this section, you will set up the environment for the hands-on. Specifically, you will do the following:

1. Create a repository for hands-on
1. Clone a forked repository to your local
1. Create a CloudBees Platform account
1. Connect a repository for hands-on use to the CloudBees Platform.
1. Issue an API Key and set it as GitHub Actions' secret
1. Ask the SE to set it to hands-on mode

Let's get started.

## 1. Create a repository for hands-on

Click a **Use this template** button to create a new repository for hands-on.

![image](https://user-images.githubusercontent.com/536667/191435068-cd3aebfe-fc23-4c30-a4a5-32b270dcc697.png)

Then, after entering the required information, click **Crete repository from template**.

<img src="https://user-images.githubusercontent.com/536667/191436235-e1347cf9-dcb2-41e8-89b6-df3bf2accf5d.png" width="50%">


## 2. Clone a forked repository to your local

Let's clone a forked repository

```sh
git clone  https://github.com/YOUR-USERNAME/REPOSITORY-NAME launchable-hands-on
cd launchable-hands-on
```

## 3. Create a CloudBees Platform Account

Sign up from the [https://cloudbees.io](https://cloudbees.io). You will create a user account for hands-on use.


<img src="https://github.com/user-attachments/assets/835b3bd9-84de-451c-a913-1cbb058bfcab" width="50%">

<br>


<img src="https://github.com/user-attachments/assets/ed023338-9124-40ca-bd07-fc1bd351c6c8" width="50%">

<br>

You will receive an email to verify account like the below:

<img src="https://github.com/user-attachments/assets/0d60e2fe-c689-49f6-9028-f724daaebbea" width="50%">

<br>

After verifying your account, you can skip the tour.

<img src="https://github.com/user-attachments/assets/7c40d6d6-a13c-4d9f-80ae-54f84228642f" with="50%">

## 4. Connect a repository for hands-on use to the CloudBees platform.

Once your account has been created, let’s connect the GitHub repository for hands-on use to the CloudBees Platform component.

<img src="https://github.com/user-attachments/assets/46fa0d20-cb43-4c73-9562-46b7bc79869b" width="50%">

Click the **Components** button from the side menu.

<img src="https://github.com/user-attachments/assets/ebaee3ba-825a-40fe-9328-ec3d767278d9" width="50%">

Next, click the **Connect your repositories** button.

<img src="https://github.com/user-attachments/assets/6192712e-9af7-489a-afc4-539d6493435e" width="50%">

Then, connect the repository that you created for the hands-on use.

<img src="https://github.com/user-attachments/assets/761350b1-a1d3-4d24-a788-7218cdc77ccb" width="50%">

<br>

<img src="https://github.com/user-attachments/assets/545c0a42-e4f6-4d52-8405-f9e227da9862" width="50%">

Finally, click the **Launchable** menu.

## 5. Issue an API Key and set.

After connecting the repository, issue an API key. You can also issue an API key from the Settings page.

<img src="https://github.com/user-attachments/assets/1f17be96-acf9-4825-8f9f-06790a14dc1c" width="50%">

<br>

Click the **Create a new API key**

<img src="https://user-images.githubusercontent.com/536667/191438711-b15eb234-e3d5-4ba2-b2fb-11d0ebd92d18.png" width="50%">

Click **Copy** key and copy API key.

<img src="https://github.com/user-attachments/assets/5025328b-fc20-4eb1-b7f2-346aab60e013" width="50%">

Once you create an API key, open the settings page of GitHub repository that created in step 1 and set the API key as a repository secret `LAUNCHABLE_TOKEN` under **Secrets and variables > Actions**.

![Screenshot from 2025-05-27 08-53-29](https://github.com/user-attachments/assets/956bbc03-599c-4551-8348-51497d0750d6)

![Screenshot from 2025-05-27 09-01-30](https://github.com/user-attachments/assets/924881cf-c69a-464e-97da-92ba4e43cb0d)

## 6. Ask the SE to set it to hands-on mode.

Set these workspaces to the special "hands on lab" mode from [the backoffice app](https://launchableinc.retool.com/apps/35915976-8697-11ef-88ca-d3dd93c47314/admin%20operation/issue%20triage%20%26%20PTS%20activation)

> [!NOTE]
> This can be only done by people who has special access.


___

Next: [Hands-on 2](HANDSON2.md)
