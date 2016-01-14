# COLORS
RED='\033[0;31m'
BLUE='\033[0;34m'
GREEN='\033[0;32m'
ORANGE='\033[0;33m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

echo ""
echo -e "${ORANGE}Server domain name [thetessera.org]:${NC} "
read domainname
if [ "$domainname" == "" ]; then
    domainname="thetessera.org"
fi

echo ""
echo -e "${ORANGE}API server proxy_pass URL [http://127.0.0.1:8000]:${NC} "
read apiURL
if [ "$apiURL" == "" ]; then
    apiURL="http://127.0.0.1:8000"
fi

echo ""
echo -e "${ORANGE}DB username [dbuser]:${NC} "
read dbusername
if [ "$dbusername" == "" ]; then
    dbusername="dbuser"
fi

echo ""
echo -e "${ORANGE}DB password for '$dbusername' [dbpassword]:${NC} "
read dbpassword
if [ "$dbpassword" == "" ]; then
    dbpassword="dbpassword"
fi

echo ""
echo -e "${ORANGE}Name for git [Tessera]:${NC} "
read gitname
if [ "$gitname" == "" ]; then
    gitname="Tessera"
fi

echo ""
echo -e "${ORANGE}Email address for git [git@thetessera.org]:${NC} "
read gitemail
if [ "$gitemail" == "" ]; then
    gitemail="git@thetessera.org"
fi


# APT-GET
echo -e "${YELLOW}Let's begin. Updating sources...${NC}"
echo ""
echo -e "${CYAN}Adding apt keys and repos... ${NC}"
    sudo apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys B97B0AFCAA1A47F044F244A07FCC7D46ACCC4CF8
    printf "deb http://apt.postgresql.org/pub/repos/apt/ precise-pgdg main" \
     | sudo tee /etc/apt/sources.list.d/pgdg.list
echo ""
echo -e "${CYAN}Updating. Please wait... ${NC}"
sudo apt-get -qq update
sudo apt-get -qq install -y curl

# NODEJS
echo -e "${YELLOW}Now installing node (v4.x)...${NC}"
	curl -sL https://deb.nodesource.com/setup_4.x | sudo -E bash -
	sudo apt-get -qq install -y nodejs
	sudo apt-get -qq install -y build-essential
echo -e "${GREEN}Done! (node, nodejs)"
echo ""
echo ""


# NGINX
echo -e "${YELLOW}Now installing nginx...${NC}"
	sudo apt-get -qq install -y nginx
echo -e "${GREEN}Done! (nginx)"
echo ""
echo ""


# NGINX CONFIG
echo -e "${YELLOW}Now configuring nginx server...${NC}"
    HOMEPATH=~
    mkdir -p ~/.www
    mkdir -p ~/.www/api
    echo "it works!" > ~/.www/index.html
printf "server {
    listen 80;

    server_name $domainname;

    root $HOMEPATH/.www;
    index index.html index.htm;

    location /api/ {
        proxy_pass $apiURL;
    }
}\n" | sudo tee /etc/nginx/sites-available/default
echo -e "${CYAN}Restarting nginx... ${NC}"
  sudo service nginx restart
echo -e "${GREEN}Done! (nginx configuration)"
echo ""
echo ""



# POSTGRESQL
echo -e "${YELLOW}Now installing PostgreSQL...${NC}"
    sudo apt-get -qq install -y python-software-properties \
        software-properties-common \
        postgresql-9.3 \
        postgresql-client-9.3 \
        postgresql-contrib-9.3
echo -e "${CYAN}Creating initial databases and user... ${NC}"
    sudo /etc/init.d/postgresql start
    sudo -u postgres psql --command "CREATE USER $dbusername WITH SUPERUSER PASSWORD '$dbpassword';"
if sudo -u postgres psql -lqt | cut -d \| -f 1 | grep -w dev; then
    echo "'dev' database already exists"
else
    sudo -u postgres createdb -O $dbusername dev
fi
if sudo -u postgres psql -lqt | cut -d \| -f 1 | grep -w prod; then
    echo "'prod' database already exists"
else
    sudo -u postgres createdb -O $dbusername prod
fi
echo -e "${CYAN}Setting privileges... ${NC}"
    echo "host    all    all    0.0.0.0/0    md5" \
        | sudo tee --append /etc/postgresql/9.3/main/pg_hba.conf
    echo "listen_addresses='*'" \
        | sudo tee --append /etc/postgresql/9.3/main/postgresql.conf
