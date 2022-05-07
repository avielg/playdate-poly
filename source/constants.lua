--- Ground ---
--------------

-- The height of space above ground shown when starting the game
kAboveGroundSpace = 60

-- The Y position at which the player appears walking "on ground"
kAboveGroundPlayerPositionY = 51

-- The X position the player begins
kPlayerStartX = 100

--- Scorpion ---
----------------

-- disable the scorpion, for debugging non-scorpion related stuff without dread...
kScorpionEnabled = true

-- scorpion appears (and begins moving) only after player moved this many lines
kNumOfLinesWhenScorpionAppears = 60

-- When the scorpion distance to player is this many lines - we lost
kLinesWhenScorpionHitPlayer = 7

--- Food ---
------------

-- max food pieces poly can eat before needing to poop
kMaxFoodInBelly = 5

--- Layers ---
--------------

zIndexLine = 1
zIndexPlayer = 2
zIndexScorpion = 2
zIndexPoop = 3
zIndexHUD = 999
zIndexAlert = 32767  -- alert goes over everything...
