local guiInfo = {}

TaxiWork = {}
TaxiWork.__index = TaxiWork

function TaxiWork:create(...)
    local instance = {}
    setmetatable(instance, TaxiWork)
    if instance:constructor(...) then
        return instance
    end
    return false
end

function TaxiWork:constructor()
    self.func = {}
    self.func.checkVehicle = function() self:checkVehicle() end
    self.func.onTaxiStartExit = function(...) self:onTaxiStartExit(source, ...) end
    self.func.onTaxiStartEnter = function(...) self:onTaxiStartEnter(source, ...) end
    self.func.onTaxiVehicleEnter = function(...) self:onTaxiVehicleEnter(source, ...) end

    addEventHandler("onClientVehicleEnter", resourceRoot, self.func.onTaxiVehicleEnter)
    addEventHandler("onClientVehicleStartExit", resourceRoot, self.func.onTaxiStartExit)
    addEventHandler("onClientVehicleStartEnter", resourceRoot, self.func.onTaxiStartEnter)
    return true
end

function TaxiWork:checkVehicle()
    local veh = getPedOccupiedVehicle(localPlayer)
    if not veh then
        removeTravelInfo()
        return
    end

    local seat = getPedOccupiedVehicleSeat(localPlayer)
    local index = getElementData(veh, "taxiPaySeat") or 0
    if seat == 0 then
        if index == 0 then
            triggerPayment()
        elseif getVehicleOccupant(veh, index) then
            createTravelInfo()
        else
            triggerPayment()
        end

    else
        if index == 0 then
            removeTravelInfo()

        elseif seat ~= index then
            removeTravelInfo()

        elseif seat == index then
            createTravelInfo()
        end
    end
end

function TaxiWork:onTaxiStartExit(source, plr, seat)
    if plr ~= localPlayer then return end
    if isTimer(self.checker) then killTimer(self.checker) end

    if seat == 0 then
        triggerServerEvent("removePlayerFromTaxi", resourceRoot, guiInfo.taxi)
    end
    removeTravelInfo()
end

function TaxiWork:onTaxiStartEnter(source, plr, seat)
    if plr ~= localPlayer then return end
    if seat == 0 then
        local jobID, jobType = exports.TR_jobs:getPlayerJob()

        if jobType ~= "taxi" or getElementData(source, "taxiID") ~= jobID then
            exports.TR_noti:create("Taksi şoförü olarak çalışmak için önce bir ofiste çalışmaya başlamalısınız.", "error", 5)
            cancelEvent()
            return
        end

        local model = getElementModel(localPlayer)
        if model ~= 171 and model ~= 172 then
            exports.TR_noti:create("Taksi şoförü olarak çalışmak için önce kıyafetlerinizi değiştirmelisiniz.", "error", 5)
            cancelEvent()
            return
        end

        if guiInfo.taxi and source ~= guiInfo.taxi then
            exports.TR_noti:create("Zaten size atanmış bir taksiniz var.", "error")
            cancelEvent()
            return
        end

        local taxiOwner = getElementData(source, "taxiOwner")
        if taxiOwner then
            if isElement(taxiOwner) and taxiOwner ~= localPlayer then
                exports.TR_noti:create("Başka bir oyuncuya ait olduğu için bu taksiye binemezsiniz.", "error")
                cancelEvent()
                return
            end
        end

        guiInfo.taxi = source
        setElementData(source, "taxiOwner", localPlayer)
        setElementData(source, "vehicleOwner", localPlayer)

    else
        if not getVehicleOccupant(source, 0) then
            cancelEvent()
            exports.TR_noti:create("Araçta taksici yok.", "error")
            return
        end
    end
end

function TaxiWork:onTaxiVehicleEnter(source, plr)
    if plr ~= localPlayer then return end

    if isTimer(self.checker) then killTimer(self.checker) end
    self.checker = setTimer(self.func.checkVehicle, 1000, 0)
end

TaxiWork:create()


function stopTaxiWork()
    guiInfo.taxi = nil
    triggerServerEvent("removePlayerTaxi", resourceRoot)
end

function addTaxiRequestInfo()
    local _, jobType = exports.TR_jobs:getPlayerJob()
    if jobType ~= "taxi" then return end

    exports.TR_noti:create("Yeni bir rapor geldi.", "info")
end
addEvent("addTaxiRequestInfo", true)
addEventHandler("addTaxiRequestInfo", root, addTaxiRequestInfo)