#! /bin/bash
echo "Menú Principal:"
echo "---------------"
echo
echo "1. Recomendación rápida de restaurante"
echo
echo "2. Recomendación detallada de restaurante"
echo
echo "3. Consultar parámetros recomendación"
echo
echo "4. Ajustar parámetros recomendación"
echo
echo "5. Salir"
echo
echo "---------------------------------------------"
opt=0
while [[ $opt -le 0 || $opt -gt 5 ]]; do
  echo
  echo "Introduzca una opción (1/2/3/4/5):"
  read opt
done

'clear'

case "$opt" in
    "1")
        echo "1. Recomendación rápida de restaurante"
        echo
        arr1=($(cat rating_final.csv | tail -n +2 | cut -d "," -f3))
        arr2=($(cat rating_final.csv | tail -n +2 | cut -d "," -f4))
        arr3=($(cat rating_final.csv | tail -n +2 | cut -d "," -f5))
        tLen=${#arr1[@]}
        #echo $tLen
        for (( i=0; i<=$tLen; i++ ))
        do
          tmp=$((${arr1[i]}+${arr2[i]}+${arr3[i]}))
          tmp=$(($tmp/3))
          echo $tmp
          echo
        done
        #tot=0
        #for linea in rating_final.csv
        #doz
        #  echo $linea[1]

        #done
        ;;
    "2" )
        echo "2. Recomendación detallada de restaurante"
        ;;
    "3")
        echo "3. Consultar parámetros recomendación"
        ;;
    "4" )
        echo "4. Ajustar parámetros recomendación"
        ;;
    "5")
        exit
        ;;
      *)
        exit
        ;;

esac
