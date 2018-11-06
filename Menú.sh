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
#---------------------------------------------
#-------------DEFAULT VALUES------------------
#---------------------------------------------
opt=0 #Option 2 choose in the main menu
alcohol=("Wine-Beer")
tLenAlcohol=${#alcohol[@]}
price=("medium")
tLenPrice=${#price[@]}
dress_code=("casual" "informal")
tLenDressCode=${#dress_code[@]}
smoking_area=("not-permitted" "none")
tLenSmoking=${#smoking_area[@]}
accessibility=("completely" "partially")
tLenAccesibility=${#accessibility[@]}
pesAlcohol=$(echo "scale=2; 0.2" | bc)  #bc 2 use decimals
pesPrice=$(echo "scale=2; 0.4" | bc)
pesDress=$(echo "scale=2; 0.1" | bc)
pesSmoking=$(echo "scale=2; 0.1" | bc)
pesAccessibility=$(echo "scale=2; 0.2" | bc)
#---------------------------------------------
#---------loop 2 get a valid option-----------
#---------------------------------------------
while [[ $opt -le 0 || $opt -gt 5 ]]; do
  echo
  echo "Introduzca una opción (1/2/3/4/5):"
  read opt
done

'clear'

case "$opt" in

    #-----------------------------------------------
    #---------------Option 1-----------------------
    #-----------------------------------------------
    "1")
        echo "1. Recomendación rápida de restaurante"
        echo
        arrId=($(cat geoplaces2.csv | tail -n +2 | cut -d "," -f1)) #get an array with all the unique ids
        tLen=${#arrId[@]} #get the length of the array
        #-------------------------------------------
        #----------testing variables----------------
        #-------------------------------------------
        Millor=0
        numRest=0
        totalNoVino=0
        tp=0
        #-------------------------------------------
        #----------------init data------------------
        #-------------------------------------------
        puntuacio=()  #array with all the scores of the variables with rating supperior to 1
        millor_p=0  #best score

        #----------------------------------------------------------------------------------------------------------------------
        #------------------------ Calculamos todas las puntuaciones de los restaurantes ---------------------------------------
        #----------------------------------------------------------------------------------------------------------------------
        ########################################################################################################################
        for (( i=0; i<$tLen; i++ )) #iteramos sobre todo el array de ids unicos
        do
          arrRating=($(cat rating_final.csv | grep ${arrId[i]}))  #nos quedamos con todas las valoraciones del restaurante acual
          arr1=($(cat rating_final.csv | grep ${arrId[i]} | tail -n +2 | cut -d "," -f3)) #cogemos la primera columna de datos
          arr2=($(cat rating_final.csv | grep ${arrId[i]} | tail -n +2 | cut -d "," -f4)) #idem 2a
          arr3=($(cat rating_final.csv | grep ${arrId[i]} | tail -n +2 | cut -d "," -f5)) #idem 3a
          tLen1=${#arr1[@]} #miramos cuantas valoraciones hay
          tmp=$(echo "scale=2; 0.0" | bc) #inicializamos el rating a calcular a 0
          for (( j=0; j<$tLen1; j++ ))  #iteramos sobre cada valoración
          do
            tmp=$(($tmp+${arr1[j]}))  #sumamos las 3 columnas de la valoración
            tmp=$(($tmp+${arr2[j]}))
            tmp=$(($tmp+${arr3[j]}))
          done
          tLen1=$(($tLen1*3)) #hacemos la media de la puntuacion del restaurante actual
          tmp=$(($tmp/$tLen1))
          if [ $tmp -ge 1 ] #miramos si el rating es mayor a 1
          then
            #echo Id_Rest: ${arrId[i]}

            puntAct=0 #inicializamos la puntuacion segun los parametros a 0
            aux=($(cat geoplaces2.csv | grep ${arrId[i]} | cut -d  "," -f12)) #cogemos el dato a comprobar
            for (( a=0; a<$tLenAlcohol; a++ ))
            do
              if [[ $aux =~ .*${alcohol[a]}.* ]]  #miramos si es igual al parametro
              then
                puntAct=$((puntAct+2))  #sumamos el peso correspondiente
                break
              fi
            done
            aux=($(cat geoplaces2.csv | grep ${arrId[i]} | cut -d  "," -f13))
            for (( a=0; a<$tLenSmoking; a++ ))
            do
              if [[ $aux =~ .*${smoking_area[a]}.* ]]
              then
                puntAct=$((puntAct+1))
                break
              fi
            done
            aux=($(cat geoplaces2.csv | grep ${arrId[i]} | cut -d  "," -f14))
            for (( a=0; a<$tLenDressCode; a++ ))
            do
              if [[ $aux =~ .*${dress_code[a]}.* ]]
              then
                puntAct=$((puntAct+1))
                break
              fi
            done
            aux=($(cat geoplaces2.csv | grep ${arrId[i]} | cut -d  "," -f15))
            for (( a=0; a<$tLenAccesibility; a++ ))
            do
              if [[ $aux =~ .*${accessibility[a]}.* ]]
              then
                puntAct=$((puntAct+2))
                break
              fi
            done
            aux=($(cat geoplaces2.csv | grep ${arrId[i]} | cut -d  "," -f16))
            for (( a=0; a<$tLenPrice; a++ ))
            do
              if [[ $aux =~ .*${price[a]}.* ]]
              then
                puntAct=$((puntAct+4))
                break
              fi
            done
            puntuacio[i]=$puntAct #añadimos la puntuación actual al array de puntuaciones
            #echo Puntuacio_Rest: ${puntuacio[i]}
            if [[ ${puntuacio[i]} -gt  $millor_p ]]
            then
            millor_p=${puntuacio[i]}
            #Millor=${arrId[i]}
            fi
          else  #si el rating es menor a 1 asignamos arbitrariamente -1 a
                #la puntuacion para distinguir el restaurante de los que superan el rating (solo para testing)
            puntuacio[i]=-1
          fi

          numRest=$((1 + $numRest)) #sumamos 1 al numero de Restaurantes añadidos al array de puntuaciones

        done  #final del bucle que itera sobre todos los ids
        ###################################################################################################################

        #-----------testing Prints----------
        #echo $Millor, $millor_p
        #echo Numero De Restaurantes:$numRest
        #echo Total Sin Vino:$totalNoVino
        #echo TotalRest: $tLen
        tLenPunt=${#puntuacio[@]}
        #echo LenPuntuacio: $tLenPunt

        #-------------------------------------------------
        #------------Buscar Mejores Puntuaciones----------
        #-------------------------------------------------

        arrMillorsIds=()  #creamos un array donde guardar las ids de los restaurantes con mayor puntuación
        id=0  #creamos un iterador que ir incrementando cada vez que insertemos
        for (( i=0; i<$tLenPunt; i++ )) #iteramos sobre todas las ids
        do
          if [[ ${puntuacio[i]} -eq $millor_p ]]  #si su puntuacion es igual a la mayor
          then
            arrMillorsIds[id]=${arrId[i]}         #insertamos el valor al array
            id=$(($id+1))
          fi
        done

        echo
        #echo "Viva Jhon Bon Jovi"
        echo
        echo ${arrMillorsIds[@]}

        randomRestId=$(( RANDOM % $id ))  #nos quedamos con un elemento aleatorio del array
        echo
        #echo randChoice: $randomRestId

        #echo $randomRestId
        millor_p=$(($millor_p/10))
        echo Recomendacio de restaurant : $(cat geoplaces2.csv | grep ${arrMillorsIds[randomRestId]} | cut -d "," -f5), $(cat geoplaces2.csv | grep ${arrMillorsIds[randomRestId]} | cut -d "," -f12), $(cat geoplaces2.csv | grep ${arrMillorsIds[randomRestId]} | cut -d "," -f13),$(cat geoplaces2.csv | grep ${arrMillorsIds[randomRestId]} | cut -d "," -f14),$(cat geoplaces2.csv | grep ${arrMillorsIds[randomRestId]} | cut -d "," -f15),$(cat geoplaces2.csv | grep ${arrMillorsIds[randomRestId]} | cut -d "," -f16)
        echo
        echo
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
