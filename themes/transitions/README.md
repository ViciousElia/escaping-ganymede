# Transitions
Due to the nature of point-and-click adventure games, room transitions are necessary
for various changes of scenery.

Outlined here are the details for implementation. This is incomplete currently because
transitions require a functional roomInterface in order to code.
## Overview
Transitions should be created, at minimum, for the following actions
- Move 
	- Cardinal directions
	- Secondary directions
	- Up/Down (stairs, elevator, et c)
- Interact/Use/Take
	- Any interaction that substantially changes the room (need not include door states)
	- Any interaction that causes the player to change locations

Further transitions may be created, and should assume the following flow:
1. Action request occurs
	1. Room alerts RoomInterface of action request
	2. RoomInterface checks global flags against required flags
	3. RoomInterface confirms action
	4. RoomInterface signals ScreenInterface to ignore inputs
2. RoomInterface gets next Room from current Room
3. RoomInterface calls TransitionInterface
	1. TransitionInterface uses data from RoomInterface to select correct Transition
	2. TransitionInterface plays first animation from Transition
	3. TransitionInterface signals RoomInterface to swap to next Room
	4. TransitionInterface plays second animation from Transition
	5. TransitionInterface queues itself for deletion
4. RoomInterface queues current Room for deletion
5. RoomInterface signals ScreenInterface to resume inputs
## Structure
**NOTE** The extension is subject to change once we establish the best way to manage
the animations. The use of `tscn` is simply because I *expect* scenes will be the
easiest way to handle the structure.

Transitions for Move actions should follow the filename structure `move_[direction].tscn`.
For Interact actions, the filename structure should be `interact_[event].tscn` and should
be referenced as such from the Room that uses the transition. For any special transitions,
the filename structure should be `special_[event].tscn`.

Examples:
- Move North - `move_n.tscn`
- Move Northwest - `move_nw.tscn`
- Take Statue - `interact_statue.tscn`
- Speak Telemaze - `special_telemaze.tscn`

**TODO** - build RoomInterface and first Transition to establish ideal structures.
## Usage
tbd
## Alternatives