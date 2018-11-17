#! /bin/bash
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








##########################################################################################################################
#################### RECOMEND RESTAURANT FUNCTION ########################################################################
##########################################################################################################################
function recomendarRestaurante {
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

  #echo
  #echo
  #echo ${arrMillorsIds[@]} #descomentar linea para mostrar ids resultado

  randomRestId=$(( RANDOM % $id ))  #nos quedamos con un elemento aleatorio del array
  echo
  #echo randChoice: $randomRestId

  #echo $randomRestId
  millor_p=$(($millor_p/10))
  echo Recomendacio de restaurant : $(cat geoplaces2.csv | grep ${arrMillorsIds[randomRestId]} | cut -d "," -f5), $(cat geoplaces2.csv | grep ${arrMillorsIds[randomRestId]} | cut -d "," -f12), $(cat geoplaces2.csv | grep ${arrMillorsIds[randomRestId]} | cut -d "," -f13),$(cat geoplaces2.csv | grep ${arrMillorsIds[randomRestId]} | cut -d "," -f14),$(cat geoplaces2.csv | grep ${arrMillorsIds[randomRestId]} | cut -d "," -f15),$(cat geoplaces2.csv | grep ${arrMillorsIds[randomRestId]} | cut -d "," -f16)
}
####################### END RECOMEND RESTAURANT FUNCTION ###############################################################################################

















