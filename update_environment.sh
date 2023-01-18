#!/bin/bash


Import_Config ()
{
  cp ~/.hyper.js ./terminal/
  cp ~/.p10k.zsh ./terminal/  
  cp ~/.zshrc ./terminal/

  echo "${GR}Configuración importada exitosamente ✅\n"
}
Export_Config ()
{
  cp -r ./terminal/ ~/
  source ~/.zshrc
  echo "${GR}Configuración exportada exitosamente ✅\n"
}

Menu ()
{
  echo ""
	echo "  1) Importar configuración 🌈"
	echo "  2) Exportar configuración 🔴"
	echo "  3) Salir 🪐"
	echo ""
	echo "Indica una opcion:  "
}
opc=0
until [ $opc -eq 3 ]
do
    case $opc in
        1)  
            Import_Config
            Menu
            ;;
        2)  
            Export_Config
            Menu
            ;;
        *)
            Menu
            ;;
    esac
    read opc
done
#EOF