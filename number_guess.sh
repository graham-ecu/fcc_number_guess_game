#! /bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

# generate random number
RANDOM_NUMBER=$((RANDOM % 1000 + 1))
echo $RANDOM_NUMBER

# prompt user for username
echo -e "\nEnter your username:"
read USERNAME

# check if user exists in database
USER_EXISTS=$($PSQL "SELECT username FROM games WHERE username='$USERNAME'")

# if user exists
if [[ ! -z $USER_EXISTS ]]
then
  # get info on user
  GAMES_PLAYED=$($PSQL "SELECT games_played FROM games WHERE username='$USERNAME'")
  FEWEST_GUESSES=$($PSQL "SELECT fewest_guesses FROM games WHERE username='$USERNAME'")
  # print welcome message
  echo -e "\nWelcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $FEWEST_GUESSES guesses."
else
  # if new user
  GAMES_PLAYED=0
  FEWEST_GUESSES="N/A"
  echo -e "\nWelcome, $USERNAME! It looks like this is your first time here."
fi

# start game
echo -e "\nGuess the secret number between 1 and 1000:"
read GUESS
# initiate guesses
NUM_GUESSES=1
# start loop
while [[ $GUESS -ne $RANDOM_NUMBER ]]
do
  # check if input is an integer
  if [[ ! $GUESS =~ ^-?[0-9]+$ ]]
  then
    echo -e "\nThat is not an integer, guess again:"
  else
    # increment number of guesses
    NUM_GUESSES=$(( NUM_GUESSES + 1 ))
    # check if guess is too high
    if [[ $GUESS -lt $RANDOM_NUMBER ]]
    then
      echo -e "It's higher than that, guess again:"
    elif [[ $GUESS -gt $RANDOM_NUMBER ]]
    then
      echo -e "It's lower than that, guess again:"
    fi
  fi
  # prompt for new guess
  read GUESS
done

# redefine values
GAMES_PLAYED=$(( GAMES_PLAYED + 1 ))
if [[ $FEWEST_GUESSES == "N/A" || $FEWEST_GUESSES -gt $NUM_GUESSES ]]
then
  FEWEST_GUESSES=$NUM_GUESSES
fi
# if first game
if [[ $GAMES_PLAYED -eq 1 ]]
then
  # add new row
  INSERT_ROW=$($PSQL "INSERT INTO games (username, games_played, fewest_guesses) VALUES ('$USERNAME', $GAMES_PLAYED, $FEWEST_GUESSES)")
else
  # Update existing row
  UPDATE_ROW=$($PSQL "UPDATE games SET games_played=$GAMES_PLAYED, fewest_guesses=$FEWEST_GUESSES WHERE username='$USERNAME'")
fi
# print success message
echo -e "\nYou guessed it in $NUM_GUESSES tries. The secret number was $RANDOM_NUMBER. Nice job!"