##########################################################################################################################
################## CHANGE VALUES FUNCTION ########################################################################
##########################################################################################################################
function cambiarValores {
  #------------------Price----------------------------------------
  echo "Indique valores para price[M,L,H]: "
  resuesta="def"
  arrChar=()
  read resuesta
  IFS=',' read -ra arrChar <<< "$resuesta"
  tLenArrChar=${#arrChar[@]}
  #echo "respuesta: "$tLenArrChar
  correcte=1
  if [ $tLenArrChar -le 0 ]
  then
    correcte=0
  fi
  for (( el=0; el<$tLenArrChar; el++ ))
  do

    if [ ${arrChar[el]} != "M" ] && [ ${arrChar[el]} != "L" ] && [ ${arrChar[el]} != "H" ]
    then
      correcte=0
    fi
  done
  while [[ $correcte == 0 ]]
  do
    echo "Valor introducido incorrecto, vuelva a introducir valores: "
    resuesta="def"
    arrChar=()
    read resuesta
    IFS=',' read -ra arrChar <<< "$resuesta"
    tLenArrChar=${#arrChar[@]}
    echo "respuesta: "$tLenArrChar
    correcte=1
    if [ $tLenArrChar -le 0 ]
    then
      correcte=0
    fi
    for (( el=0; el<$tLenArrChar; el++ ))
    do

      if [ ${arrChar[el]} != "M" ] && [ ${arrChar[el]} != "L" ] && [ ${arrChar[el]} != "H" ]
      then
        correcte=0
      fi
    done #endfor
  done  #endWhile
  price=()
  for (( el=0; el<$tLenArrChar; el++ ))
  do
    case "${arrChar[el]}" in
      "M")

        price[el]="medium"
        ;;
      "L")
        price[el]="low"
        ;;
      "H")
        price[el]="high"
        ;;
      *)
        ;;
    esac
  done
  tLenPrice=${#price[@]}
  #------------------dress_code----------------------------------------
  echo "Indique valores para dress_code[I,C,F]: "
  resuesta="def"
  arrChar=()
  read resuesta
  IFS=',' read -ra arrChar <<< "$resuesta"
  tLenArrChar=${#arrChar[@]}
  #echo "respuesta: "$tLenArrChar
  correcte=1
  if [ $tLenArrChar -le 0 ]
  then
    correcte=0
  fi
  for (( el=0; el<$tLenArrChar; el++ ))
  do

    if [ ${arrChar[el]} != "I" ] && [ ${arrChar[el]} != "C" ] && [ ${arrChar[el]} != "F" ]
    then
      correcte=0
    fi
  done
  while [[ $correcte == 0 ]]
  do
    echo "Valor introducido incorrecto, vuelva a introducir valores: "
    resuesta="def"
    arrChar=()
    read resuesta
    IFS=',' read -ra arrChar <<< "$resuesta"
    tLenArrChar=${#arrChar[@]}
    echo "respuesta: "$tLenArrChar
    correcte=1
    if [ $tLenArrChar -le 0 ]
    then
      correcte=0
    fi
    for (( el=0; el<$tLenArrChar; el++ ))
    do

      if [ ${arrChar[el]} != "I" ] && [ ${arrChar[el]} != "C" ] && [ ${arrChar[el]} != "F" ]
      then
        correcte=0
      fi
    done #endfor
  done  #endWhile
  dress_code=()
  for (( el=0; el<$tLenArrChar; el++ ))
  do
    case "${arrChar[el]}" in
      "I")
        dress_code[el]="informal"
        ;;
      "C")
        dress_code[el]="casual"
        ;;
      "F")
        dress_code[el]="formal"
        ;;
      *)
        ;;
    esac
  done
  tLenDressCode=${#dress_code[@]}
  #------------------Alcohol----------------------------------------
  echo "Indique valores para alcohol[N,W,F]: "
  resuesta="def"
  arrChar=()
  read resuesta
  IFS=',' read -ra arrChar <<< "$resuesta"
  tLenArrChar=${#arrChar[@]}
  #echo "respuesta: "$tLenArrChar
  correcte=1
  if [ $tLenArrChar -le 0 ]
  then
    correcte=0
  fi
  for (( el=0; el<$tLenArrChar; el++ ))
  do

    if [ ${arrChar[el]} != "N" ] && [ ${arrChar[el]} != "W" ] && [ ${arrChar[el]} != "F" ]
    then
      correcte=0
    fi
  done
  while [[ $correcte == 0 ]]
  do
    echo "Valor introducido incorrecto, vuelva a introducir valores: "
    resuesta="def"
    arrChar=()
    read resuesta
    IFS=',' read -ra arrChar <<< "$resuesta"
    tLenArrChar=${#arrChar[@]}
    echo "respuesta: "$tLenArrChar
    correcte=1
    if [ $tLenArrChar -le 0 ]
    then
      correcte=0
    fi
    for (( el=0; el<$tLenArrChar; el++ ))
    do

      if [ ${arrChar[el]} != "N" ] && [ ${arrChar[el]} != "W" ] && [ ${arrChar[el]} != "F" ]
      then
        correcte=0
      fi
    done #endfor
  done  #endWhile
  tLenAlcohol=()
  for (( el=0; el<$tLenArrChar; el++ ))
  do
    case "${arrChar[el]}" in
      "N")

        alcohol[el]="No_Alcohol_Served"
        ;;
      "W")
        alcohol[el]="Wine-Beer"
        ;;
      "F")
        alcohol[el]="Full_Bar"
        ;;
      *)
        ;;
    esac
  done
  tLenAlcohol=${#alcohol[@]}
  #------------------Smoking Area----------------------------------------
  echo "Indique valores para smoking_area[O,B,P,S,N]: "
  resuesta="def"
  arrChar=()
  read resuesta
  IFS=',' read -ra arrChar <<< "$resuesta"
  tLenArrChar=${#arrChar[@]}
  #echo "respuesta: "$tLenArrChar
  correcte=1
  if [ $tLenArrChar -le 0 ]
  then
    correcte=0
  fi
  for (( el=0; el<$tLenArrChar; el++ ))
  do

    if [ ${arrChar[el]} != "0" ] && [ ${arrChar[el]} != "B" ] && [ ${arrChar[el]} != "P" ] && [ ${arrChar[el]} != "S" ] && [ ${arrChar[el]} != "N" ]
    then
      correcte=0
    fi
  done
  while [[ $correcte == 0 ]]
  do
    echo "Valor introducido incorrecto, vuelva a introducir valores: "
    resuesta="def"
    arrChar=()
    read resuesta
    IFS=',' read -ra arrChar <<< "$resuesta"
    tLenArrChar=${#arrChar[@]}
    echo "respuesta: "$tLenArrChar
    correcte=1
    if [ $tLenArrChar -le 0 ]
    then
      correcte=0
    fi
    for (( el=0; el<$tLenArrChar; el++ ))
    do

      if [ ${arrChar[el]} != "0" ] && [ ${arrChar[el]} != "B" ] && [ ${arrChar[el]} != "P" ] && [ ${arrChar[el]} != "S" ] && [ ${arrChar[el]} != "N" ]
      then
        correcte=0
      fi
    done #endfor
  done  #endWhile
  smoking_area=()
  for (( el=0; el<$tLenArrChar; el++ ))
  do
    case "${arrChar[el]}" in
      "0")
        smoking_area[el]="none"
        ;;
      "B")
        smoking_area[el]="only at bar"
        ;;
      "P")
        smoking_area[el]="permitted"
        ;;
      "S")
        smoking_area[el]="section"
        ;;
      "N")
        smoking_area[el]="not-permitted"
        ;;
      *)
        ;;
    esac
  done
  tLenSmoking=${#smoking_area[@]}
  #------------------Accesibility ----------------------------------------
  echo "Indique valores para accessibility[N,P,C]: "
  resuesta="def"
  arrChar=()
  read resuesta
  IFS=',' read -ra arrChar <<< "$resuesta"
  tLenArrChar=${#arrChar[@]}
  #echo "respuesta: "$tLenArrChar
  correcte=1
  if [ $tLenArrChar -le 0 ]
  then
    correcte=0
  fi
  for (( el=0; el<$tLenArrChar; el++ ))
  do

    if [ ${arrChar[el]} != "N" ] && [ ${arrChar[el]} != "P" ] && [ ${arrChar[el]} != "C" ]
    then
      correcte=0
    fi
  done
  while [[ $correcte == 0 ]]
  do
    echo "Valor introducido incorrecto, vuelva a introducir valores: "
    resuesta="def"
    arrChar=()
    read resuesta
    IFS=',' read -ra arrChar <<< "$resuesta"
    tLenArrChar=${#arrChar[@]}
    echo "respuesta: "$tLenArrChar
    correcte=1
    if [ $tLenArrChar -le 0 ]
    then
      correcte=0
    fi
    for (( el=0; el<$tLenArrChar; el++ ))
    do

      if [ ${arrChar[el]} != "N" ] && [ ${arrChar[el]} != "P" ] && [ ${arrChar[el]} != "C" ]
      then
        correcte=0
      fi
    done #endfor
  done  #endWhile
  accessibility=()
  for (( el=0; el<$tLenArrChar; el++ ))
  do
    case "${arrChar[el]}" in
      "N")

        accessibility[el]="no_accessibility"
        ;;
      "P")
        accessibility[el]="low"
        ;;
      "C")
        accessibility[el]="partially"
        ;;
      *)
        ;;
    esac
  done
  tLenAccesibility=${#accessibility[@]}
}
################ END CHANGE VALUES FUNCTION ###############################################################################
















