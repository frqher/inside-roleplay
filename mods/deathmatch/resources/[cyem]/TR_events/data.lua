eventData = {
    events = {
        ["MD"] = {
            name = "Monster Derby",
            playerCount = 20,
            -- minPlayers = 8,
            minPlayers = 2,
            type = "monsterDerby",
            tribune = Vector3(4290.0805664063, -1600.9825439453, 250.40043640137),
        },
        ["CD"] = {
            name = "Crossed Derby",
            playerCount = 30,
            -- minPlayers = 8,
            minPlayers = 2,
            type = "crossedDerby",
            tribune = Vector3(6158.6762695313, -537.67712402344, 67.897262573242),
        },
        ["PB"] = {
            name = "Pirate Boarding",
            playerCount = 20,
            minPlayers = 2,
            type = "pirate",
            tribune = Vector3(-2351.62109375, 3135.6284179688, 10.399440765381),
        },
        ["OX"] = {
            name = "Prawda / Fałsz",
            playerCount = 50,
            minPlayers = 2,
            type = "ox",
            tribune = Vector3(-2351.62109375, 3135.6284179688, 10.399440765381),
        },
        ["FO"] = {
            name = "Fallout Boards",
            playerCount = 30,
            minPlayers = 2,
            type = "fallout",
            tribune = Vector3(-2351.62109375, 3135.6284179688, 10.399440765381),
        },
        -- {
        --     name = "Sky Jumps",
        --     playerCount = 20,
        --     minPlayers = 6,
        --     type = "jumps",
        -- },
        -- {
        --     name = "Reach the Sky",
        --     playerCount = 20,
        --     minPlayers = 6,
        --     type = "plane",
        -- },
    },

    isStarted = false,

    players = {},
    playerCount = 0,
    startTime = 61,
    -- startTime = 11,
    -- eventDelay = 180,
    eventDelay = 1800,
}

function isEventExists(type)
    return eventData.events[type] or false
end