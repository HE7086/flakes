FLAKE_PATH := `nix flake metadata --json | jq '.path'`

deploy HOSTS=`ls ./hosts | sed 's/\.nix$//' | xargs`:
    #!/bin/bash
    for host in {{HOSTS}}; do
        printf "\033[1;31mDeploying [$host]...\033[0m\n"
        rsync -acvF -hh --info=stats1 --info=progress2 --modify-window=1 --delete -e ssh \
            {{FLAKE_PATH}}/ root@$host:/etc/nixos
        ssh root@$host nixos-rebuild switch --fast --flake /etc/nixos
        if [ $? -eq 0 ]; then
            printf "\033[1;32mDeploy complete for [$host]\033[0m\n"
        else
            printf "\033[1;31m!!!Deploy failed for [$host]!!!\033[0m\n"
        fi
    done
