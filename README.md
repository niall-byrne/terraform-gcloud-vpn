terraform-gcloud-vpn
====================

Leverage Google Cloud to create a personal VPN server and client side configuration all in one step.<br>
The instructions primarily target folks using OSX, but can be adapted for Windows or Linux users.

##Dependencies

You'll need to install [Terraform](https://www.terraform.io/) and the [gcloud](https://cloud.google.com/sdk/) cli tool.


##Configuration

Generate a new set of public and private ssh keys to use with your server:
```
    $ ssh-keygen
```

Create a fresh project in your GCE account, and take note of the three fields associated with it:

1. The project name
2. The project id
3. The organization number

Enter the filename of the ssh public key, and the project values into the configuration file:
```
    $ vi config/config.tfvars
```


##Create a VPN Server

Once you have configured the settings, you can provision a server:
```
    ./form.sh create
```

This could take as long as 15 minutes, as generating the diffie-hellman key takes considerable time on a economical compute instance.
Once it has finished, a 'configurations' folder will be created, containing 5 unique client opvn files.

If you're on a mac, download [tunnelblick](https://tunnelblick.net/) and import the configuration.
There are similar tools for Windows/Linux based computers.


##Delete your VPN Server

If you're finished with your VPN server, simply run the following command:
```
    ./form.sh destroy
```
