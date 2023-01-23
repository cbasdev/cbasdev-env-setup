#!/bin/bash
### Instalar SDKMAN
Install_SDKMAN ()
{
    curl "https://get.sdkman.io/" | bash && \
    source ~/.sdkman/bin/sdkman-init.sh
    source ~/.bash_profile 
}
### Instalar Dev_Tools
Dev_Tools ()
{
    JavaVersion=$(sdk list java|grep "11.*-zulu"|tr -s " "|head -n 1|awk '{ print $8 }')
    
    sdk install java $JavaVersion & \
    sdk install gradle 3.5 & \
    #sdk install maven 3.5.4 & \
    sdk install grails 2.5.3 && \
    sdk install grails 2.5.4 go version
    
}
### Instalar HomeBrew
Install_Homebrew ()
{
    #Valida Xcode
    if ! [ -x "$(command -v xcode-select)" ]; then
        printf "${GR}Xcode no esta Instalado ${NC}\n"
        xcode-select --install
    fi
    
    /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
    echo "export PATH=$PATH:/opt/homebrew/bin" >> ~/.bash_profile 
    source ~/.bash_profile 
}
### Instalar Docker
Install_Docker ()
{
    brew install docker
}
### Instalar Python3
Install_Python3 ()
{
    brew install python3
}
### Instalar FuryCLI
Install_FuryCLI ()
{   
    if ! [ -x "$(command -v pip3)" ]; then
        printf "${GR}Pip no esta Instalado ${NC}\n"
        curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py 
        python3 get-pip.py --install
    fi
    
    pip3 install --user -i https://pypi.artifacts.furycloud.io/ furycli --upgrade --no-warn-script-location && \
    PYTHON_VERSION=`python3 -V | cut -d " " -f 2 | cut -c 1-3`
    echo '#Added by furycli:' >> ~/.zshrc
    echo "export PATH="$HOME/Library/Python/$PYTHON_VERSION/bin:$PATH"" >> ~/.zshrc
    echo '#Added by furycli:' >> ~/.bash_profile
    echo "export PATH="$HOME/Library/Python/$PYTHON_VERSION/bin:$PATH"" >> ~/.bash_profile
    ln -sf /Users/$USER/Library/Python/$PYTHON_VERSION/bin/fury
    source ~/.zshrc && \
    source ~/.bash_profile && \
    fury version # Para validar instalacion de furycli
    if [[ "$?" == 0 ]];
    then
        echo "Fury Client ha sido instalado exitosamente!"
    else
        echo "Fury Client no fue instalado correctamente, contactate con Internal Systems"
    fi
}
###Install Go
Install_Go ()
{
    #installing Go
    brew install go
    echo "export PATH=$PATH:/usr/local/go/bin" >> ~/.bash_profile 
    source ~/.bash_profile 
    go version
    if [[ "$?" == 0 ]];
    then
        echo "Go Instalado correctamente"
    else
        echo "Error al instalar Go"
    fi
}
#Install Nvm
Install_NVM ()
{
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.37.2/install.sh | bash
    export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    source ~/.bash_profile 
}
#Install FNM
Install_FNM ()
{
    brew install fnm
    eval "$(fnm env --use-on-cd --version-file-strategy=recursive)"
    source ~/.zshrc
}

#Install Node
Install_Node ()
{
    brew install node
    nvm install node
    brew install npm
}
#INSTALLING RVM AND RUBY
Install_Ruby ()
{
    echo "Installing RVM and Ruby"
    curl -sSL https://get.rvm.io | bash -s stable --ruby
    rvm install 2.7
    source ~/.bash_profile
}
#installing KIBANA AND ELASTIC SEARCH
Install_Elastic ()
{
    echo "Installing Kibana Full"
    brew tap elastic/tap
    brew install elastic/tap/kibana-full
    echo "Installing Elastic Search"
    brew install elastic/tap/elasticsearch-full
    
    JAVA_PATH=$(/usr/libexec/java_home)
    echo "export ES_JAVA_HOME=$JAVA_PATH" >> ~/.bash_profile
    echo "export JAVA_HOME=$JAVA_PATH" >> ~/.bash_profile
    source ~/.bash_profile
}
Install_Redis_mvn ()
{
    echo "Installing REDIS"
    brew install redis
    
    echo "Downloads Maven"
    brew install maven
}
    
