-- Global variables

world_size = 50

-- Interface

Config:create_slider('Num_mobiles', 0, 500, 1, 100)

-- pos_to_torus relocate the agents as they are living in a torus
local function pos_to_torus(agent, size_x, size_y)
    local x,y = agent:xcor(),agent:ycor()

    if x > size_x then
        agent.pos[1] = agent.pos[1] - size_x
    elseif x < 0 then
        agent.pos[1] = agent.pos[1] + size_x
    end

    if y > size_y then
        agent.pos[2] = agent.pos[2] - size_y
    elseif y < 0 then
        agent.pos[2] = agent.pos[2] + size_y
    end
end

local function random_float(a,b)
    return a + (b-a) * math.random();
end

local function merge(ag,lead)
    ag.leader = lead
    ag.heading = lead.heading
    ag.color = {0,1,0,1}

    local e0 = ag:link_neighbors(Links)
--    print("e0 COUNT", e0.count)
    local extend = e0:with(
        function(other)
            return other.leader ~= lead
        end)

    if extend.count > 0 then
        for _,ag2 in ordered(extend) do
            merge(ag2,lead)
        end
    end
end

SETUP = function()
    -- Frame collection
    Checkpoints = FamilyMobil()
    Checkpoints:add({ ['pos'] = {0, world_size} })
    Checkpoints:add({ ['pos'] = {0,0} })
    Checkpoints:add({ ['pos'] = { world_size,0} })
    Checkpoints:add({ ['pos'] = { world_size, world_size} })

    for _, ch in ordered(Checkpoints) do
        ch.shape = 'circle'
        ch.scale = 2
        ch.color = {1,0,0,1}
        ch.label = ch:xcor() .. ',' .. ch:ycor()
    end

    -- Create a new collection
    Mobiles = FamilyMobil()
    Links   = FamilyRelational()

    -- Populate the collection with Agents.
    Mobiles:create_n( Config.Num_mobiles, function()
        return {
            ['pos']          = {math.random(0,world_size),math.random(0,world_size)}
            ,['heading']     = math.random(__2pi)
            ,['shape']       = "circle"
            ,['scale']       = 1
            ,['color']       = {0,0,1,1}
            ,['turn_amount'] = random_float(-0.2,0.2)
        }
    end)

    for _ , ag in ordered(Mobiles) do
        ag.leader = ag
    end

end

-- This function is executed until the stop condition is reached, 
-- or the button go/stop is stop
RUN = function()

    local alone = Mobiles:with(function(ag)
        return ag.leader == ag
    end)
    for _,ag in ordered(alone) do
        ag.turn_amount = random_float(-0.2,0.2)
    end

    for _,ag in ordered(Mobiles) do
        ag:rt(ag.leader.turn_amount)
        ag:fd(0.1)
        pos_to_torus(ag,world_size,world_size)
    end

    for _,ag in ordered(Mobiles) do
        local candidates = Mobiles:with(function(other)
            return (ag:dist_euc_to(other) < 1) and (ag.leader ~= other.leader)
        end)
        if candidates.count > 0 then
            for _,ag2 in ordered(candidates) do
                Links:add({
                    ['source']  = ag
                    ,['target'] = ag2
                    ,['color']  = {0,0,1,0}
                    ,['visible'] = false
                    })
                merge(ag2,ag.leader)
            end
        end
    end
end