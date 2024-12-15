# run as root!
apt-get update -y
apt-get upgrade -y
apt-get install sudo -y


sudo apt-get install -y build-essential zlib1g-dev libyaml-dev libssl-dev libgdbm-dev libre2-dev \
  libreadline-dev libncurses5-dev libffi-dev curl openssh-server libxml2-dev libxslt-dev \
  libcurl4-openssl-dev libicu-dev libkrb5-dev logrotate rsync python3-docutils pkg-config cmake \
  runit-systemd


# Install gitaly
sudo apt-get install -y libcurl4-openssl-dev libexpat1-dev gettext libz-dev libssl-dev libpcre2-dev build-essential git-core


git clone https://gitlab.com/gitlab-org/gitaly.git -b 17-6-stable /tmp/gitaly
cd /tmp/gitaly
sudo apt install make pkg-config libcurl4-openssl-dev libssl-dev -y


sudo make git GIT_PREFIX=/usr/local


sudo apt remove -y git-core
sudo apt autoremove

# Install Ruby/Go/NodeJS/

gitlab-runner -l debug register --non-interactive --url https://gitlab.com/ --token glrt-t3_bZ4qAF4Sxcsfr2kXntK_ \
        --executor shell --name tf-test --docker-pull-policy always \
        --locked=false --run-untagged=false --docker-privileged=false \
        --limit 0 \
        --tag-list aws