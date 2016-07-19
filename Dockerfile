FROM busybox

RUN dir=`mktemp -d` && trap 'rm -rf "$dir"' EXIT && \
    wget -O- http://nixos.org/releases/nix/nix-1.11.2/nix-1.11.2-x86_64-linux.tar.bz2  | bzcat | tar x -C $dir && \
    addgroup -S nixbld && \
    for n in $(seq 1 10); do \
      adduser \
        -s /bin/false \
        -G nixbld \
        -H \
        -S \
        -D \
        nixbld$n; \
    done && \ 
    mkdir -m 0755 /nix && USER=root sh $dir/*/install && \
    echo ". /root/.nix-profile/etc/profile.d/nix.sh" >> /etc/profile && \
    . /etc/profile && \
    nix-env -u && \
    nix-env -q

ONBUILD ENV PATH /root/.nix-profile/bin:/root/.nix-profile/sbin:/bin:/sbin:/usr/bin:/usr/sbin
ONBUILD ENV ENV /etc/profile
ENV ENV /etc/profile
