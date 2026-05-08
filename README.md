# proxy-config

nginx reverse proxy for Ubuntu 24 LTS — sits behind Cloudflare, forwards to backend servers, optionally caches images via imgproxy. Includes fail2ban and kernel tuning.

## Setup

Run once on a fresh server:

```bash
git clone https://github.com/LynxTR/proxy-config.git && \
cd proxy-config && \
sudo ./bootstrap.sh
```

Installs nginx + fail2ban, applies sysctl tuning, deploys all configs, and puts `lynxsetup` on your PATH.

## Commands

```bash
lynxsetup list                                           # show all domains
sudo lynxsetup add <domain> <backend-ip> <port>          # add an app
sudo lynxsetup add-imgproxy <domain> <backend-ip> <port> # add imgproxy cache
sudo lynxsetup add-ssh-key "<pubkey>"                    # add SSH key + disable password auth
sudo lynxsetup delete <domain>                           # remove (prompts confirm)
sudo lynxsetup delete <domain> -y                        # remove without prompt
```

## Examples

```bash
sudo lynxsetup add app.example.com 10.0.0.1 3000
sudo lynxsetup add-imgproxy img.example.com 10.0.0.1 8080
lynxsetup list
sudo lynxsetup delete app.example.com
```

## Cloudflare

For each domain: DNS A record → orange cloud on → SSL/TLS mode **Flexible**.

> Direct connections to the server IP (bypassing Cloudflare) are blocked with 403.

## fail2ban

```bash
fail2ban-client status                     # list jails
fail2ban-client status sshd               # banned IPs
fail2ban-client set sshd unbanip 1.2.3.4  # unban
```

`sshd-aggressive` (bans on first SSH failure) is enabled by default — only safe with key-only auth. Disable it in `fail2ban/jail.d/ssh.conf` if needed.
