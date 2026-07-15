> [!NOTE]
> Deprecated
>
> use macos now :(

# Noname's NixOS Flake

## Usage

- fill in `secret.nix`
- run `git add -N -f secret.nix`
- run `sudo nixos-rebuild switch --flake .#nixos`

## DNS firefighting

1. add tls://223.5.5.5 to every dns option

2. refresh config

```sh
# 切换到本地 DNS
curl -X PUT http://127.0.0.1:9090/configs \
  -d '{"path": "/path/to/config-local.yaml", "force": true}'
# 恢复正常 DNS
curl -X PUT http://127.0.0.1:9090/configs \
  -d '{"path": "/path/to/config-normal.yaml", "force": true}'
```