##installing tools
Install_tools ()
{
    echo "Downloads VirtualBox"
    curl -o vbox.dmg  https://download.virtualbox.org/virtualbox/6.1.16/VirtualBox-6.1.16-140961-OSX.dmg
    
    echo "Installing Discord, Zoom, Github"
    brew install --cask zoom github discord    
}
Compliance_Check ()
{
#Script to check compliance status of a mac
    GR='\033[1;32m'
    RED='\033[1;31m'
    OR='\033[0;33m'
    YL='\033[1;33m'
    GY='\033[1;34m'
    NC='\033[0m' # No Color
    user=$(dscl . list /Users | grep -v '_' | grep -v 'daemon' | grep -v 'macadmin' | grep -v 'meliadmin' | grep -v 'mfe' | grep -v 'nobody' | grep -v 'root')
    printf "${NC}Verificando el compliance de la notebook....${NC}\n"
    #Check admin
    #printf "${NC}Verificando Admin: ${NC}"
    groups $user | grep -q -w admin; 
    if [ "$?" == 0 ]; then
        printf "${GR}Es admin${NC}\n"; 
    else 
        printf "${RED}No es admin${NC}\n"; 
    fi
    #Check Printers
    #printf "${NC}Verificando Impresoras: "
    if [ -x "$(command -v lpstat -p)" ]; then
        printf "${GR}Las impresoras estan instaladas${NC}\n"
    else
        printf "${RED}Las impresoras no estan instaladas${NC}\n"
    fi
    #Check Hostname
    #echo "Verificando Hostname"
    if [[ "$(command Hostname)" == "MX0"* ]]  || [[ "$(command Hostname)" == "AR0"* ]] || [[ "$(command Hostname)" == "CO0"* ]] || [[ "$(command Hostname)" == "BR0"* ]]  || [[ "$(command Hostname)" == "CL0"* ]] || [[ "$(command Hostname)" == "UR0"* ]]; then
        printf "${GR}Hostname Correcto${NC}\n"
    else
        printf "${RED}Hostname Incorrecto${NC}\n"
    fi
    #Check Account Mobile
    user=$(dscl . list /Users | grep -v '_' | grep -v 'daemon' | grep -v 'macadmin' | grep -v 'meliadmin' | grep -v 'mfe' | grep -v 'nobody' | grep -v 'root')
    printf "La cuenta movil es: ${GR}${user}${NC}\n" 
    #Check Brew
    #echo "Verificando Brew: "
    if [ -x "$(command -v brew)" ]; then
        printf "${GR}Brew esta instalado${NC}\n"
    else
        printf "${RED}Brew no esta instalado${NC}\n"
    fi
    #Check Python3 
    #echo "Verificando Python: "
    if [ -x "$(command -v python3)" ]; then
        printf "${GR}Python3 esta instalado${NC}\n"
    else
        printf "${RED}Python3 no esta instalado${NC}\n"
    fi
    #Check GIT
    #echo "Verificando git"
    if [ -x "$(command -v git)" ]; then
        printf "${GR}Git esta instalado${NC}\n"
    else
        printf "${RED}Git no esta instalado${NC}\n"
    fi
    #Check MHUNT
    #echo "Verificando Mhunt"
    if [ -x "$(command -v pgrep mhuntagent)" ]; then
        printf "${GR}Mhunt esta instalado${NC}\n"
    else
        printf "${RED}Mhunt no esta instalado${NC}\n"
    fi
    #Check HUB WSONE
    #echo "Verificando Ivanti"
    if [ -x "$(command -v pgrep IntelligentHubAgent)" ]; then
        printf "${GR}WSONE esta Instalado${NC}\n"
    else
        printf "${RED}WSONE no esta Instalado${NC}\n"
    fi
    #Check CROWSTRIKE
    #echo "Verificando Mcafee"
    if [ -x "$(command -v sysctl cs)" ]; then
        printf "${GR}Crowstrike esta Instalado${NC}\n"
    else
        printf "${RED}Crowstrike no esta Instalado${NC}\n"
    fi
    #Check GP
    #echo "Verificando Global Protect"
    if [ -x "$(command -v pgrep GlobalProtect)" ]; then
        printf "${GR}GlobalProtect esta instalado${NC}\n"
    else
        printf "${RED}GlobalProtect no esta instalado${NC}\n"
    fi
    #Check Fury
    #echo "Verificando Fury"
    if [ -x "$(command -v fury)" ]; then
        printf "${GR}Fury esta instalado${NC}\n"
    else
        printf "${RED}Fury no esta instalado${NC}\n"
    fi
    #Check Dominio
    #echo "Verificando union al dominio:"
    #ping -c 3 -o arardc01.ml.com 1> /dev/null 2> /dev/null
    nc -vz ml.com 389 > /dev/null 2>&1
    if [[ $? == 0 ]]; then
        domain=$( dsconfigad -show | awk '/Active Directory Domain/{print $NF}' )
        if [[ "$domain" == "ml.com" ]]; then
            if [[ $? == 0 ]]; then
                printf "${GR}Esta en AD${NC}\n"
            else
                printf "${RED}No esta en AD${NC}\n"
            fi
        else
            printf "${OR}No esta vinculada al dominio de Meli${NC}\n"
        fi
    else
        printf "${YL}El DC no esta en rango${NC}\n"
    fi
    #Check Go
    if [ -x "$(command -v go version)" ]; then
        printf "${GR}Go esta Instalado\n"
    else
        printf "${RED}Go no esta instalado \n"
    fi
    #Check SDKMan
    sdk=$(command -v sdk version)
    if [ sdk ]; then
        printf "${GR}SDKMan esta instalado \n"
    else
        printf "${RED}SDKMan no esta Instalado \n"
    fi
    #Check NPM
    if [ -x "$(command -v npm)" ]; then
        printf "${GR}NPM esta Instalado \n"
    else
        printf "${RED}NPM no esta instalado \n"
    fi
    #Check Node
    nvm=$(command -v nvm --version)
    if [ nvm ]; then
        printf "${GR}Nvm esta Instalado \n"
    else
        printf "${RED}Nvm no esta instalado \n"
    fi
    if [ -x "$(command -v node --version)" ]; then
        printf "${GR}Node esta Instalado \n"
    else
        printf "${RED}Node no esta instalado \n"
    fi
    #Check Ruby
    if [ -x "$(command -v ruby -v)" ]; then
        printf "${GR}Ruby esta Instalado \n"
    else
        printf "${RED}Ruby no esta instalado \n"
    fi
    #Check Maven
    mvn=$(command -v mvn -version)
    if [ mvn ]; then
        printf "${GR}Maven esta Instalado \n"
    else
        printf "${RED}Maven no esta instalado \n"
    fi
    #Check Redis
    if [ -x "$(command -v redis-cli)" ]; then
        printf "${GR}Redis esta Instalado \n"
    else
        printf "${RED}Redis no esta instalado \n"
    fi
    #Check Elasticsearch
    if [ -x "$(command -v elasticsearch --version)" ]; then #Revisar Elasticsearch e instalar java jdk btw
        printf "${GR}ElasticSearch esta Instalado \n"
    else
        printf "${RED}ElasticSearch no esta instalado \n"
    fi
    #Check Kibana
    if [ -x "$(command -v kibana)" ]; then
        printf "${GR}Kibana esta Instalado ${NC}\n"
    else
        printf "${RED}Kibana no esta instalado ${NC}\n"
    fi
    #check zoom
    ls /Applications | grep -i zoom > /dev/null
    if [ "$?" == 0 ]; then
        printf "${GR}Zoom esta instalado${NC}\n"
    else
        printf "${RED}Zoom no esta instalado${NC}\n"
    fi
    #check Github
    ls /Applications | grep -i github > /dev/null
    if [ "$?" == 0 ]; then
        printf "${GR}Github esta instalado${NC}\n"
    else
        printf "${RED}Github no esta instalado${NC}\n"
    fi
    #check discord
    ls /Applications | grep -i discord > /dev/null
    if [ "$?" == 0 ]; then
        printf "${GR}Discord esta instalado${NC}\n"
    else
        printf "${RED}Discord no esta instalado${NC}\n"
    fi
}
### Funcion menu
Menu ()
{
    echo ""
	echo "  1) Instalar todo el ambiente"
	echo "  2) Instalar SDKMAN"
	echo "  3) Instalar Homebrew"
    echo "  4) Instalar Docker"
    echo "  5) Instalar Python3"
	echo "  6) Instalar Furycli"
    echo "  7) Instalar Go"
    echo "  8) Instalar FNM"
    echo "  9) Instalar Node"
	echo "  10) Instalar Ruby"
    echo "  11) Instalar Elastic Search"
    echo "  12) Instalar REDIS & Maven"
    echo "  13) Tools VB/Discord/Zoom/Github"
    echo "  14) Check BootcampIT"
	echo "  15) Salir"
	echo ""
	echo "Indica una opcion:  "
}
### Menu Principal
opc=0
until [ $opc -eq 15 ]
do
    case $opc in
        1)  
            Install_SDKMAN
            Dev_Tools
            Install_Homebrew
            Install_Docker
            Install_Python3
            Install_FuryCLI
            Install_Go
            Install_NVM
            Install_FNM
            Install_Node
            Install_Ruby
            Install_Elastic
            Install_Redis_mvn
            Install_tools
            Compliance_Check
            Menu
            ;;
        2)  
            Install_SDKMAN
            Menu
            ;;
        3)
            Install_Homebrew
            Menu
            ;;
        4)  
            Install_Docker
            Menu
            ;;
        5)
            Install_Python3
            Menu
            ;;
            
        6)
            Install_FuryCLI
            Menu
            ;;
        7)
            Install_Go
            Menu
            ;;
        8)
            Install_FNM
            Menu
            ;;
        9)
            Install_Node
            Menu
            ;;
        10)
            Install_Ruby
            Menu
            ;;
        11)
            Install_Elastic
            Menu
            ;;
        12)
            Install_Redis_mvn
            Menu
            ;;
        13)
            Install_tools
            Menu
            ;;
        14)
            Compliance_Check
            Menu
            ;;
        *)
            Menu
            ;;
    esac
    read opc
done
#EOF
