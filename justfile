alias d := deploy
alias bd := build-deploy

deploy HOSTS=`ls ./hosts | sed 's/\.nix$//' | xargs`:
    #!/bin/bash
    set -euo pipefail
    FLAKE_PATH=$(nix flake metadata --json | jq -r '.path')
    for host in {{HOSTS}}; do
        printf "\033[1;31m[$host] Deploying...\033[0m\n"
        # rsync -acvF -hh --info=stats1 --info=progress2 --modify-window=1 --delete \
        #     -e ssh \
        #     $FLAKE_PATH/ \
        #     root@$host:/etc/nixos
        # ssh root@$host nixos-rebuild switch --flake /etc/nixos
        nix shell 'nixpkgs#nixos-rebuild' \
            -c nixos-rebuild \
            --target-host root@$host \
            --build-host root@$host \
            --flake ".#$host" \
            --verbose \
            --fast \
            switch
        if [ $? -eq 0 ]; then
            printf "\033[1;32m[$host] Deploy Complete\033[0m\n"
        else
            printf "\033[1;31m[$host] Deploy Failed!!!\033[0m\n"
        fi
    done

build-deploy HOSTS=`ls ./hosts | sed 's/\.nix$//' | xargs`:
    #!/bin/bash
    set -euo pipefail
    for host in {{HOSTS}}; do
        printf "\033[1;31m[$host] Deploying...\033[0m\n"
        nix shell 'nixpkgs#nixos-rebuild' \
            -c nixos-rebuild \
            --target-host root@$host \
            --build-host localhost \
            --flake ".#$host" \
            --verbose \
            switch
        if [ $? -eq 0 ]; then
            printf "\033[1;32m[$host] Deploy Complete\033[0m\n"
        else
            printf "\033[1;31m[$host] Deploy Failed!!!\033[0m\n"
        fi
    done

update-sops:
    find secrets -name '*.yaml' -exec sops updatekeys --yes {} \;

get-age:
    nix shell 'nixpkgs#ssh-to-age' -c ssh-to-age </etc/ssh/ssh_host_ed25519_key.pub

repl:
    nix --extra-experimental-features 'repl-flake' repl '.#nixosConfigurations'

update:
    nix flake update && git add flake.lock && git commit -m 'flake update'
