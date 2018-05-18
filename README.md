# linux-aws-iam-user
A set of scripts to manage local user accounts and groups on Red Hat Enterprise Linux (including CentOS) driven by AWS IAM


## Includes:

1. create-lnx-user.sh | to create a new local user based on an AWS IAM user + SSH public key
2. delete-lnx-user.sh | to delete local users including the termination of running processes
3. create-sudo-dropin.sh | to create a NOPASSWD sudo drop-in file


## TODO:

- Write out the AWS IAM policy  
- SSH public key checking
- Group creation (including adding the user to that group)
- Checks for the aws command
- Delete script
- Verbose option
- Test and adapt to make it work on Amazon Linux


## Pull requests and patches

We are open to pull requests and patches!

Just make sure you run [ShellCheck](https://github.com/koalaman/shellcheck/) first (it's okay to ignore `SC2181`)
