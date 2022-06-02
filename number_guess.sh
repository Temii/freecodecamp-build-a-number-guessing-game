#! /bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"
SUCCESSFUL_INSERT_RESULT="INSERT 0 1"

echo "Enter your username:"

read USERNAME

USER_ID=$($PSQL "SELECT user_id FROM users WHERE username = '$USERNAME'")

if [[ -z $USER_ID ]]
then
  INSERT_USER_RESULT=$($PSQL "INSERT INTO users(username) VALUES('$USERNAME')")
  USER_ID=$($PSQL "SELECT user_id FROM users WHERE username = '$USERNAME'")

  if [[ $INSERT_USER_RESULT == $SUCCESSFUL_INSERT_RESULT ]]
  then
    echo "Welcome, $USERNAME! It looks like this is your first time here."
  else
    echo "Error saving new user!"
  fi
else
  USER_GAMES=$($PSQL "SELECT COUNT(game_id), MIN(guesses_number) FROM games WHERE user_id = $USER_ID")

  IFS="|" read GAMES_PLAYED BEST_SCORE <<< "$USER_GAMES"

  echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_SCORE guesses."
fi

GAME_NUMBER=$(( $RANDOM % 1000 + 1 ))
TRIES=1
echo "Guess the secret number between 1 and 1000:"

until [[ $GUESSED_NUMBER == $GAME_NUMBER ]]
do
  read GUESSED_NUMBER

  if [[ $GUESSED_NUMBER =~ [0-9]+ ]]
  then
    if [[ $GUESSED_NUMBER == $GAME_NUMBER ]]
    then
      INSERT_GAME_RESULT=$($PSQL "INSERT INTO games(user_id, guesses_number) VALUES($USER_ID, $TRIES)")

      if [[ $INSERT_GAME_RESULT == $SUCCESSFUL_INSERT_RESULT ]]
      then
        echo "You guessed it in $TRIES tries. The secret number was $GAME_NUMBER. Nice job!"
      else
        echo "Error saving game!"
      fi
    else
      if [[ $GUESSED_NUMBER < $GAME_NUMBER ]]
      then
        COMPARISON=higher
      else
        COMPARISON=lower
      fi

      TRIES=$(($TRIES+1))
      echo "It's $COMPARISON than that, guess again:"
    fi
  else
    echo "That is not an integer, guess again:"
  fi
done
