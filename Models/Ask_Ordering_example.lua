-- Interface and Global Parameters

Config:create_slider('N_agents', 0, 20, 1.0, 10)
Config:create_boolean('random_ordered', true)

-- SETUP Function: 

SETUP = function()

    Mobils = FamilyMobil()
    Mobils:create_n (Config.N_agents, function()
        return {
            ['pos']      = {0,0}
            ,['scale']   = 1.5
            ,['color']   = {1,0,0,1}
            ,['heading'] = math.pi / 2
        }
    end)

    local x = 0
    for _, ag in ordered(Mobils) do
        ag:move_to({x,0})
        ag.label = ag.id
        x = x + 2
    end

end

-- RUN Function: 

RUN = function()
    -- Limitación de ask: no puede combinarse con otras variables que cambien en cada ciclo... algo que tiene sentido
    -- si se considera el ask como una ejecución paralela.
    if Config.random_ordered then
        for _,ag in shuffled(Mobils) do
            ag:fd(1)
        end
    else
        for _,ag in ordered(Mobils) do
            ag:fd(1)
        end
    end
end