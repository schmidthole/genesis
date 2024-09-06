# Genesis

a minimalist and opinionated installation template for golang applications. this is mostly for me to not have
to deal with writing the same script for every application.

`genesis` will stage and install a Golang application onto a linux host and run it as a systemd service.
It assumes the following:

* The app will be run from `/opt/{app_name}/{app_binary}`
* The app will have a config file located at `/etc/{app_config_file}`
* The app will store its data in `/var/{app_name}/`

## Usage

Run the script by downloading it and executing with your desired arguments...

```sh
wget -qO- https://raw.githubusercontent.com/schmidthole/genesis/main/genesis.sh | bash -s -- \
  --app "app_name" \ 
  --binary "path/to/app" \ 
  --exec "/opt/app -config /etc/app-config" \
  --config "/path/to/config"
  --target "root@1.1.1.1"
```
