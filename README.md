# proxy-config

> **⚠️ Personal setup, not intended for production use.**
> This configuration is tailored to a specific personal environment. It is published for reference only. Use at your own risk.

## Setup

```bash
git clone https://github.com/LynxTR/proxy-config.git && \
cd proxy-config && \
sudo ./bootstrap.sh
```

## Commands

```bash
lynxsetup list                                                              # show all domains
sudo lynxsetup add <domain> <backend-ip> <port>                             # add an app
sudo lynxsetup add-imgproxy <domain> <backend-ip> <port>                    # add imgproxy cache
sudo lynxsetup add-r2 <domain> <r2-custom-domain> [path-prefix]                    # add R2 bucket proxy
sudo lynxsetup add-ssh-key "<pubkey>"                                       # add SSH key + disable password auth
sudo lynxsetup delete <domain>                                              # remove (prompts confirm)
sudo lynxsetup delete <domain> -y                                           # remove without prompt
```

## Examples

```bash
sudo lynxsetup add app.example.com 10.0.0.1 3000
sudo lynxsetup add-imgproxy img.example.com 10.0.0.1 8080
sudo lynxsetup add-r2 assets.example.com r2.example.com /assets
lynxsetup list
sudo lynxsetup delete app.example.com
```

## R2 Bucket Proxy

Serves files from a Cloudflare R2 bucket via its Cloudflare custom domain.

**Prerequisite:** attach a custom domain to your bucket in the Cloudflare dashboard:

```bash
sudo lynxsetup add-r2 <domain> <r2-custom-domain> [path-prefix]
```

## fail2ban

```bash
fail2ban-client status                     # list jails
fail2ban-client status sshd               # banned IPs
fail2ban-client set sshd unbanip 1.2.3.4  # unban
```

`sshd-aggressive` (bans on first SSH failure) is enabled by default — only safe with key-only auth. Disable it in `fail2ban/jail.d/ssh.conf` if needed.
