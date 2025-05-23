alias c := check
alias d := deploy
alias bd := build-deploy

hosts := `nix flake show --json 2>/dev/null | jq -r '.nixosConfigurations | keys[]' | xargs`

deploy-to HOST FLAKE:
    #!/bin/bash
    set -euo pipefail
    printf "\033[1;31m[{{HOST}}] Deploying...\033[0m\n"
    nix shell 'nixpkgs#nixos-rebuild' \
        -c nixos-rebuild \
        --target-host root@{{HOST}} \
        --build-host root@{{HOST}} \
        --flake ".#{{FLAKE}}" \
        --fast \
        switch
    if [ $? -eq 0 ]; then
        printf "\033[1;32m[{{HOST}} Deploy Complete\033[0m\n"
    else
        printf "\033[1;31m[{{HOST}} Deploy Failed!!!\033[0m\n"
    fi

deploy HOSTS=hosts:
    #!/bin/bash
    set -euo pipefail
    for host in {{HOSTS}}; do
        printf "\033[1;31m[$host] Deploying...\033[0m\n"
        nix shell 'nixpkgs#nixos-rebuild' \
            -c nixos-rebuild \
            --target-host root@$host \
            --build-host root@$host \
            --flake ".#$host" \
            --fast \
            switch
        if [ $? -eq 0 ]; then
            printf "\033[1;32m[$host] Deploy Complete\033[0m\n"
        else
            printf "\033[1;31m[$host] Deploy Failed!!!\033[0m\n"
        fi
    done

build-deploy HOSTS=hosts:
    #!/bin/bash
    set -euo pipefail
    for host in {{HOSTS}}; do
        printf "\033[1;31m[$host] Deploying...\033[0m\n"
        nix shell 'nixpkgs#nixos-rebuild' \
            -c nixos-rebuild \
            --target-host root@$host \
            --build-host localhost \
            --flake ".#$host" \
            switch
        if [ $? -eq 0 ]; then
            printf "\033[1;32m[$host] Deploy Complete\033[0m\n"
        else
            printf "\033[1;31m[$host] Deploy Failed!!!\033[0m\n"
        fi
    done

deploy-config HOSTS=hosts:
    #!/bin/bash
    set -euo pipefail
    FLAKE_PATH=$(nix flake metadata --json | jq -r '.path')
    for host in {{HOSTS}}; do
        printf "\033[1;31m[$host] Deploying Config...\033[0m\n"
        rsync -acvF -hh --info=stats1 --info=progress2 --modify-window=1 --delete \
            -e ssh \
            $FLAKE_PATH/ \
            root@$host:/etc/nixos
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
    # nix --extra-experimental-features 'repl-flake' repl '.#nixosConfigurations'
    # :p fridge.config.nix.settings
    # lib = import fridge.pkgs.lib
    nix repl --show-trace '.#nixosConfigurations'

check:
    git amend && nix flake check

update:
    nix flake update && git add flake.lock && git commit -m 'flake update'
