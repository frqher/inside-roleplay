highwayGates = {}

positions = {
    {
        positions = {
            gate      = {1637.79, -7.70, 36.35, 0, 90, 25},
            vehSpawn  = {1637.01782, -37.61654, 36.60964,205.16},
        },
    },
    {
        positions = {
            gate      = {1638.79, -21.70, 36.35, 0, 90, 204},
            vehSpawn  = {1639.97241, 6.38590, 36.63328,24.10},
        },
    },

    --- SF
    {
        positions = {
            gate      = {-1387.59, 825.40, 47.15, 0, 90, 136.5},
            vehSpawn  = {-1420.62634, 820.29822, 47.30768,136.99},
        },
        flipped = true,
    },
    {
        positions = {
            gate      = {-1410.5, 828.59, 47.15, 0, 90, 317.12},
            vehSpawn  = {-1376.67285, 834.56500, 47.30693,316.79},
        },
        flipped = true,
    },

    --- SF - BM
    {
        positions = {
            gate      = {-2680.5, 1280.40, 55.26, 0, 90, -0},
            vehSpawn  = {-2690.68604, 1239.47339, 55.42969,196.02},
        },
    },
    {
        positions = {
            gate      = {-2664.39, 1280.40, 55.26, 0, 90, 180},
            vehSpawn  = {-2690.68604, 1239.47339, 55.42969,196.02},
        },
        flipped = true,
    },
    {
        positions = {
            gate      = {-2682.70, 1269.59, 55.26, 0, 90, 180},
            vehSpawn  = {-2667.2158203125, 1318.7333984375, 55.106704711914, 11.912109375},
        },
    },
    {
        positions = {
            gate      = {-2698.29, 1269.59, 55.26, 0, 90, 0},
            vehSpawn  = {-2667.2158203125, 1318.7333984375, 55.106704711914, 11.912109375},
        },
        flipped = true,
    },
}

function getPosition(element, vec)
	local rot = Vector3(getElementRotation(element))
	local mat = Matrix(Vector3(getElementPosition(element)), rot)
	local newPos = mat:transformPosition(vec)
	return newPos.x, newPos.y, newPos.z, rot.z
end