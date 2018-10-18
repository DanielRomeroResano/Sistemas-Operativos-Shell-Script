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
        arrId=($(cat geoplaces2.csv | tail -n +2 | cut -d "," -f1))
        tLen=${#arrId[@]}
        numRest=0
        totalNoVino=0
        for (( i=0; i<$tLen; i++ ))
        do
          arrRating=($(cat rating_final.csv | grep ${arrId[i]}))
          arr1=($(cat rating_final.csv | grep ${arrId[i]} | tail -n +2 | cut -d "," -f3))
          arr2=($(cat rating_final.csv | grep ${arrId[i]} | tail -n +2 | cut -d "," -f4))
          arr3=($(cat rating_final.csv | grep ${arrId[i]} | tail -n +2 | cut -d "," -f5))
          tLen1=${#arr1[@]}
          tmp=0,0
          for (( j=0; j<$tLen1; j++ ))
          do
            tmp=$(($tmp+${arr1[j]}))
            tmp=$(($tmp+${arr2[j]}))
            tmp=$(($tmp+${arr3[j]}))
          done
          tLen1=$(($tLen1*3))
          tmp=$(($tmp/$tLen1))
          if [ $tmp -ge 1 ]
          then
            echo $tmp:${arrId[i]}
            echo
            puntAct=0
            aux=($(cat geoplaces2.csv | grep ${arrId[i]} | cut -d  "," -f12))
            if [[ $aux =~ .*'Wine-Beer'.* ]]
            then
              totalNoVino=$(($totalNoVino+1))
            fi
            
          fi

          numRest=$((1+$numRest))
        done
        echo Numero De Restaurantes:$numRest
        echo Total Sin Vino:$totalNoVino
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
