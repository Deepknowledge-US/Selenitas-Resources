-- "Communication_Mobiles"
-- Agents are created and randomly located in the world
-- A message is given to one of them
-- Agents will share the message with others if close enough.
-- The simulation ends when all agents have the message.

-- Interface and Globals Parameters

Config:create_slider('Num_agents', 0, 1000, 1, 100)
Config:create_slider('radius', 0, 10, .01, 1)


-- Agents with the message will share it with other agents (without the message) inside the radius
local function comunicate(x)

    if x.message then
        local neighborhood = People:with(function(other)
            return not other.message and (other:dist_euc_to(x) <= Config.radius)
        end)
        for _,other in ordered(neighborhood) do
            other.message = true
            other.color = {0,0,1,1}
        end
    end

end

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
    -- Marks
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

    -- Create a new Family
    People = FamilyMobil()

    -- Populate the Family with Agents.
    People:create_n(Config.Num_agents, function()
        return {
            ['pos']     = {math.random(0,100),math.random(0,100)}
            ,['message'] = false
            ,['heading'] = __2pi * math.random()
            ,['scale']   = 2
        }
    end)

    local one_person = one_of(People)
    one_person.message = true
    one_person.color = {0,0,1,1}

    Config.go = true

end

-- This function is executed until the stop condition is reached, 
-- or the button go/stop is stop
RUN = function()
    if not Config.go then
        do return end
    end
    -- Stop condition
    if People:with(function(x) return x.message == false end).count == 0 then
        Config.go = false
        return
    end


    for _, person in ordered(People) do
        person:lt(random_float(-0.5,0.5))
        person:fd(1)
        pos_to_torus(person,100,100)
        comunicate(person)
    end

end