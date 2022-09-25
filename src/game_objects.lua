-- table for all objects with info for each parameter
GAME_OBJECT_DEFS = {
    ['switch'] = {
        type = 'switch',
        texture = 'tiles',
        frame = 35,
        width = 16,
        height = 16,
        solid = false,
        defaultState = 'unpressed',
        states = {
            ['unpressed'] = {
                frame = 35 
            },
            ['pressed'] = {
                frame = 36 
            }
        }
    },
    ['pot'] = {
        type = 'pot',
        texture = 'tiles',
        width = 16,
        height = 16,
        frame = POT_IDS[math.random(#POT_IDS)],
        defaultState = 'normal',
        states = {
            ['normal'] = {frame = 72},
            ['broken'] = {frame = 52}
        },
        solid = true
    },
    ['heart'] = {
        texture = 'hearts',
        frame = 5,
        width = 16,
        height = 16,
        consumable = true
    }
}
