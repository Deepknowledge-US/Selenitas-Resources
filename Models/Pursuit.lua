-- Interface 

Config:create_slider('Num_pursuers', 0, 100, 1, 100)

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

SETUP = function()
    -- Test collection
    Checkpoints = FamilyMobil()
    Checkpoints:add({ ['pos'] = {0, 100} })
    Checkpoints:add({ ['pos'] = {0,0} })
    Checkpoints:add({ ['pos'] = { 100,0} })
    Checkpoints:add({ ['pos'] = { 100, 100} })

    for _, ch in ordered(Checkpoints) do
        ch.shape = 'circle'
        ch.scale = 5
        ch.color = {1,0,0,1}
        ch.label = ch:xcor() .. ',' .. ch:ycor()
    end

    -- Create a new collection
    Pursuers = FamilyMobil()

    -- Populate the collection with Agents.
    Pursuers:create_n (Config.Num_pursuers, function()
        return {
            ['pos']     = {math.random(0,100),math.random(0,100)}
            ,['heading'] = __2pi*math.random()
            ,['scale']   = 2
            ,['color']   = {0,0,1,1}
            ,['speed']   = math.random()
        }
    end)

    Pursueds = FamilyMobil()

    Pursueds:create_n (1, function()
        return {
            ['pos']     = {math.random(0,100),math.random(0,100)}
            ,['heading'] = __2pi*math.random()
            ,['scale']   = 2
            ,['color']   = {0,1,0,1}
            ,['speed']   = 1
        }
    end)

    pursued = one_of(Pursueds)

end

-- This function is executed until the stop condition is reached, 
-- or the button go/stop is stop
RUN = function()
    
    pursued:lt(random_float(-0.6,0.6))
    pursued:fd(1)
    pos_to_torus(pursued,100,100)

    for _,p in ordered(Pursuers) do
        if p:dist_euc_to(pursued) < 25 then
            p:face(pursued)
            p.color={0,0,1,1}
        else
            p.color={0,0,0.5,1}
        end
        p:lt(random_float(-0.4,0.4))
        p:fd(p.speed)
        pos_to_torus(p,100,100)
    end

end