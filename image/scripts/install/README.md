# Cloud Workstation base configuration

All scripts in this directory that start with `install_` are run by the `full_install.bash` script at image baking time and are used to customize the Cloud Workstation image as all are copied to the image into the `.config/install` directory of the `root` user.

To customize further, there are three options:

- If you're adding an `apt` package, just add it to the list inside the `install_apt_packages.bash` script.
- If you're adding a Code OSS or VSCode extension, add it to corresponding associative array inside the `install_vscode_extensions.bash` script.
- If you're installing something else, write a dedicated script following the convention `install_<binary name>.bash`, and give it execution permissions.