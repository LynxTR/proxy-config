# proxy-config

Created to quickly set up a proxy server. If you are thinking of using it, please check the code beforehand.

## Copy-paste

```bash
git clone https://github.com/LynxTR/proxy-config.git && \
cd proxy-config && \
sudo ./bootstrap.sh
```

## Help

```bash
lynxsetup list                                                              # show all domains

sudo lynxsetup add <domain> <backend-ip> <port>                             # add an app
sudo lynxsetup add-imgproxy <domain> <backend-ip> <port>                    # add imgproxy cache
sudo lynxsetup add-r2 <domain> <r2-custom-domain> [path-prefix]             # add R2 bucket proxy
sudo lynxsetup add-ssh-key "<pubkey>"                                       # add SSH key + disable password auth
sudo lynxsetup add-cert <domain> <cert-path> <key-path>                     # add SSH key + disable password auth
sudo lynxsetup delete <domain>                                              # remove (prompts confirm)
sudo lynxsetup delete <domain> -y                                           # remove without prompt

fail2ban-client status                                                      # list jails
fail2ban-client status sshd                                                 # banned IPs
fail2ban-client set sshd unbanip 1.2.3.4                                    # unban
```

## Examples

```bash
lynxsetup list
sudo lynxsetup add app.example.com 10.0.0.1 3000
sudo lynxsetup add-imgproxy img.example.com 10.0.0.1 8080
sudo lynxsetup add-r2 assets.example.com r2.example.com /assets
sudo lynxsetup delete app.example.com
```