echo -e "${GREEN}Done! (PostgreSQL)"
echo ""
echo ""

# OTHERS
echo -e "${YELLOW}Now installing other packages (git, gparted, vim, meld, forever)...${NC}"
sudo apt-get -qq install -y git gparted vim meld
echo prefix = ~/.node >> ~/.npmrc
echo 'export PATH=$PATH:$HOME/.node/bin' >> ~/.bashrc
echo 'export NODE_PATH=$NODE_PATH:$HOME/.node/lib/node_modules' >> ~/.bashrc
echo 'export PYTHONPATH=$PYTHONPATH:$HOME/.node/lib/node_modules' >> ~/.bashrc
echo 'export PATH=$PATH:$HOME/.node/bin' >> ~/.profile
echo 'export NODE_PATH=$NODE_PATH:$HOME/.node/lib/node_modules' >> ~/.profile
echo 'export PYTHONPATH=$PYTHONPATH:$HOME/.node/lib/node_modules' >> ~/.profile
hash -r
source ~/.bashrc
echo -e "${GREEN}Done! (others)"
echo ""
echo ""

echo -e "${YELLOW}Now extending ~/.bashrc...${NC}"
npm install -g --prefix=$(npm config get prefix) forever
git clone https://github.com/magicmonty/bash-git-prompt.git ~/.bash-git-prompt
(cd ~/.bash-git-prompt && git reset --hard eb2554395c43287c1ada1544012106b61f8ce3c8)
echo "source ~/.bash-git-prompt/gitprompt.sh" >> ~/.bashrc
cp ~/.bash-git-prompt/git-prompt-colors.sh ~/.git-prompt-colors.sh
sed -i -e 's/\xe2\x97\x8f/\xe2\x80\xa2/' -e 's/\xe2\x9c\x96/\xe2\x98\xa2\x20/' -e 's/\xe2\x9c\x9a/\xc2\xb1/' -e 's/\xe2\x9a\x91/\xe2\xad\x91/' -e 's/\xe2\x9a\x91/\xe2\xad\x91/' -e 's/\xe2\x86\x91\xc2\xb7/\xe2\x86\x91/' -e 's/\xe2\x86\x93\xc2\xb7/\xe2\x86\x93/' ~/.git-prompt-colors.sh
printf '\n  GIT_PROMPT_START="$BoldBlue\w$ResetColor"\n  GIT_PROMPT_END=" $ "' >> ~/.git-prompt-colors.sh
echo -e "${GREEN}Done! (extending bashrc)"
echo ""
echo ""


echo -e "${YELLOW}Now configuring git...${NC}"
git config --global merge.tool meld
git config --global mergetool.keepBackup false
git config --global diff.tool meld
git config --global --add color.ui true
git config --global push.default simple
git config --global user.email "$gitemail"
git config --global user.name "$gitname"
git config --global core.pager 'less -x5,9'
git config --global pull.ff only
echo -e "${GREEN}Done! (configuring git)"
echo ""
echo ""

echo -e "${YELLOW}Generating public SSH key...${NC}"
ssh-keygen -t rsa -b 2048 -C "$email" -N "" -f ~/.ssh/id_rsa
echo -e "${GREEN}Done! (generating SSH key)"
echo ""
echo ""


# AUTOREMOVE
echo -e "${YELLOW}Cleaning up...${NC}"
sudo apt-get -y autoremove
echo -e "${GREEN}Done! (clean up)${NC}"
echo ""
echo ""

# SUMMARY
echo ""
echo -e "${YELLOW}OK. All done. Here is a summary:${NC}"
echo -e "${CYAN}Domain Name: ${NC}$domainname"
echo -e "${CYAN}API URL: ${NC}$apiURL"
echo -e "${CYAN}nginx content folder: ${NC}~/.www"
echo -e "${CYAN}DB Username: ${NC}$dbusername"
echo -e "${CYAN}DB Password: ${NC}$dbpassword"
echo -e "${CYAN}DBs: ${NC}dev, prod"
echo -e "${CYAN}git name: ${NC}$gitname"
echo -e "${CYAN}git e-mail: ${NC}$gitemail"
echo -e "${CYAN}ssh public key: ${NC}~/.ssh/id_rsa.pub"
echo ""
echo ""
echo -e "${YELLOW}To complete all changes and reload bash, please log out and in again.${NC}"
echo ""
