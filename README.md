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
sudo lynxsetup add-cert <domain> <cert-path> <key-path>                     # install TLS cert and enable HTTPS
sudo lynxsetup delete <domain>                                              # remove (prompts confirm)
sudo lynxsetup delete <domain> -y                                           # remove without prompt

sudo lynxsetup trust-ip <ip/cidr> [comment]                                 # allow IP to bypass Cloudflare check
sudo lynxsetup untrust-ip <ip/cidr>                                         # remove trusted IP
lynxsetup list-trusted                                                      # list all trusted IPs

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
sudo lynxsetup trust-ip 1.2.3.4 "office"
sudo lynxsetup trust-ip 10.0.0.0/8
sudo lynxsetup untrust-ip 1.2.3.4
lynxsetup list-trusted
```
