# Ghostgame

Planned Features:

object doors, trapdoors, switches, buttons and pressure_plates:
- have a color code, doors open, if signals with the same color are active
1) buttons:
- attached to walls 
- can be activated by humans
- emit signals for a short period of time
2) switches:
- attached to walls
- can be activated and deactivated by humans
- emits signals if activated
3) pressure_plates:
- attached to the ground
- can be activated by movables and humans by walking on it
- emit signals as long as there is an object on it
4) doors and trapdoors:
- doors are three blocks tall and trapdoors are three blocks wide
- if a signal emitter with the same color is active, they will open
- can be inverted, that you have to give a signal to close them
- there should be an iron version of this doors, where the ghost cannot pass through them
5) later, there should be other doors, which only open, if the player collected a specific amount of items
6) later, there should be special switches, which can be pressed by the ghost and change properties of the whole world (e.g. activate/deactivate lights in the house)

object human:
- dying: the player falls over with an animation and sound; the screen fades out and the level resets
- some humans have other abilities, which are shown on the sprite; e.g. cannot be possessed
- will be scared of some actions of the player and from movables and run away
- maybe they have a value of how likely they are to be afraid
- this value can be raised if it's dark, etc. and through events
- adults could have a higher resistance to scary things
- can activate switches and buttons
- humans can collect pumpkins, if every human got a pumpkin, the map is cleared and will be brighter
- ladders, possessed humans can climb on them

keyhint interface:
- show controller keys while using a controller
- while possessing an object, show all available controlls

object behaviour:
- movables should apply their movement to other movables, who are stacked above them
- movables should be able to push other movables with ca. half the normal movement speed

light system:
- light shouldn't add infinite on objects

sound behaviour:
- the direction from which the sound comes should be relative to the ghost instead of the middle of the screen

others:
- pumpkin points
- save system for pumpkin points, cleared levels and current position of the player
- objects like a clock, a thermometer or paintings, which can be manipulated; this could have effects on the real world
- snow, which can smelt, if it's hot
- water, which can be turned to ice and vice versa
- objects, who can only be moved on rails or who automatically move objects on them 
- locks and keys for doors
- hide function for ghosts
- pushing blocks
- static generators, etc. who have changes to the whole house, e.g. turning the electricity on
- different objects with different moving behaviour 
- boss level
- reset system, only current room, save some progress

Unsolved Bugs:

scene loading:
- unpossess processes can lead to unloading of the whole scene
- error messages


Controlls:
1) move_left, move_right, move_up, move_down: 
- moves the character in the direction
- used in Movables and in Human only for horizontal movement(move_right, move_left)
- used in Ghost for all directions
2) possess:
- used in Ghost to possess or unpossess an Possessable
3) action:
- currently unused
- will be used in Human to interact with objects like buttons and switches
4) reload:
- currently reloads the whole game
- will reload the current room and sets the ghost to the position, where he entered the room
5) switch_fullscreen:
- switch between fullscreen mode and windowed mode
6) switch_possessable:
- used in Ghost to switch the selected Possessable
- while possessing, can be used to switch to another possessable in range
7) jump:
- used in Human to let him jump

Collision Layer:
1) solid_blocks: tilemap blocks, which are solid for all objects including the ghost
2) blocks: tilemap blocks, which are solid for nearly all objects; ghost excluded
3) objects: mainly possessables, which do not collide with other objects
4) solid_objects: mainly possessables, which have to collide with other possessables

Z Index:
-1	background_color
0	background_texture
1	clock
2	emitter
3	receiver
4	iron_crate
5	crate; barrel
6	lamp
7	human; pumpkin
8	ghost
9	-
10	msg_possess
