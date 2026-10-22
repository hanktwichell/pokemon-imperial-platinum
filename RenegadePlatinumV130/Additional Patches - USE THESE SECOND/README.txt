==============================================
Instructions
==============================================
To apply these extra patches, you first need a Renegade Platinum ROM, produced by patching a normal Platinum ROM with the appropriate "RenegadePlatinum3541.xdelta" or "RenegadePlatinum4997.xdelta" patch, dependent on your Platinum ROM.

1) Open DeltaPatcherLite.exe.
2) Select your Renegade Platinum ROM as the "original file".
3) Select a patch of your choice as the "XDelta patch".
4) Click on the cog icon that's next to "Apply patch" and click on "Checksum validation", such that it becomes UNCHECKED. Checksum validation is on by default, and will cause you to get XD3_INVALID_INPUT errors if you try to apply multiple additional patches. 
5) Click "Apply patch". This should be successful and apply the patch to the Renegade Platinum ROM.
6) To apply another patch, just change what you have selected as "XDelta patch" and hit "Apply patch" again.

Note that you should be able to apply one of these patches on top of Renegade Platinum without needing to remove the checksum validation, so you should get a choice of one of these patches even if you cannot use Delta Patcher Lite and have to use a patcher that can't remove the checksum validation.

==============================================
Available Patches
==============================================
1/4096 Shiny Rate (Shiny_Rate_1_4096.xdelta)
---
Changes the shiny rate to be 1/4096, equal to the games that are Gen 6 and onwards. By default, the shiny rate is 1/512. This does not affect the chance of the Poké Radar forcing a shiny patch.

1/8192 Shiny Rate (Shiny_Rate_1_8192.xdelta)
---
Changes the shiny rate to be 1/8192, equal to the games that are Gen 5 and before. By default, the shiny rate is 1/512. This does not affect the chance of the Poké Radar forcing a shiny patch.

Classic Version (ClassicVersion.xdelta)
---
Removes any changes to Pokémon that modify their types, stats or abilities to something that isn't in the main series as of Gen 7.

Speed Up Patch (SpeedUpPatch.xdelta)
---
Changes a few things to speed up the normally sluggish pace of Gen 4 games.
* Instant text. This means you can just mash A to get through dialogue if desired.
* Gauge animation cut. HP and EXP bars won't have the slow increase/decrease they normally do. (Note: This doesn't affect small HP bars so may not be noticeable early.)
* FPS cap removed. Ordinarily locked to 30, the game will now run as fast as it can up to a maximum of 60. Most noticeable in battles. You can see an example of how this works here: https://www.youtube.com/watch?v=P7P6tjsuNxY