##########################################################################################################################
###################### MAIN FUNCTION ############################################################################
##########################################################################################################################
while [[ $opt != 5 ]];
do
  clear
  opt=0
  ################### Prints Main menú ###########################3
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
  #---------loop 2 get a valid option-----------
  #---------------------------------------------
  while [[ $opt -le 0 || $opt -gt 5 ]];
  do
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
          recomendarRestaurante
          echo
          echo
          read -n 1 -s -r -p "Presione cualquier tecla para continuar"
          #tot=0
          #for linea in rating_final.csv
          #doz
          #  echo $linea[1]

          #done
          ;;
      "2" )
          echo "2. Recomendación detallada de restaurante"
          echo
          cambiarValores
          recomendarRestaurante
          read -n 1 -s -r -p "Presione cualquier tecla para continuar"
          ;; #end opt 2
      "3")
          echo "3. Consultar parámetros recomendación"
          echo
          echo "-------------"
          echo
          echo "Peso precio: 0"$pesPrice
          echo
          echo "Peso somking area: 0"$pesSmoking
          echo
          echo "Peso alcohol: 0"$pesAlcohol
          echo
          echo "Peso dress code: 0"$pesDress
          echo
          echo "Peso accessibility: 0"$pesAccessibility
          echo
          echo "-------------"
          echo
          echo "Precios: "${price[@]}
          echo
          echo "Smoking areas: "${smoking_area[@]}
          echo
          echo "Alcohol services: " ${alcohol[@]}
          echo
          echo "Dress codes: "${dress_code[@]}
          echo
          echo "Accesibilities: "${accessibility[@]}
          echo
          read -n 1 -s -r -p "Presione cualquier tecla para continuar"
          echo

          ;;
      "4" )
          echo "4. Ajustar parámetros recomendación"
          read -n 1 -s -r -p "Presione cualquier tecla para continuar"
          ;;
      "5")
          exit
          ;;
        *)
          echo "Error en la opcion elegida, cierre forzado"
          exit
          ;;

  esac
done
#################### END MAIN FUNCTION ################################################################################
