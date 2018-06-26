# Ghostgame

Planned Features:

object human:
- dying: the player falls over with an animation and sound; the screen fades out and the level resets
- some humans have other abilities, which are shown on the sprite; e.g. cannot be possessed
- will be scared of some actions of the player and from movables and run away
- maybe they have a value of how likely they are to be afraid
- this value can be raised if it's dark, etc. and through events
- adults could have a higher resistance to scary things

keyhint interface:
- design rework
- extra controller keys while using a controller
- while possessing an object, show all available controlls

object behaviour:
- movables should apply their movement to other movables, who are stacked above them
- movables should be able to push other movables with ca. half the normal movement speed

light system:
- light shouldn't add infinite on objects

node structure:
- organizing nodes in groups

sound behaviour:
- the direction from which the sound comes should be relative to the ghost instead of the middle of the screen

others:
- doors and hatchs; two variants of both: 1) unpossessable, unsolid, emitting signals via switches, etc. are required to open them
											2) unpossessable, solid, only having the required progress points or a key will grant you access
- levers, buttons and pressure_plates, which can emit signals to objects like connected doors
- marking system, which switch is connected to which door, etc.
- humans can collect pumpkins, if every human got a pumpkin, the map is cleared and will be brighter
- pumpkin points should be saved
- ladders, possessed humans can climb up on them
- objects like a clock, a thermometer or paintings, which can be manipulated; this could have effects on the real world around them
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


Collision System:

collision layer:
- 1) solid_blocks: tilemap blocks, which are solid for all objects including the ghost
- 2) blocks: tilemap blocks, which are solid for nearly all objects; ghost excluded
- 3) objects: mainly possessables, which do not collide with other objects
- 4) solid_objects: mainly possessables, which have to collide with other possessables


Z Index:

-1	background_color
0	background_texture
1	clock
2	-
3	-
4	iron_crate
5	crate; barrel
6	lamp
7	human; pumpkin
8	ghost
9	-
10	msg_possess
