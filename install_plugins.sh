#!/bin/bash
Install_Homebrew ()
{
    if ! [ -x "$(command -v xcode-select)" ]; then
        printf "${GR}Xcode no esta Instalado ${NC}\n"
        xcode-select --install
    fi
    
    /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
    echo "export PATH=$PATH:/opt/homebrew/bin" >> ~/.bash_profile 
    source ~/.bash_profile 
}

Install_OhMyZsh ()
{
  sh -c "$(wget https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh -O -)"
}
Install_ZshAutoSuggestions ()
{
  git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
}
Install_ZshSyntaxHighlighting ()
{
  brew install zsh-syntax-highlighting
}

Menu ()
{
  echo ""
	echo "  1) Instalar todo el ambiente"
	echo "  2) Instalar Homebrew"
	echo "  3) Instalar oh-my-zsh"
  echo "  6) Instalar zsh-autosuggestions"
  echo "  7) Instalar zsh-syntax-highlighting"
	echo "  8) Salir"
	echo ""
	echo "Indica una opcion:  "
}
opc=0
until [ $opc -eq 15 ]
do
    case $opc in
        1)  
            Install_SDKMAN
            Install_Homebrew
            Install_OhMyZsh
            Install_P10K
            Install_Fig
            Menu
            ;;
        2)  
            Install_Homebrew
            Menu
            ;;
        3)
            Install_OhMyZsh
            Menu
            ;;
        4)
            Install_P10K
            Menu
            ;;
        5)
            Install_Fig
            Menu
            ;;
        6) 
            Install_ZshAutoSuggestions
            Menu
            ;;
        7) 
            Install_ZshSyntaxHighlighting
            Menu
            ;;
        *)
            Menu
            ;;
    esac
    read opc
done
#EOF