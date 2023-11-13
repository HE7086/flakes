alias d := deploy

FLAKE_PATH := `nix flake metadata --json | jq '.path'`

deploy HOSTS=`ls ./hosts | sed 's/\.nix$//' | xargs`:
    #!/bin/bash
    [[ -z "{{FLAKE_PATH}}" ]] && echo FLAKE_PATH is empty, check your nix daemon && exit 1
    for host in {{HOSTS}}; do
        printf "\033[1;31m[$host] Deploying...\033[0m\n"
        rsync -acvF -hh --info=stats1 --info=progress2 --modify-window=1 --delete -e ssh \
            {{FLAKE_PATH}}/ root@$host:/etc/nixos
        ssh root@$host nixos-rebuild switch --fast --flake /etc/nixos
        if [ $? -eq 0 ]; then
            printf "\033[1;32mDeploy complete for [$host]\033[0m\n"
        else
            printf "\033[1;31m[$host] Deploy Failed!!!\033[0m\n"
        fi
    done

update-sops:
    sops updatekeys --yes secrets.yaml

get-age:
    nix shell 'nixpkgs#ssh-to-age' -c ssh-to-age </etc/ssh/ssh_host_ed25519_key.pub

repl:
    nix --extra-experimental-features 'repl-flake' repl .#nixosConfigurations

update:
    nix flake update && git add flake.lock && git commit -m "flake update"
