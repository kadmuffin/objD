#######
# Compiled from test.mcscript
# to mcscript/raycast1.mcfunction
#
# Generated by Minecraft Script for 1.13
######
say hey
scoreboard players add raycast1 mcscript_raycast 1
execute positioned ^ ^ ^1 unless block ~ ~ ~ air run tag @s add mcscriptStop
execute positioned ^ ^ ^1 if entity @s[tag=!mcscriptStop] if block ~ ~ ~ air if score raycast1 mcscript_raycast matches ..10 run function noname:mcscript/raycast1
execute if score raycast1 mcscript_raycast matches ..10 if entity @s[tag=mcscriptStop] positioned ^ ^ ^1 run say hi
tag @s[tag=mcscriptStop] remove mcscriptStop