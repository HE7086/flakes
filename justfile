FLAKE_PATH := `nix flake metadata --json | jq '.path'`

deploy HOSTS=`ls ./hosts | sed 's/\.nix$//' | xargs`:
    #!/bin/bash
    for host in {{HOSTS}}; do
        rsync -acvF -hh --info=stats1 --info=progress2 --modify-window=1 --delete -e ssh \
            {{FLAKE_PATH}}/ root@$host:/etc/nixos
        ssh root@$host nixos-rebuild switch --fast --flake /etc/nixos
    done
