# Ghostgame

Planned Features:

new object: Human
- can be possessed
- can run and jump (jumpwidth: ca. 1.5 block; jumpheight: ca. 1.5 blocks)
- will die from falldamage after slightly less than 3 blocks (48 pixel)
- can have different textures and abilities, some cannot be possessed and walk on their own
- can be scared, can run away

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
- doors and hatchs; three variants of both: 1) possessable, unsolid, the player is able to open them
											2) unpossessable, unsolid, emitting signals via switches, etc. are required to open them
											3) unpossessable, solid, only having the required progress points or a key will grant you access
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
- watering plants, etc. to grow new objects
- pushing blocks
- static generators, etc. who have changes to the whole house, e.g. turning the electricity on
- different objects with different moving behaviour 
- boss level

Unsolved Bugs:

scene loading:
- unpossess processes can lead to unloading of the whole scene
- if an object is possessed during a scene transition, the transition failes; the ghost should left the object before the transition
- using the tab scene reset spawns the player at the wrong position; it should be saved where the player entered a scene
- if the player switches between scenes at a fast pace, the loading and unloading is screwed up; a short delay doesn't seem to fix this problem


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
7	pumpkin
8	ghost
9	-
10	msg_possess
