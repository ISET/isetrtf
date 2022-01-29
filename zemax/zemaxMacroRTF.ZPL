! Image height (=object side for reverse lens)
! Set this equal to the largest off-axis Field Distance defined in Field Setup
ImgHeight = 1.08

! Set file name for txt file dump
file2$ = "c:\path\to\folder\wideangle200deg-primaryWL1.txt"

! Number of samples on inputplane
NumOfHeightStep = 50   
! Number of radial and angular samples on the exit pupil
NumOfRadiusStep = 30
NumOfAnglesStep = 18



nw = NWAV()
ns = NSUR()
nf = NFLD()

maxfield = MAXF()
PI = 2*ACOS(0)

OUTPUT SCREEN

FORMAT .0
PRINT "Number of wavelengths = ", nw
PRINT "Number of surfaces = ", ns
PRINT "Number of field = ", nf
PRINT

PRINT "Setting up parameters..."
hx = 0
hy = 1
px = 0
py = 0







ImgHgtDelta = 1/NumOfHeightStep
RadiusDelta = 1/NumOfRadiusStep
AnglesDelta = 2*PI/NumOfAnglesStep

TIMER
FORMAT .6
PRINT "Processing..."

OUTPUT file2$

PRINT "Count    x        y        z        dx       dy       dz       x'       y'       z'       dx'      dy'      dz'      err      "
rayTraced = 1
ray_Error = 0

FOR hIndex, 0, NumOfHeightStep, 1
    hx = 0
    hy = hIndex * ImgHgtDelta

    FOR rIndex, 0, NumOfRadiusStep, 1
    
        IF (rIndex != 0)
            FOR aIndex, 0, rIndex*NumOfAnglesStep-1, 1
                px = rIndex * RadiusDelta * COSI(aIndex*AnglesDelta/rIndex)
                py = rIndex * RadiusDelta * SINE(aIndex*AnglesDelta/rIndex)
                RAYTRACE hx, hy, px, py, 1
                IF ((RAYV() != 0) | (RAYE() != 0))
                   PRINT rayTraced, " ", 0, " ", hy*ImgHeight, " ", 0, " NaN NaN NaN NaN NaN NaN NaN NaN NaN"
                   ray_Error = ray_Error + 1
                ELSE
                  dzprimeErr = (RAGN(ns) - dzprime)/dzprime
                  PRINT rayTraced, " ", RAGX(0), " ", hy*ImgHeight, " ", RAGZ(0), " ", RAGL(0), " ", RAGM(0), " ", RAGN(0), " ", RAGX(ns), " ", RAGY(ns), " ", RAGZ(ns), " ", RAGL(ns), " ", RAGM(ns), " ", RAGN(ns), " ", dzprimeErr
                ENDIF
                rayTraced = rayTraced + 1
            NEXT
        ELSE
            px = 0
            py = 0
            RAYTRACE hx, hy, px, py, 1
            IF ((RAYV() != 0) | (RAYE() != 0))
               PRINT rayTraced, " ", 0, " ", hy*ImgHeight, " ", 0, " NaN NaN NaN NaN NaN NaN NaN NaN NaN"
               ray_Error = ray_Error + 1
            ELSE
               ! Record dz' of this chief ray
               dzprime = RAGN(ns)
                  PRINT rayTraced, " ", 0, " ", hy*ImgHeight, " ", 0, " ", RAGL(0), " ", RAGM(0), " ", RAGN(0), " ", RAGX(ns), " ", RAGY(ns), " ", RAGZ(ns), " ", RAGL(ns), " ", RAGM(ns), " ", RAGN(ns), " ", 0
            ENDIF            
            rayTraced = rayTraced + 1
        ENDIF
    NEXT
NEXT
rayTraced = rayTraced - 1

OUTPUT SCREEN
PRINT "Done..."
PRINT "# of ray traced = ", rayTraced
PRINT "# of error ray  = ", ray_Error
PRINT "Elapsed time: ", ETIM(), "seconds"
