# Bootstrapping your Cloud Workstation

Here are the basic steps you need to perform to get your Cloud Workstation up and running. We've done most of the tasks for you, but there are a few things you need to do by yourself to get started.

## First time setup

There's an automated process you can run with

```bash
ws_bootstrap.bash
```

If you prefer doing the steps by yourself, read on.

### Login in to Google Cloud

Log in to Google Cloud for API and services access:

```bash
gcloud auth login
```

Log in to Google Cloud to get Application Default Credentials for your apps:

```bash
gcloud auth application-default login
```

### Configure your Git credentials

```bash
ws_setup_git_keys.bash
```

### Get your dotfiles

Get your dotfiles from the repository and bootstrap any local configuration you may have:

```bash
ssh-keyscan -H gitlab.com > ~/.ssh/known_hosts
yadm clone "$DOTFILES_REPO" --bootstrap -f
```

Finally, make sure you substitute any placeholders in your dotfiles with the correct values:

```bash
ws_yadm_full_reset.bash
```

## Updating your dotfiles

To update your dotfiles, simply follow the instructions in the [yadm page](https://yadm.io/docs/common_commands).

We recommend you periodically backup your Code OSS extensions and check in the resulting extensions list:

```bash
wx_backup_code_extensions.bash
```
