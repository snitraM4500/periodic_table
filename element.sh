#!/bin/bash

# Set up the PSQL command
PSQL="psql --username=freecodecamp --dbname=periodic_table --tuples-only -c"

# Function to display element information
display_element_info() {
    local element=$1
    
    if [[ ! $element =~ ^[0-9]+$ ]]
    then
      # Query the database for element information
      ELEMENT_INFO=$($PSQL "SELECT e.atomic_number, e.name, e.symbol, t.type, p.atomic_mass, p.melting_point_celsius, p.boiling_point_celsius 
      FROM properties p
      INNER JOIN elements e USING(atomic_number)
      INNER JOIN types t USING(type_id)
      WHERE e.symbol = '$element' OR e.name='$element'")
    else
     # Query the database for element information
      ELEMENT_INFO=$($PSQL "SELECT e.atomic_number, e.name, e.symbol, t.type, p.atomic_mass, p.melting_point_celsius, p.boiling_point_celsius 
      FROM properties p
      INNER JOIN elements e USING(atomic_number)
      INNER JOIN types t USING(type_id)
      WHERE e.atomic_number = $element")
    fi

    # Check if element was found
    if [[ -z $ELEMENT_INFO ]]; then
        EXITNOTFOUND
        return
    fi

    echo "$ELEMENT_INFO" | while read ATOMIC_NUMBER BAR NAME BAR SYMBOL BAR TYPE BAR ATOMIC_MASS BAR MELTING_POINT BAR BOILING_POINT
    do
      echo "The element with atomic number $ATOMIC_NUMBER is $(echo $NAME | sed -r 's/^ *| *$//g') ($(echo $SYMBOL | sed -r 's/^ *| *$//g')). It's a $TYPE, with a mass of $ATOMIC_MASS amu. $(echo $NAME | sed -r 's/^ *| *$//g') has a melting point of $MELTING_POINT celsius and a boiling point of $BOILING_POINT celsius."
    done
}

EXITNOTPROVIDED(){
  echo "Please provide an element as an argument."
}

EXITNOTFOUND(){
  echo "I could not find that element in the database."
}

# Check if an argument is provided
if [[ $# -eq 0 ]]; then
    EXITNOTPROVIDED
else
    # Get the first argument
    element=$1

    # Call the display_element_info function
    display_element_info $element
fi
