# Mastermind Game

Mastermind is a code-breaking game where the player needs to guess the secret code within a limited number of turns. This implementation includes both a player mode and a computer mode.

## Rules

**Guess Mode**

- The secret code is 4 digits long by default.
- Each digit represents a color chosen from a pool of 8 options, which are [red blue green yellow orange white pink violet].
- There are no duplicate colors in the secret code.
- After each guess, the game provides feedback on the number of hits and balls.
- A "hit" means the color and placement are correct, while a "ball" means the color is correct but the placement is wrong.
- The player must guess the secret code within a set number of turns (12 by default).
- After each game, player can choose a different digits and turns to be used in the next round.

**Computer Mode**

- Player chooses 4 different digits long.
- There are no duplicate colors in the secret code.
- Computer has a set number of turns to guess that code.
- After each game, player can choose number of turns for computer to use.

## Usage

To play the game, run the provided script (ruby mm.rb). You can choose between creating the secret code or guessing it.

## Implementation Details

- The game starts by randomly selecting a secret code.
- In player mode, the player makes guesses and receives feedback.
- In computer mode, the computer attempts to guess the secret code using various strategies.
- The game board displays the current state of the guesses.
- Players can play multiple games with different settings.
