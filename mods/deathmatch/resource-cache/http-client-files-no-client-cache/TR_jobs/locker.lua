function getLockerOptions()
    local jobID, jobType = getPlayerJob()

    if jobType == "mechanic" then
        return {{"Mekanik kıyafeti (E)", 50}, {"Mekanik kıyafeti (K)", 192}, {"Boyacı kıyafeti", 305}}
    elseif jobType == "taxi" then
        return {{"Taksi şoförü kıyafeti (E)", 171}, {"Taksi şoförü kıyafeti (K)", 172}}
    -- Fraksiyonlar
    elseif jobType == "fire" then
        return {{"Kışla kıyafeti (E)", 279}, {"Kışla kıyafeti (K)", 137}, {"Özel kıyafet (E)", 277}, {"Özel kıyafet (K)", 278}, {"Teknik kıyafet (E)", 293}}
    elseif jobType == "police" then
        return {{"Akademi kıyafeti (E)", 267}, {"Akademi kıyafeti (K)", 265}, {"Polis elbisesi (K)", 266}, {"PO I elbisesi (E)", 280}, {"PO II elbisesi (E)", 282}, {"PO III elbisesi (E)", 283}, {"PO IV elbisesi (E)", 284}, {"SGT I elbisesi (E)", 285}, {"SGT II elbisesi (E)", 286}, {"Korporal I elbisesi (E)", 287}, {"Korporal III elbisesi (E)", 288}, {"SWAT elbisesi (E)", 301}, {"ACOP elbisesi (E)", 246}, {"Deputy Chief elbisesi (E)", 238}, {"Komuta elbisesi (E)", 71}, {"SuperVisor elbisesi (E)", 257}, {"TEU elbisesi (E)", 256}, {"Chief elbisesi (E)", 245}}
    elseif jobType == "medic" then
        return {{"Kurtarıcı kıyafeti (E)", 302}, {"Kurtarıcı kıyafeti (K)", 303}, {"Doktor ceketi (E)", 274}, {"Cerrah ceketi (E)", 275}, {"Laborant ceketi (E)", 70}}
    elseif jobType == "news" then
        return {{"Editör kıyafeti (E)", 17}, {"Editör kıyafeti (K)", 219}, {"Fotoğrafçı kıyafeti (E)", 120}, {"Fotoğrafçı kıyafeti (K)", 91}, {"Kameraman kıyafeti (E)", 217}}
    elseif jobType == "ers" then
        return {{"Akademi kıyafeti (E)", 196}, {"Akademi kıyafeti (K)", 298}, {"İş elbisesi (E)", 145}, {"İş elbisesi (E)", 177}, {"Mekanik kıyafeti (E)", 190}}
    elseif jobID == "TR_warehouse" then
        return {{"İş elbisesi (E)", 16}, {"İş elbisesi (K)", 298}}
    elseif jobID == "TR_pizzaboy" then
        return {{"İş elbisesi (E)", 155}, {"İş elbisesi (K)", 304}}
    end
    
    return false
end

function updateLockerInfo()
    local jobID, jobType = getPlayerJob()
    local skin = getElementModel(localPlayer)

    if jobType == "fire" then
        if skin == 279 or skin == 137 or skin == 277 or skin == 278 then
            hideInformation()
        else
            createInformation("San Andreas İtfaiye Departmanı", "Soyunma odasına gidin ve uygun skin giyin.")

        end
        return

    elseif jobType == "medic" then
        if skin == 302 or skin == 303 or skin == 274 or skin == 275 or skin == 70 then
            hideInformation()
        else
            createInformation("Acil Tıbbi Hizmetler", "Soyunma odasına gidin ve uygun skin giyin.")

        end
        return

    elseif jobType == "police" then
        local weapons = getElementData(localPlayer, "weapons")
        if weapons then
            if #weapons > 0 then
                hideInformation()
                return
            end
        end

        if skin == 267 or skin == 265 or skin == 266 or skin == 280 or skin == 282 or skin == 283 or skin == 284 or skin == 285 or skin == 286 or skin == 287 or skin == 288 or skin == 301 or skin == 246 or skin == 238 or skin == 71 or skin == 257 or skin == 256 or skin == 245 then
            createInformation("San Andreas Polis Departmanı", "Atış poligonuna gidin ve ekipmanınızı alın.")

        else
            createInformation("San Andreas Polis Departmanı", "Gardıroba gidin ve uygun cilde bürünün veya hemen atış poligonuna giderek ekipmanınızı alın.")

        end

    elseif jobType == "fractionc" then
        if skin == 46 or skin == 59 or skin == 185 or skin == 12 or skin == 216 or skin == 91 then
            hideInformation()
        else
            createInformation("San Andreas Fraksiyon Merkezi", "Gardıroba gidin ve uygun cilde bürünün.")

        end
        return

    elseif jobType == "ers" then
        if skin == 196 or skin == 298 or skin == 145 or skin == 177 or skin == 190 then
            hideInformation()
        else
            createInformation("Acil Yol Hizmetleri", "Gardıroba gidin ve uygun cilde bürünün.")

        end
        return

    elseif jobType == "news" then
        if skin == 17 or skin == 219 or skin == 120 or skin == 91 or skin == 217 then
            hideInformation()
        else
            createInformation("İçeriden Haberler", "Gardıroba gidin ve uygun cilde bürünün.")

        end
        return
    end

    if skin == 50 then
        createInformation("Otomobil Mekaniği", "Boş bir istasyona gidin ve müşteriyi bekleyin, ardından ona tamir hizmeti sunun.")
    
    elseif skin == 305 then
        createInformation("Otomobil Boyacısı", "Boya istasyonuna gidin ve müşteriyi bekleyin, ardından boya hizmeti sunun.")
    
    elseif skin == 171 or skin == 172 then
        createInformation("Taksi Şoförü", "Bekleyin ya da müşteri almak için sık ziyaret edilen bir yere gidin. Bildirim panelini F4 tuşuyla açabilirsiniz.")
    
    elseif skin == 16 or skin == 298 then
        createInformation("Depo İşçisi", "Malzemelerin indirileceği yere gidin.")
        exports.TR_jobs:setPlayerTargetPos(2255.5432128906, -199.31307983398, 96.181617736816 - 0.5, 5, 1, "İndirmek için yaklaşın")
    
    elseif skin == 155 or skin == 304 then
        createInformation("Pizza Dağıtımı", "Dağıtım için hazır olan pizzaları alın.")
        setPlayerTargetPos(376.49130249023, -113.70402526855, 1001.4921875 - 0.5, 5, 1, "Siparişleri alın")
    else
        openLockerInfo()
    end
    

    exports.TR_weapons:updateWeapons()
end